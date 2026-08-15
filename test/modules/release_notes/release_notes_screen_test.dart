import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/release_notes/release_notes_screen.dart';
import 'package:dis_app/services/release_notes_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Das Gate liegt im Arbeitsspeicher statt in Hive: Echte Datei-Ein-/Ausgabe
/// blockiert in einem Widget-Test — derselbe Grund wie beim
/// Einwilligungs-Schirm.
///
/// Der Weg zum Feedback wird hier bewusst nur bis zum Vermerk geprüft und
/// nicht bis in den geöffneten Schirm: `FeedbackScreen` holt sich seinen
/// Versender aus GetIt, und ein Test, der dafür erst den ganzen Container
/// aufsetzt, prüft am Ende den Aufbau statt die Sache.
void main() {
  late ReleaseNotesGate gate;

  setUp(() {
    gate = ReleaseNotesGate.inMemory(
      currentVersion: '3.0.20',
      seenVersion: '3.0.19',
    );
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    VoidCallback? onDismissed,
    String? appVersion,
    Future<void> Function()? onOpenFeedback,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReleaseNotesScreen(
          gate: gate,
          onDismissed: onDismissed ?? () {},
          appVersion: appVersion,
          onOpenFeedback: onOpenFeedback,
        ),
      ),
    );
  }

  group('ReleaseNotesScreen', () {
    testWidgets('beide Wege tragen dieselbe Größe', (tester) async {
      await pumpScreen(tester);

      final feedback = tester.getSize(
        find.byKey(const Key('release_notes_feedback')),
      );
      final weiter = tester.getSize(
        find.byKey(const Key('release_notes_continue')),
      );

      expect(feedback, weiter);
    });

    testWidgets('jeder Knopf trägt Symbol und Wort', (tester) async {
      await pumpScreen(tester);

      for (final schluessel in const [
        Key('release_notes_feedback'),
        Key('release_notes_continue'),
      ]) {
        expect(
          find.descendant(
            of: find.byKey(schluessel),
            matching: find.byType(Icon),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(schluessel),
            matching: find.byType(Text),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('die Frage nach dem Fehlenden steht auf der Fläche', (
      tester,
    ) async {
      await pumpScreen(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('de'));

      expect(find.text(l10n.releaseNotesAsk), findsOneWidget);
      // Richtlinie 10: Es steht dort, was nach dem Schreiben passiert.
      expect(find.text(l10n.releaseNotesWhatHappens), findsOneWidget);
    });

    testWidgets('ohne Fassung steht keine Nummer da', (tester) async {
      await pumpScreen(tester);

      expect(find.textContaining('Aurora 3.0'), findsNothing);
    });

    testWidgets('mit Fassung steht die Nummer da', (tester) async {
      await pumpScreen(tester, appVersion: '3.0.20');

      expect(find.text('Aurora 3.0.20'), findsOneWidget);
    });

    testWidgets('„Weiter" vermerkt die Fassung und meldet zurück', (
      tester,
    ) async {
      var gemeldet = false;
      await pumpScreen(tester, onDismissed: () => gemeldet = true);

      expect(gate.needsShowing, isTrue);

      await tester.tap(find.byKey(const Key('release_notes_continue')));
      await tester.pump();

      expect(gate.needsShowing, isFalse);
      expect(gemeldet, isTrue);
    });

    testWidgets('der Weg zum Feedback vermerkt die Fassung ebenfalls', (
      tester,
    ) async {
      // Sonst stünde der Schirm nach der Rückkehr aus dem Formular erneut da.
      // Geprüft wird die Reihenfolge: Beim Öffnen muss der Vermerk schon
      // liegen, nicht erst danach.
      var gemeldet = false;
      var offenMitVermerk = false;
      await pumpScreen(
        tester,
        onDismissed: () => gemeldet = true,
        onOpenFeedback: () async => offenMitVermerk = !gate.needsShowing,
      );

      await tester.tap(find.byKey(const Key('release_notes_feedback')));
      await tester.pump();

      expect(offenMitVermerk, isTrue);
      expect(gate.needsShowing, isFalse);
      expect(gemeldet, isTrue);
    });
  });
}
