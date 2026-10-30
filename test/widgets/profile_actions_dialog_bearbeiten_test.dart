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
import 'package:dis_app/widgets/profile_actions_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Wer ein Profil bearbeiten darf, ohne sich erst anzumelden.
///
/// Rückmeldungen vom 23.08. und 03.09.2026: „I can't change the age of a
/// little that I entered wrong" und „can't wait until the edit button is
/// functional". Der Knopf beim langen Drücken sagte nur „folgt bald", und
/// im Dialog stand „Profil bearbeiten" allein für das gerade aktive Profil.
///
/// Ein Profil ohne Passwort schützt nichts — jeder kann sich mit einem Tipp
/// als es anmelden. Es darf also auch direkt bearbeitet werden. Mit
/// Passwort bleibt die Anmeldung davor.
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
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('dialog_bearbeiten_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }

    final eventBus = EventBus();
    final profileService = ProfileService(eventBus);
    await profileService.openBoxes();
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
    fakeDataEntry.fakeSettingsBox = profileService.settingsBox;

    await getIt.reset();
    getIt.registerSingleton<DataEntry>(fakeDataEntry);
    getIt.registerSingleton<PasswordResetService>(resetService);
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

  Future<void> dialogOeffnen(WidgetTester tester, Profile profil) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => ProfileActionsDialog.show(context, profil),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    // Feste Pumps statt pumpAndSettle — der Avatar-Glow animiert dauerhaft.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Profile kleine({String? passwort, String? sprache}) => Profile(
    id: 'kleine-1111-2222-3333',
    nameRaw: 'Kleine',
    preferredColorValue: 0xFF0000,
    createdAt: DateTime.now(),
    age: 7,
    passwordHash: passwort,
    preferredLanguage: sprache,
  );

  // Der Sprachknopf nennt den Anteil. Am Gerät stand dort nur „Deutsch",
  // und das las sich wie die Sprache der ganzen App — während der Schirm
  // dahinter Englisch sprach (App en, Anteil de).
  testWidgets('der Sprachknopf sagt, wessen Sprache gemeint ist', (
    tester,
  ) async {
    await dialogOeffnen(tester, kleine(sprache: 'de'));
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));

    expect(
      find.text(l10n.profileLanguageOf('Kleine', 'Deutsch')),
      findsOneWidget,
    );
    expect(find.text('Deutsch'), findsNothing);
  });

  testWidgets('ohne eigene Sprache sagt der Knopf: wie die App', (
    tester,
  ) async {
    await dialogOeffnen(tester, kleine());
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));

    expect(find.text(l10n.profileLanguageOfApp('Kleine')), findsOneWidget);
    expect(find.text(l10n.languageFollowApp), findsNothing);
  });

  testWidgets('ohne Passwort: bearbeiten geht, ohne erst anzumelden', (
    tester,
  ) async {
    await dialogOeffnen(tester, kleine());
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));

    expect(find.text(l10n.menuProfileEdit), findsOneWidget);
  });

  testWidgets('mit Passwort: erst anmelden, kein Bearbeiten davor', (
    tester,
  ) async {
    await dialogOeffnen(tester, kleine(passwort: 'egal'));
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));

    expect(find.text(l10n.menuProfileEdit), findsNothing);
  });
}
