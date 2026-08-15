import 'dart:io';

import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/password_reset_service.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Durchstich über den ganzen Reset-Lebenszyklus (Unit 6).
///
/// Prüft, was die Einzeltests nicht sehen: dass Start, Neustart, Abbruch,
/// Ablauf und Aktivierung über echte Hive-Boxen hinweg zusammenspielen —
/// auch über einen App-Neustart und die Migration vom alten globalen Slot.
void main() {
  late Directory tempDir;
  late ProfileService profileService;
  late PasswordResetService resetService;
  late EventBus eventBus;
  late DateTime jetzt;

  DateTime uhr() => jetzt;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('reset_flow_test_');
    Hive.init(tempDir.path);
    jetzt = DateTime(2026, 8, 5, 12);

    eventBus = EventBus();
    profileService = ProfileService(eventBus);
    await profileService.openBoxes();
    resetService =
        PasswordResetService(profileService, eventBus, nowProvider: uhr);
    await resetService.performMigration();
  });

  tearDown(() async {
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } on FileSystemException {
      // Windows-Lock — das Betriebssystem räumt auf
    }
  });

  Future<void> legeAn(String id, String passwort, {int? fristStunden}) async {
    await profileService.profilesBox.put(
      id,
      Profile(
        id: id,
        nameRaw: 'Profil $id',
        preferredColorValue: 0xFFAA0000,
        createdAt: jetzt,
        passwordHash: Profile.hashPassword(passwort),
        resetDurationHours: fristStunden,
      ),
    );
  }

  Profile hole(String id) => profileService.profilesBox.get(id)!;

  test('voller Lebenszyklus: Start, Neustart, Abbruch, Ablauf, Aktivierung',
      () async {
    await legeAn('profil-eins-0001', 'altespasswort');

    // Start
    expect(await resetService.startReset('profil-eins-0001', 'ersterversuch'),
        isTrue);
    final endeErst = hole('profil-eins-0001').resetEndsAt!;
    expect(hole('profil-eins-0001').hasActiveReset, isTrue);

    // Neustart ersetzt Pending und friert ein neues Ende ein
    jetzt = jetzt.add(const Duration(hours: 3));
    await resetService.startReset('profil-eins-0001', 'zweiterversuch');
    expect(hole('profil-eins-0001').resetEndsAt!.isAfter(endeErst), isTrue);

    // Abbruch durch Login mit dem alten Passwort
    expect(
      await resetService.checkAndHandleLogin(
          hole('profil-eins-0001'), 'altespasswort'),
      ResetLoginOutcome.cancelled,
    );
    expect(hole('profil-eins-0001').hasActiveReset, isFalse);
    expect(hole('profil-eins-0001').hasPendingPassword, isFalse);

    // Erneuter Start, diesmal bis zum Ablauf
    await resetService.startReset('profil-eins-0001', 'neuespasswort');
    jetzt = jetzt.add(const Duration(hours: 25));

    // Aktivierung beim ersten Login mit dem neuen Passwort
    expect(
      await resetService.checkAndHandleLogin(
          hole('profil-eins-0001'), 'neuespasswort'),
      ResetLoginOutcome.activated,
    );
    final danach = hole('profil-eins-0001');
    expect(danach.hasActiveReset, isFalse);
    expect(danach.verifyPassword('neuespasswort'), isTrue);
    expect(danach.verifyPassword('altespasswort'), isFalse);
  });

  test('zwei Profile mit verschiedenen Fristen stören einander nicht',
      () async {
    await legeAn('profil-eins-0001', 'passwort-eins');
    await legeAn('profil-zwei-0002', 'passwort-zwei', fristStunden: 168);

    await resetService.startReset('profil-eins-0001', 'neu-eins');
    await resetService.startReset('profil-zwei-0002', 'neu-zwei');

    // Nach 25 Stunden ist nur die Ein-Tages-Frist durch: dort greift das
    // neue Passwort, beim Sieben-Tage-Profil noch das alte.
    jetzt = jetzt.add(const Duration(hours: 25));

    expect(
      await resetService.checkAndHandleLogin(
          hole('profil-eins-0001'), 'neu-eins'),
      ResetLoginOutcome.activated,
    );
    expect(
      await resetService.checkAndHandleLogin(
          hole('profil-zwei-0002'), 'passwort-zwei'),
      ResetLoginOutcome.cancelled,
    );

    // Jedes Profil hat seinen eigenen Ausgang genommen
    expect(hole('profil-eins-0001').verifyPassword('neu-eins'), isTrue);
    expect(hole('profil-zwei-0002').verifyPassword('passwort-zwei'), isTrue);
    expect(hole('profil-zwei-0002').hasPendingPassword, isFalse);
  });

  test('App-Neustart mitten in der Frist erhält Zustand und Restzeit',
      () async {
    await legeAn('profil-eins-0001', 'altespasswort');
    await resetService.startReset('profil-eins-0001', 'neuespasswort');
    final ende = hole('profil-eins-0001').resetEndsAt!;

    // Boxen schließen und erneut öffnen — wie ein App-Neustart
    await Hive.close();
    Hive.init(tempDir.path);
    profileService = ProfileService(eventBus);
    await profileService.openBoxes();
    resetService =
        PasswordResetService(profileService, eventBus, nowProvider: uhr);

    final nachNeustart = hole('profil-eins-0001');
    expect(nachNeustart.hasActiveReset, isTrue);
    expect(nachNeustart.resetEndsAt, ende);
    expect(nachNeustart.hasPendingPassword, isTrue);
  });

  test('Migration beendet einen Reset aus dem alten globalen Slot', () async {
    await legeAn('profil-eins-0001', 'altespasswort');
    // Alter Zustand: Pending am Profil, Frist im globalen Settings-Slot
    await profileService.profilesBox.put(
      'profil-eins-0001',
      hole('profil-eins-0001').copyWith(pendingPasswordHash: 'alt-pending'),
    );
    await profileService.settingsBox
        .put('password_reset_timer', jetzt.millisecondsSinceEpoch);
    await profileService.settingsBox
        .put('password_reset_profile_id', 'profil-eins-0001');

    await resetService.performMigration();

    expect(profileService.settingsBox.get('password_reset_timer'), isNull);
    expect(profileService.settingsBox.get('password_reset_profile_id'), isNull);
    expect(hole('profil-eins-0001').hasPendingPassword, isFalse);
    expect(profileService.settingsBox.get('reset_migration_notice'),
        isNotNull);
  });
}
