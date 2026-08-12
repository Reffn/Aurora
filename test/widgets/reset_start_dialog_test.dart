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
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Tests für den Reset-Start-Dialog (Unit 4).
///
/// Geprüft wird die Oberfläche: Warnung vor der Eingabe, Abbruch schreibt
/// nichts, ungleiche Passwörter starten nichts, laufender Reset warnt vor
/// dem Neubeginn der Frist. Die Zustandslogik prüft
/// test/services/password_reset_service_test.dart.
///
/// DataEntry ist gefaked — echte Hive-Schreibvorgänge completen in der
/// FakeAsync-Zone von testWidgets nicht.
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

  final List<String> gestarteteResets = [];
  Profile? profil;

  @override
  Future<bool> startPasswordReset(
    String profileId,
    String newPassword, {
    String source = 'UI',
  }) async {
    gestarteteResets.add(newPassword);
    return true;
  }

  @override
  Profile? getProfileById(String profileId) => profil;

  @override
  Profile? getActiveProfile() => null;
}

void main() {
  late _FakeDataEntry fakeDataEntry;
  late Directory tempDir;

  Profile machProfil({String? passwortHash, bool mitLaufendemReset = false}) {
    final jetzt = DateTime.now();
    return Profile(
      id: 'profil-1111-2222-3333',
      nameRaw: 'TestProfil',
      preferredColorValue: 0xFF0000,
      createdAt: jetzt,
      passwordHash: passwortHash,
      resetStartedAt: mitLaufendemReset ? jetzt : null,
      resetEndsAt:
          mitLaufendemReset ? jetzt.add(const Duration(hours: 24)) : null,
      pendingPasswordHash: mitLaufendemReset ? 'pending-hash' : null,
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('reset_start_dialog_test_');
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

    await getIt.reset();
    getIt.registerSingleton<DataEntry>(fakeDataEntry);
    getIt.registerSingleton<PasswordResetService>(resetService);
    getIt.registerSingleton<ProfileService>(profileService);
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } on FileSystemException {
      // Windows-Lock — das Betriebssystem räumt auf
    }
  });

  /// Feste Pumps: der Avatar-Glow animiert dauerhaft, pumpAndSettle
  /// käme nie zurück.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> oeffneDialog(WidgetTester tester, Profile profile) async {
    fakeDataEntry.profil = profile;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => ProfileActionsDialog.show(context, profile),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);
  }

  group('Reset-Start-Dialog (Unit 4)', () {
    testWidgets('Profil ohne Passwort bietet keinen Reset-Einstieg an',
        (tester) async {
      await oeffneDialog(tester, machProfil());

      expect(find.text('Passwort vergessen?'), findsNothing);
    });

    testWidgets('Start-Dialog warnt vor der Passworteingabe', (tester) async {
      await oeffneDialog(tester, machProfil(passwortHash: 'hash'));

      await tester.tap(find.text('Passwort vergessen?'));
      await settle(tester);

      // Warnzeichen und Eingabefelder liegen im selben Dialog, die
      // Bestätigung ist ein eigener Schritt.
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Reset starten'), findsOneWidget);
      expect(fakeDataEntry.gestarteteResets, isEmpty);
    });

    testWidgets('Abbruch schreibt nichts', (tester) async {
      await oeffneDialog(tester, machProfil(passwortHash: 'hash'));

      await tester.tap(find.text('Passwort vergessen?'));
      await settle(tester);

      // Feld 0 gehört dem Login des Hauptdialogs — der Start-Dialog liegt
      // darüber und bringt seine beiden eigenen Felder mit.
      await tester.enterText(find.byType(TextField).at(1), 'neuespasswort');
      await tester.enterText(find.byType(TextField).at(2), 'neuespasswort');
      await settle(tester);

      await tester.tap(find.text('Abbrechen').last);
      await settle(tester);

      expect(fakeDataEntry.gestarteteResets, isEmpty);
    });

    testWidgets('Ungleiche Wiederholung startet keinen Reset', (tester) async {
      await oeffneDialog(tester, machProfil(passwortHash: 'hash'));

      await tester.tap(find.text('Passwort vergessen?'));
      await settle(tester);

      // Feld 0 gehört dem Login des Hauptdialogs — der Start-Dialog liegt
      // darüber und bringt seine beiden eigenen Felder mit.
      await tester.enterText(find.byType(TextField).at(1), 'neuespasswort');
      await tester.enterText(find.byType(TextField).at(2), 'tippfehler');
      await settle(tester);

      await tester.tap(find.text('Reset starten'));
      await settle(tester);

      expect(fakeDataEntry.gestarteteResets, isEmpty);
    });

    testWidgets('Bestätigter Start meldet das neue Passwort an DataEntry',
        (tester) async {
      await oeffneDialog(tester, machProfil(passwortHash: 'hash'));

      await tester.tap(find.text('Passwort vergessen?'));
      await settle(tester);

      // Feld 0 gehört dem Login des Hauptdialogs — der Start-Dialog liegt
      // darüber und bringt seine beiden eigenen Felder mit.
      await tester.enterText(find.byType(TextField).at(1), 'neuespasswort');
      await tester.enterText(find.byType(TextField).at(2), 'neuespasswort');
      await settle(tester);

      await tester.tap(find.text('Reset starten'));
      await settle(tester);

      expect(fakeDataEntry.gestarteteResets, ['neuespasswort']);
    });

    testWidgets('Laufender Reset zeigt Zustand mit Hinweis auf Neubeginn',
        (tester) async {
      await oeffneDialog(
        tester,
        machProfil(passwortHash: 'hash', mitLaufendemReset: true),
      );

      await tester.tap(find.byIcon(Icons.hourglass_top).last);
      await settle(tester);

      expect(find.text('Erneut starten'), findsOneWidget);
      expect(fakeDataEntry.gestarteteResets, isEmpty);
    });

    // Am 12.08.2026 am A14 gemeldet: In diesen Feldern lässt sich nichts
    // eintippen. Der Bedienbaum des Geräts trug 24 Knoten und kein einziges
    // `EditText`; die Felder wurden gezeichnet, aber es gab sie nicht.
    //
    // Die fünf Tests darüber sind trotzdem grün, weil `tester.enterText` den
    // Text unmittelbar am Widget setzt — ohne Griff, ohne Fokus, ohne
    // Tastatur. Was sie prüfen, ist die Logik hinter dem Feld, nie seine
    // Erreichbarkeit.
    testWidgets('ein Griff auf das Feld gibt ihm den Fokus', (tester) async {
      await oeffneDialog(tester, machProfil(passwortHash: 'hash'));
      await tester.tap(find.text('Passwort vergessen?'));
      await settle(tester);

      final feld = find.byType(TextField).at(1);
      await tester.tap(feld);
      await settle(tester);

      final schreibfeld = tester.widget<EditableText>(
        find.descendant(of: feld, matching: find.byType(EditableText)),
      );
      expect(
        schreibfeld.focusNode.hasFocus,
        isTrue,
        reason: 'Ohne Fokus bleibt die Tastatur weg und das Feld ist tot.',
      );
    });

    testWidgets('das Feld kündigt sich dem System als Eingabe an',
        (tester) async {
      await oeffneDialog(tester, machProfil(passwortHash: 'hash'));
      await tester.tap(find.text('Passwort vergessen?'));
      await settle(tester);

      final handle = tester.ensureSemantics();
      // Auf den Schreibkern zeigen, nicht auf das `TextField`: Dessen
      // Semantik-Knoten ist der Scroll-Container darum herum.
      final knoten = tester.getSemantics(
        find.descendant(
          of: find.byType(TextField).at(1),
          matching: find.byType(EditableText),
        ),
      );

      expect(knoten.hasFlag(SemanticsFlag.isTextField), isTrue);
      expect(knoten.hasFlag(SemanticsFlag.isEnabled), isTrue);
      expect(
        knoten.hasFlag(SemanticsFlag.isObscured),
        isTrue,
        reason: 'Ein Passwortfeld, das sich nicht als verdeckt ankündigt, '
            'liest ein Screenreader laut vor.',
      );
      handle.dispose();
    });
  });
}
