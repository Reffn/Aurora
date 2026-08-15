import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/l10n/app_localizations.dart';
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
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/profile_actions_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Widget-Tests für die Reset-Verzweigung im Login-Pfad (Unit 3).
///
/// Geprüft wird ausschließlich die UI-Verzweigung: welcher Bestätigungs-
/// dialog bei welchem ResetLoginOutcome erscheint. Die Zustandslogik selbst
/// ist durch test/services/password_reset_service_test.dart abgedeckt.
/// Deshalb ein DataEntry-Fake ohne Hive — echte Datei-IO completed in der
/// FakeAsync-Zone von testWidgets nicht zuverlässig (Windows).
class _FakeDataEntry extends DataEntry {
  _FakeDataEntry(
    super.eventBus, {
    required super.chatService,
    required super.profileService,
    required super.calendarService,
    required super.medicationService,
    required super.contactService,
    required super.finderService,
    required super.diaryService,
    required super.commentService,
    required super.navigationService,
    required super.passwordResetService,
  });

  ResetLoginOutcome nextOutcome = ResetLoginOutcome.none;
  Profile? _active;
  int changeActiveProfileCalls = 0;
  late Box<dynamic> fakeSettingsBox;

  @override
  Box<dynamic> get settingsBox => fakeSettingsBox;

  @override
  Future<ResetLoginOutcome> checkAndHandleLogin(
    Profile profile,
    String enteredPassword, {
    String source = 'UI',
  }) async {
    return nextOutcome;
  }

  @override
  Future<void> changeActiveProfile(
    Profile profile, {
    String source = 'UI',
  }) async {
    changeActiveProfileCalls++;
    _active = profile;
  }

  @override
  Profile? getActiveProfile() => _active;
}

void main() {
  late _FakeDataEntry fakeDataEntry;
  late Profile profile;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('dialog_reset_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }

    final eventBus = EventBus();
    final profileService = ProfileService(eventBus);
    await profileService.openBoxes();
    final settingsBox = profileService.settingsBox;
    final resetService = PasswordResetService(profileService, eventBus);
    fakeDataEntry = _FakeDataEntry(
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
      passwordResetService: resetService,
    );
    fakeDataEntry.fakeSettingsBox = settingsBox;

    await getIt.reset();
    getIt.registerSingleton<DataEntry>(fakeDataEntry);
    getIt.registerSingleton<PasswordResetService>(resetService);

    profile = Profile(
      id: 'profil-1111-2222-3333',
      nameRaw: 'TestProfil',
      preferredColorValue: 0xFF0000,
      createdAt: DateTime.now(),
      passwordHash: 'irrelevant-fake-pruefung-laeuft-nie',
    );
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } on FileSystemException {
      // Windows-Lock — Aufräumen dem Betriebssystem überlassen
    }
  });

  /// Feste Pumps statt pumpAndSettle — der Avatar-Glow animiert dauerhaft.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> pumpDialogAndLogin(
    WidgetTester tester,
    String password, {
    bool requireCurrentProfileLogin = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => ProfileActionsDialog.show(
                  context,
                  profile,
                  requireCurrentProfileLogin: requireCurrentProfileLogin,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);

    await tester.enterText(find.byType(TextField).first, password);
    await settle(tester);

    await tester.ensureVisible(find.text('Weiter als TestProfil'));
    await tester.tap(find.text('Weiter als TestProfil'));
    await settle(tester);
  }

  group('profile_actions_dialog Reset-Verzweigung (Unit 3)', () {
    testWidgets('session lock authenticates the previously active profile', (
      tester,
    ) async {
      await fakeDataEntry.changeActiveProfile(profile);

      await pumpDialogAndLogin(
        tester,
        'richtig',
        requireCurrentProfileLogin: true,
      );

      expect(fakeDataEntry.getActiveProfile()?.id, profile.id);
      expect(fakeDataEntry.changeActiveProfileCalls, 1);
      expect(find.byType(ProfileActionsDialog), findsNothing);
    });

    testWidgets(
      'cancelled: Abbruch-Bestätigung sichtbar, danach Profil aktiv',
      (tester) async {
        fakeDataEntry.nextOutcome = ResetLoginOutcome.cancelled;

        await pumpDialogAndLogin(tester, 'altespasswort');

        expect(find.text('Zurücksetzen abgebrochen'), findsOneWidget);
        expect(find.byIcon(Icons.timer_off_outlined), findsOneWidget);

        await tester.tap(find.text('Verstanden'));
        await settle(tester);

        expect(fakeDataEntry.getActiveProfile()?.id, 'profil-1111-2222-3333');
      },
    );

    testWidgets('helle Profilfarbe hält Reset-Handlung lesbar', (tester) async {
      profile = profile.copyWith(preferredColor: Colors.white);
      fakeDataEntry.nextOutcome = ResetLoginOutcome.cancelled;

      await pumpDialogAndLogin(tester, 'altespasswort');

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Verstanden'),
      );
      expect(
        button.style?.foregroundColor?.resolve(<WidgetState>{}),
        AppColors.onColor(Colors.white),
      );
    });

    testWidgets(
      'activated: Aktivierungshinweis sichtbar, danach Profil aktiv',
      (tester) async {
        fakeDataEntry.nextOutcome = ResetLoginOutcome.activated;

        await pumpDialogAndLogin(tester, 'neuespasswort');

        expect(find.text('Neues Passwort aktiv'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outlined), findsOneWidget);

        await tester.tap(find.text('Verstanden'));
        await settle(tester);

        expect(fakeDataEntry.getActiveProfile()?.id, 'profil-1111-2222-3333');
      },
    );

    testWidgets('none: keinerlei Reset-UI, Profil direkt aktiv', (
      tester,
    ) async {
      fakeDataEntry.nextOutcome = ResetLoginOutcome.none;

      await pumpDialogAndLogin(tester, 'richtig');

      expect(find.text('Zurücksetzen abgebrochen'), findsNothing);
      expect(find.text('Neues Passwort aktiv'), findsNothing);
      expect(fakeDataEntry.getActiveProfile()?.id, 'profil-1111-2222-3333');
    });

    testWidgets('wrongPassword: kein Dialog, kein Profilwechsel', (
      tester,
    ) async {
      fakeDataEntry.nextOutcome = ResetLoginOutcome.wrongPassword;

      await pumpDialogAndLogin(tester, 'falsch');

      expect(find.text('Zurücksetzen abgebrochen'), findsNothing);
      expect(find.text('Neues Passwort aktiv'), findsNothing);
      expect(fakeDataEntry.getActiveProfile(), isNull);
    });
  });
}
