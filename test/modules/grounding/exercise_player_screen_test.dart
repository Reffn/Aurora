import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/exercise_player_screen.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_done_sheet.dart';
import 'package:dis_app/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('de'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  group('ExercisePlayerScreen', () {
    testWidgets('startet beim ersten Schritt', (tester) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      final dots = tester.widget<ProgressDots>(find.byType(ProgressDots));
      expect(dots.active, 1);
      expect(dots.total, GroundingExercises.anchor.steps.length);
    });

    testWidgets('erster Schritt des Ankers zeigt das heutige Datum', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      final year = DateTime.now().year.toString();
      expect(find.textContaining(year), findsOneWidget);
    });

    testWidgets('jeder Schritt zeigt sein eigenes Symbol im Kreis der Übung', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      final bild = find.byKey(const ValueKey('grounding-bild'));
      expect(
        find.descendant(of: bild, matching: find.byIcon(Icons.calendar_today)),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: bild, matching: find.byIcon(Icons.visibility)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: bild,
          matching: find.byIcon(GroundingExercises.anchor.icon),
        ),
        findsNothing,
        reason: 'nicht mehr das Übungssymbol auf jedem Schritt',
      );
    });

    // Am Gerät: Bild und Text sprangen je Schritt auf und ab, weil ein
    // zweizeiliger Satz das mittig gesetzte Bild nach oben schob. Der
    // Textbereich hat jetzt eine feste Höhe für drei Zeilen.
    testWidgets(
      'das Bild bleibt stehen, ob der Satz ein- oder zweizeilig ist',
      (tester) async {
        final l10n = await AppLocalizations.delegate.load(const Locale('de'));
        await tester.pumpWidget(
          _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
        );
        await tester.pumpAndSettle();

        Future<void> weiter() async {
          await tester.tap(
            find.byKey(const ValueKey('grounding-step-surface')),
          );
          await tester.pumpAndSettle();
        }

        // Schritt 4: „Der Körper von heute ist nicht der von damals.“
        for (var i = 0; i < 3; i++) {
          await weiter();
        }
        final langerSatz = tester.getSize(
          find.text(l10n.groundingOrientationStep4),
        );
        final bildBeiLang = tester.getCenter(
          find.byKey(const ValueKey('grounding-bild')),
        );

        // Schritt 6: „Du bist hier.“
        await weiter();
        await weiter();
        final kurzerSatz = tester.getSize(
          find.text(l10n.groundingOrientationStep6),
        );
        final bildBeiKurz = tester.getCenter(
          find.byKey(const ValueKey('grounding-bild')),
        );

        expect(
          langerSatz.height,
          greaterThan(kurzerSatz.height),
          reason: 'Die Probe braucht einen zwei- und einen einzeiligen Satz.',
        );
        expect(bildBeiKurz, bildBeiLang);
      },
    );

    testWidgets('Tippen auf die Flaeche geht einen Schritt weiter', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
      await tester.pumpAndSettle();

      final dots = tester.widget<ProgressDots>(find.byType(ProgressDots));
      expect(dots.active, 2);
    });

    testWidgets('Zurueck ist auf jedem Schritt erreichbar', (tester) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < GroundingExercises.anchor.steps.length - 1; i++) {
        expect(
          find.byKey(const ValueKey('grounding-back')),
          findsOneWidget,
          reason: 'Zurueck fehlt bei Schritt $i',
        );
        await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('der letzte Schritt fuehrt zur Abschluss-Leiter', (
      tester,
    ) async {
      final exercise = GroundingExercises.anchor;
      await tester.pumpWidget(_app(ExercisePlayerScreen(exercise: exercise)));
      await tester.pumpAndSettle();

      for (var i = 0; i < exercise.steps.length; i++) {
        await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
        await tester.pumpAndSettle();
      }

      expect(find.byType(ExerciseDoneSheet), findsOneWidget);
    });

    testWidgets('hold blockiert das Weitertippen nicht', (tester) async {
      // Die Körperübung hat auf Schritt 4 ein hold von zwanzig Sekunden.
      // (Die Atemübung taugt dafür seit 3.0.25 nicht mehr: Sie ist ein
      // durchgehender Takt, getippt wird dort gar nicht.)
      final body = GroundingExercises.all.firstWhere((e) => e.id == 'body');
      expect(body.steps[3].hold, const Duration(seconds: 20));

      await tester.pumpWidget(_app(ExercisePlayerScreen(exercise: body)));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
        await tester.pumpAndSettle();
      }
      expect(tester.widget<ProgressDots>(find.byType(ProgressDots)).active, 4);

      // Sofort tippen, ohne die zwanzig Sekunden abzuwarten.
      await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final dots = tester.widget<ProgressDots>(find.byType(ProgressDots));
      expect(dots.active, 5);
    });
  });

  /// Gerätebefund: Ein Schritt zeigte Bild, Satz und Punkte — und nichts,
  /// was den Weg weiter zeigt. Die Punkte legten Wischen nahe, Wischen tat
  /// nichts. Wer im dissoziativen Zustand nicht weiterkam, drückte Zurück:
  /// sieben Abbrüche auf drei Abschlüsse beim Hauptknopf.
  group('ExercisePlayerScreen – Weg nach vorn', () {
    int aktiverPunkt(WidgetTester tester) =>
        tester.widget<ProgressDots>(find.byType(ProgressDots)).active;

    testWidgets('Schritt 1 zeigt einen sichtbaren Weiter-Knopf mit Symbol', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      final weiter = find.byKey(const ValueKey('grounding-next'));
      expect(weiter, findsOneWidget);
      expect(
        find.descendant(of: weiter, matching: find.byType(Icon)),
        findsOneWidget,
      );
      expect(tester.getSize(weiter).height, greaterThanOrEqualTo(56));
    });

    testWidgets('der Hinweis-Puls kommt zur Ruhe und ruht in Normalgröße', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      // Ein Puls ohne Ende käme hier nie an. Ein Puls, der groß stehen
      // bleibt, wäre ein halb geschwollener Knopf.
      await tester.pumpAndSettle();

      final scale = tester.widget<ScaleTransition>(
        find.descendant(
          of: find.byKey(const ValueKey('grounding-next')),
          matching: find.byType(ScaleTransition),
        ),
      );
      expect(scale.scale.value, 1.0);
    });

    testWidgets('der Weiter-Knopf geht einen Schritt weiter', (tester) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('grounding-next')));
      await tester.pumpAndSettle();

      expect(aktiverPunkt(tester), 2);
    });

    testWidgets('Wischen nach links geht einen Schritt weiter', (tester) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey('grounding-step-surface')),
        const Offset(-300, 0),
      );
      await tester.pumpAndSettle();

      expect(aktiverPunkt(tester), 2);
    });

    testWidgets('Wischen nach rechts geht einen Schritt zurück', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
      await tester.pumpAndSettle();
      expect(aktiverPunkt(tester), 2);

      await tester.drag(
        find.byKey(const ValueKey('grounding-step-surface')),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      expect(aktiverPunkt(tester), 1);
    });

    testWidgets('Wischen nach rechts auf Schritt 1 verlässt die Übung nicht', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey('grounding-step-surface')),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExercisePlayerScreen), findsOneWidget);
      expect(aktiverPunkt(tester), 1);
    });

    testWidgets('auf dem letzten Schritt heißt der Knopf Fertig', (
      tester,
    ) async {
      final exercise = GroundingExercises.anchor;
      await tester.pumpWidget(_app(ExercisePlayerScreen(exercise: exercise)));
      await tester.pumpAndSettle();

      for (var i = 0; i < exercise.steps.length - 1; i++) {
        await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
        await tester.pumpAndSettle();
      }

      final weiter = find.byKey(const ValueKey('grounding-next'));
      expect(
        find.descendant(of: weiter, matching: find.text('Fertig')),
        findsOneWidget,
      );
      await tester.tap(weiter);
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseDoneSheet), findsOneWidget);
    });

    testWidgets('die Uhrzeit auf dem Orientierungsschritt läuft weiter', (
      tester,
    ) async {
      // Vorher stand `DateTime.now()` nur im build — wer eine Minute auf dem
      // ersten Schritt blieb, sah eine stehende Uhr.
      var jetzt = DateTime(2026, 10, 6, 19, 3);
      await tester.pumpWidget(
        _app(
          ExercisePlayerScreen(
            exercise: GroundingExercises.anchor,
            clock: () => jetzt,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('19:03'), findsOneWidget);

      jetzt = DateTime(2026, 10, 6, 19, 4);
      await tester.pump(const Duration(seconds: 2));

      expect(find.textContaining('19:04'), findsOneWidget);
    });
  });
}
