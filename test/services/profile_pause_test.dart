import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/profile_events.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/calendar_service.dart';
import 'package:dis_app/services/chat_service.dart';
import 'package:dis_app/services/comment_service.dart';
import 'package:dis_app/services/contact_service.dart';
import 'package:dis_app/services/diary_service.dart';
import 'package:dis_app/services/finder_service.dart';
import 'package:dis_app/services/medication_service.dart';
import 'package:dis_app/services/navigation_service.dart';
import 'package:dis_app/services/password_reset_service.dart';
import 'package:dis_app/services/permission_preset_service.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Pausieren wirkt wirklich.
///
/// `DataEntry.deactivateProfile` veröffentlichte nur ein Ereignis, auf das
/// niemand den Zustand änderte. Die Oberfläche meldete Erfolg, der Anteil
/// blieb in der Auswahl.
void main() {
  late Directory tempDir;
  late EventBus eventBus;
  late ProfileService profileService;
  late DataEntry dataEntry;
  late List<String> pausiertGemeldet;

  Future<void> anlegen(
    String id, {
    String? name,
    bool isAdmin = false,
    bool isActive = true,
    List<String> rechte = const [],
    String? passwordHash,
    String? sprache,
    DateTime? angelegt,
  }) => profileService.profilesBox.put(
    id,
    Profile(
      id: id,
      nameRaw: name ?? id,
      preferredColorValue: 0xFF3366CC,
      createdAt: angelegt ?? DateTime(2026, 10, 29),
      isAdmin: isAdmin,
      isActive: isActive,
      permissions: rechte,
      passwordHash: passwordHash,
      preferredLanguage: sprache,
    ),
  );

  // Direkt dorthin schreiben, wo der Dienst das aktive Profil liest.
  Future<void> aktiv(String id) =>
      profileService.settingsBox.put('active_profile_id', id);

  Profile gespeichert(String id) => profileService.profilesBox.get(id)!;

  // Der Bus liefert nicht synchron aus.
  Future<void> busLeeren() => Future<void>.delayed(Duration.zero);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('profile_pause_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }

    eventBus = EventBus();
    profileService = ProfileService(eventBus);
    await profileService.openBoxes();
    // Wie in der App: Der Dienst hört auf die Ereignisse, auch auf
    // `ProfileDeactivatedEvent`.
    profileService.subscribeToEvents();
    dataEntry = DataEntry(
      eventBus,
      chatService: ChatService(eventBus),
      profileService: profileService,
      calendarService: CalendarService(eventBus),
      medicationService: MedicationService(eventBus),
      contactService: ContactService(eventBus),
      finderService: FinderService(eventBus),
      diaryService: DiaryService(eventBus),
      commentService: CommentService(eventBus),
      navigationService: NavigationService(eventBus),
      passwordResetService: PasswordResetService(profileService, eventBus),
    );

    pausiertGemeldet = [];
    eventBus.on<ProfileDeactivatedEvent>().listen(
      (event) => pausiertGemeldet.add(event.profileId),
    );

    await anlegen(
      'admin',
      isAdmin: true,
      rechte: Permission.values.map((p) => p.persistedValue).toList(),
    );
    // Kein Admin, aber mit dem Recht „Anteile pausieren“.
    await anlegen(
      'verwalter',
      rechte: [Permission.deactivateProfiles.persistedValue],
    );
    await anlegen('ohne-recht');
    await anlegen(
      'mira',
      name: 'Mira',
      rechte: [
        Permission.viewMedication.persistedValue,
        Permission.editAllEvents.persistedValue,
      ],
      passwordHash: 'gespeicherter-hash-von-mira',
      sprache: 'en',
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('pausieren versteckt den Anteil', () async {
    await anlegen('zora', name: 'Zora', isActive: false);
    await anlegen('ben', name: 'Ben', isActive: false);
    await aktiv('admin');

    final ok = await dataEntry.pauseProfile('mira');
    await busLeeren();

    expect(ok, isTrue);
    expect(dataEntry.getProfiles().map((p) => p.id), isNot(contains('mira')));
    expect(dataEntry.getAllProfiles().map((p) => p.id), contains('mira'));
    expect(
      dataEntry.getPausedProfiles().map((p) => p.name),
      ['Ben', 'Mira', 'Zora'],
    );
    // Der Handler des Ereignisses lässt das aktive Profil, wo es ist.
    expect(dataEntry.getActiveProfile()?.id, 'admin');
  });

  test('pausieren über DataEntry ändert den Zustand', () async {
    await aktiv('verwalter');
    expect(dataEntry.canPauseProfile('mira'), isTrue);

    final ok = await dataEntry.pauseProfile('mira');
    await busLeeren();

    expect(ok, isTrue);
    expect(gespeichert('mira').isActive, isFalse);
    // Das Ereignis kommt nach der Änderung, genau einmal.
    expect(pausiertGemeldet, ['mira']);
  });

  test('das eigene Profil lässt sich nicht pausieren', () async {
    await aktiv('verwalter');

    expect(dataEntry.canPauseProfile('verwalter'), isFalse);
    final ok = await dataEntry.pauseProfile('verwalter');
    await busLeeren();

    expect(ok, isFalse);
    expect(gespeichert('verwalter').isActive, isTrue);
    expect(pausiertGemeldet, isEmpty);
    expect(dataEntry.getActiveProfile()?.id, 'verwalter');
  });

  test('der letzte Admin lässt sich nicht pausieren', () async {
    // Ein pausierter Admin zählt nicht mit.
    await anlegen('admin-pausiert', isAdmin: true, isActive: false);
    await aktiv('verwalter');

    expect(dataEntry.canPauseProfile('admin'), isFalse);
    final ok = await dataEntry.pauseProfile('admin');
    await busLeeren();

    expect(ok, isFalse);
    expect(gespeichert('admin').isActive, isTrue);
    expect(pausiertGemeldet, isEmpty);

    // Gegenprobe: Mit einem zweiten aktiven Admin geht es.
    await anlegen('admin-zwei', isAdmin: true);
    expect(dataEntry.canPauseProfile('admin'), isTrue);
    expect(await dataEntry.pauseProfile('admin'), isTrue);
    expect(gespeichert('admin').isActive, isFalse);
  });

  group('Admin-Rolle abgeben', () {
    final alle = Permission.values.map((p) => p.persistedValue).toList();

    setUp(() async {
      // Abgeben setzt die Vorlage `standard`. Ungeladen liefert der Dienst
      // eine leere Liste, das genügt hier.
      getIt.registerSingleton<PermissionPresetService>(
        PermissionPresetService(),
      );
      // A ist der älteste Anteil, B ist jünger und damit nicht der erste.
      await anlegen(
        'admin-a',
        isAdmin: true,
        rechte: alle,
        angelegt: DateTime(2026),
      );
      await anlegen(
        'admin-b',
        isAdmin: true,
        rechte: alle,
        angelegt: DateTime(2026, 12),
      );
      await profileService.profilesBox.delete('admin');
      await aktiv('admin-b');
    });

    tearDown(() => getIt.unregister<PermissionPresetService>());

    // B pausiert A und gibt danach die eigene Admin-Rolle ab. Zählte der
    // pausierte A dabei als „ein Admin bleibt“, wäre kein aktiver Admin mehr
    // da, und niemand könnte A zurückholen.
    test(
      'wer den anderen Admin pausiert hat, behält die Admin-Rolle',
      () async {
        expect(dataEntry.canRevokeAdmin('admin-b'), isTrue);
        expect(await dataEntry.pauseProfile('admin-a'), isTrue);
        expect(gespeichert('admin-a').isActive, isFalse);

        // Die Oberfläche fragt dieselbe Stelle und bietet nichts an.
        expect(dataEntry.canRevokeAdmin('admin-b'), isFalse);
        final ok = await dataEntry.revokeAdmin('admin-b');

        expect(ok, isFalse);
        expect(gespeichert('admin-b').isAdmin, isTrue);
        expect(dataEntry.canResumeProfiles(), isTrue);
      },
    );

    test('mit einem zweiten aktiven Admin geht das Abgeben', () async {
      await anlegen(
        'admin-c',
        isAdmin: true,
        rechte: alle,
        angelegt: DateTime(2026, 12),
      );
      expect(await dataEntry.pauseProfile('admin-a'), isTrue);

      final ok = await dataEntry.revokeAdmin('admin-b');

      expect(ok, isTrue);
      expect(gespeichert('admin-b').isAdmin, isFalse);
    });

    test('nur ein Admin nimmt die Rolle, nie die des ersten Anteils', () async {
      await anlegen('admin-c', isAdmin: true, angelegt: DateTime(2026, 12));

      // Der älteste Anteil bleibt Admin.
      expect(dataEntry.canRevokeAdmin('admin-a'), isFalse);
      expect(await dataEntry.revokeAdmin('admin-a'), isFalse);
      // Wer kein Admin ist, hat keine Rolle abzugeben.
      expect(dataEntry.canRevokeAdmin('mira'), isFalse);

      // Ein Nicht-Admin mit „Rechte vergeben“ nimmt niemandem die Rolle.
      await anlegen(
        'verwalter',
        rechte: [Permission.managePermissions.persistedValue],
      );
      await aktiv('verwalter');
      expect(dataEntry.canRevokeAdmin('admin-c'), isFalse);
      expect(await dataEntry.revokeAdmin('admin-c'), isFalse);
      expect(gespeichert('admin-c').isAdmin, isTrue);
    });
  });

  test('ohne Recht kein Pausieren', () async {
    await aktiv('ohne-recht');

    expect(dataEntry.canPauseProfile('mira'), isFalse);
    final ok = await dataEntry.pauseProfile('mira');
    await busLeeren();

    expect(ok, isFalse);
    expect(gespeichert('mira').isActive, isTrue);
    expect(pausiertGemeldet, isEmpty);
  });

  test('schon pausiert oder unbekannt lässt sich nicht pausieren', () async {
    await anlegen('zora', isActive: false);
    await aktiv('admin');

    expect(dataEntry.canPauseProfile('zora'), isFalse);
    expect(dataEntry.canPauseProfile('gibt-es-nicht'), isFalse);
    expect(await dataEntry.pauseProfile('gibt-es-nicht'), isFalse);
  });

  test('pausieren ändert nur isActive', () async {
    await aktiv('admin');
    final vorher = gespeichert('mira');

    await dataEntry.pauseProfile('mira');
    final nachher = gespeichert('mira');

    expect(nachher.isActive, isFalse);
    expect(nachher.name, vorher.name);
    expect(nachher.passwordHash, vorher.passwordHash);
    expect(nachher.permissions, vorher.permissions);
    expect(nachher.preferredLanguage, vorher.preferredLanguage);
    // Auch kein anderes Feld.
    expect(
      nachher.toMap()..remove('is_active'),
      vorher.toMap()..remove('is_active'),
    );

    // Wieder aufgenommen ist der Anteil wie vorher, das Passwort gilt weiter.
    await dataEntry.resumeProfile('mira');
    expect(gespeichert('mira').toMap(), vorher.toMap());
  });

  test('niemand pausiert ist der Normalfall und keine Warnung', () {
    // Warnungen landen im Ringpuffer mit 50 Plätzen, der in Fehlerberichten
    // mitgeht. Die Abfrage läuft bei jedem Aufbau der Profilauswahl; meldete
    // sie die leere Liste, verdrängte sie dort echte Warnungen.
    int warnungen() => logger
        .getRecentErrors()
        .where((e) => e.message.contains('getPausedProfiles'))
        .length;
    final vorher = warnungen();

    expect(dataEntry.getPausedProfiles(), isEmpty);
    expect(warnungen(), vorher);
  });

  test('wieder aufnehmen braucht dasselbe Recht wie pausieren', () async {
    await aktiv('admin');
    await dataEntry.pauseProfile('mira');

    await aktiv('ohne-recht');
    expect(dataEntry.canResumeProfiles(), isFalse);
    expect(await dataEntry.resumeProfile('mira'), isFalse);
    expect(gespeichert('mira').isActive, isFalse);

    // Kein Admin, aber mit dem Recht: Das genügt, wie beim Pausieren.
    await aktiv('verwalter');
    expect(dataEntry.canResumeProfiles(), isTrue);
    expect(await dataEntry.resumeProfile('mira'), isTrue);
    expect(gespeichert('mira').isActive, isTrue);
    expect(dataEntry.getProfiles().map((p) => p.id), contains('mira'));
    expect(dataEntry.getPausedProfiles(), isEmpty);
  });

  // Regel 34: Die Admin-Prüfung in `makeAdmin` und `canRevokeAdmin` ist die
  // einzige Schranke zwischen „Rechte vergeben“ und der Admin-Rolle. Fiele
  // sie, ernennte sich ein Anteil mit diesem Recht selbst zum Admin.
  test('mit „Rechte vergeben“, aber ohne Admin-Rolle: weder ernennen noch '
      'abgeben', () async {
    await anlegen(
      'rechtevergeber',
      rechte: [Permission.managePermissions.persistedValue],
    );
    // Ein zweiter Admin, jünger als alle anderen: Abgeben scheitert hier nur
    // an der Admin-Prüfung, nicht am ersten Anteil oder am letzten Admin.
    await anlegen(
      'admin-zwei',
      isAdmin: true,
      rechte: Permission.values.map((p) => p.persistedValue).toList(),
      angelegt: DateTime(2027),
    );
    await aktiv('rechtevergeber');
    Map<String, Map<String, dynamic>> bestand() => {
      for (final p in profileService.profilesBox.values) p.id: p.toMap(),
    };
    final vorher = bestand();

    expect(await dataEntry.makeAdmin('rechtevergeber'), isFalse);
    expect(await dataEntry.makeAdmin('mira'), isFalse);
    expect(dataEntry.canRevokeAdmin('admin-zwei'), isFalse);
    expect(await dataEntry.revokeAdmin('admin-zwei'), isFalse);

    expect(bestand(), vorher);
  });
}
