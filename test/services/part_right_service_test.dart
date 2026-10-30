import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/models/part_right.dart';
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
import 'package:dis_app/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Schalter pro Anteil setzen, und wer das darf.
///
/// Rechte vergeben durfte bisher nur ein Admin, obwohl es dafür das Recht
/// `managePermissions` gibt. Der Schirm bot das Ändern an, der Dienst
/// lehnte es für jeden Nicht-Admin ab.
void main() {
  late Directory tempDir;
  late ProfileService profileService;
  late DataEntry dataEntry;

  Future<void> anlegen(
    String id, {
    bool isAdmin = false,
    List<String> rechte = const [],
  }) => profileService.profilesBox.put(
    id,
    Profile(
      id: id,
      nameRaw: id,
      preferredColorValue: 0xFF3366CC,
      createdAt: DateTime(2026, 10, 29),
      isAdmin: isAdmin,
      permissions: rechte,
    ),
  );

  // Ohne `subscribeToEvents()` kommt `ActiveProfileChangedEvent` nicht an,
  // also direkt dorthin schreiben, wo der Dienst das aktive Profil liest.
  Future<void> aktiv(String id) =>
      profileService.settingsBox.put('active_profile_id', id);

  List<String> gespeichert(String id) =>
      profileService.profilesBox.get(id)!.permissions;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('part_right_service_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }

    final eventBus = EventBus();
    profileService = ProfileService(eventBus);
    await profileService.openBoxes();
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

    await anlegen(
      'admin',
      isAdmin: true,
      rechte: Permission.values.map((p) => p.persistedValue).toList(),
    );
    await anlegen(
      'verwalter',
      rechte: [Permission.managePermissions.persistedValue],
    );
    await anlegen('ohne-rechte');
    await anlegen(
      'anteil',
      rechte: [
        Permission.editAllEvents.persistedValue,
        Permission.editAllDiaryEntries.persistedValue,
      ],
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('Schalter pro Anteil setzen', () {
    test('Nicht-Admin mit Rechte vergeben darf schalten', () async {
      await aktiv('verwalter');

      final ok = await dataEntry.setPartRight(
        'anteil',
        PartRight.readOthersDiaries,
        on: true,
      );

      expect(ok, isTrue);
      expect(
        gespeichert('anteil'),
        contains(Permission.viewAllDiaries.persistedValue),
      );
    });

    test('ohne Rechte vergeben bleibt alles, wie es war', () async {
      await aktiv('ohne-rechte');
      final vorherAnteil = List<String>.of(gespeichert('anteil'));
      final vorherSelbst = List<String>.of(gespeichert('ohne-rechte'));

      final fremd = await dataEntry.setPartRight(
        'anteil',
        PartRight.deleteOthersEntries,
        on: true,
      );
      // Auch sich selbst das Recht zu geben, scheitert.
      final selbst = await dataEntry.setPartRight(
        'ohne-rechte',
        PartRight.grantRights,
        on: true,
      );

      expect(fremd, isFalse);
      expect(selbst, isFalse);
      expect(gespeichert('anteil'), vorherAnteil);
      expect(gespeichert('ohne-rechte'), vorherSelbst);
    });

    test('Schalter an setzt alle seine Rechte', () async {
      await aktiv('admin');

      final ok = await dataEntry.setPartRight(
        'anteil',
        PartRight.deleteOthersEntries,
        on: true,
      );

      expect(ok, isTrue);
      expect(
        gespeichert('anteil'),
        containsAll([
          Permission.deleteAllMessages.persistedValue,
          Permission.deleteAllEvents.persistedValue,
          Permission.deleteAllDiaryEntries.persistedValue,
          // Rechte anderer Schalter bleiben stehen
          Permission.editAllEvents.persistedValue,
          Permission.editAllDiaryEntries.persistedValue,
        ]),
      );
    });

    test('Medikamente sehen aus nimmt den Plan mit', () async {
      await aktiv('admin');
      await dataEntry.setPartRight(
        'anteil',
        PartRight.changeMedicationPlan,
        on: true,
      );

      final ok = await dataEntry.setPartRight(
        'anteil',
        PartRight.seeMedication,
        on: false,
      );

      expect(ok, isTrue);
      final profile = profileService.profilesBox.get('anteil')!;
      expect(PartRight.seeMedication.stateFor(profile), PartRightState.off);
      expect(
        PartRight.changeMedicationPlan.stateFor(profile),
        PartRightState.off,
      );
    });
  });
}
