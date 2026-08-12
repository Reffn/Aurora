import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/profile_edit_screen.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Der Schutz ungespeicherter Profiländerungen.
///
/// Codex hat am 10. August belegt: Im Profil den Namen ändern und zurück
/// gehen verwirft die Änderung wortlos. Kalender, Medikamente, Tagebuch,
/// Kontakte und Finder fragen an derselben Stelle nach — das Profil war die
/// einzige Ausnahme.
///
/// Für Aurora zählt das doppelt: Ein Anteil kann eine Änderung beginnen,
/// unterbrochen werden und später nicht wissen, ob sie gespeichert wurde.
///
/// Geprüft werden **beide** Rückwege. Der sichtbare Pfeil rief früher
/// `Navigator.pop` unmittelbar auf und lief damit an jedem `PopScope` vorbei;
/// ein Test nur für Android-Zurück hätte das nicht bemerkt.
void main() {
  late Profile profil;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('profil_entwurf_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }

    final eventBus = EventBus();
    final profileService = ProfileService(eventBus);
    await profileService.openBoxes();
    final resetService = PasswordResetService(profileService, eventBus);
    final dataEntry = DataEntry(
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
    getIt.registerSingleton<DataEntry>(dataEntry);
    getIt.registerSingleton<PasswordResetService>(resetService);

    profil = Profile(
      id: 'profil-1111-2222-3333',
      nameRaw: 'Vorher',
      preferredColorValue: 0xFF3366CC,
      createdAt: DateTime(2026),
      age: 25,
    );
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows gibt die Datei manchmal verzögert frei. Für das Ergebnis
      // dieser Prüfung ist das ohne Belang.
    }
  });

  /// `pumpAndSettle` ist hier unbrauchbar: Im Bearbeitungsbaum läuft eine
  /// Animation, die nie zur Ruhe kommt, und die Prüfung liefe in einen
  /// Zeitablauf statt in ein Ergebnis. Getaktete Pumps genügen — geprüft wird
  /// der Zustand nach dem Übergang, nicht die Animation selbst.
  Future<void> beruhige(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Der Bildschirm liegt auf einer Route, damit ein Zurück überhaupt ein
  /// Ziel hat — sonst schluckt Flutter den Pop wirkungslos.
  Future<void> zeigeBearbeitung(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProfileEditScreen(profile: profil),
                  ),
                ),
                child: const Text('oeffnen'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('oeffnen'));
    await beruhige(tester);
  }

  Future<void> aendereNamen(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).first, 'Nachher');
    await beruhige(tester);
  }

  testWidgets('Der sichtbare Pfeil fragt nach, wenn etwas geändert wurde',
      (tester) async {
    await zeigeBearbeitung(tester);
    await aendereNamen(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await beruhige(tester);

    expect(
      find.byType(AlertDialog),
      findsOneWidget,
      reason: 'Ohne Rückfrage wäre der geänderte Name lautlos verloren.',
    );
    expect(find.byType(ProfileEditScreen), findsOneWidget);
  });

  testWidgets('Android-Zurück fragt genauso nach', (tester) async {
    await zeigeBearbeitung(tester);
    await aendereNamen(tester);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    await navigator.maybePop();
    await beruhige(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(ProfileEditScreen), findsOneWidget);
  });

  testWidgets('Ohne Änderung geht der Pfeil ohne Rückfrage zurück',
      (tester) async {
    await zeigeBearbeitung(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await beruhige(tester);

    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.byType(ProfileEditScreen),
      findsNothing,
      reason: 'Wer nichts geändert hat, soll nicht gefragt werden.',
    );
  });

  testWidgets('Der Zurück-Pfeil trägt einen Namen', (tester) async {
    await zeigeBearbeitung(tester);

    expect(
      find.byTooltip('Zurück'),
      findsOneWidget,
      reason: 'Android meldete den Pfeil bisher als unbeschrifteten Button.',
    );
  });
}
