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

    testWidgets('erster Schritt des Ankers zeigt das heutige Datum',
        (tester) async {
      await tester.pumpWidget(
        _app(ExercisePlayerScreen(exercise: GroundingExercises.anchor)),
      );
      await tester.pumpAndSettle();

      final year = DateTime.now().year.toString();
      expect(find.textContaining(year), findsOneWidget);
    });

    testWidgets('Tippen auf die Flaeche geht einen Schritt weiter',
        (tester) async {
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

    testWidgets('der letzte Schritt fuehrt zur Abschluss-Leiter',
        (tester) async {
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
      // Die Atemuebung hat auf Schritt 1 ein hold von vier Sekunden.
      final breath =
          GroundingExercises.all.firstWhere((e) => e.id == 'breath');

      await tester.pumpWidget(_app(ExercisePlayerScreen(exercise: breath)));
      await tester.pumpAndSettle();

      // Sofort tippen, ohne die vier Sekunden abzuwarten.
      await tester.tap(find.byKey(const ValueKey('grounding-step-surface')));
      await tester.pumpAndSettle();

      final dots = tester.widget<ProgressDots>(find.byType(ProgressDots));
      expect(dots.active, 2);
    });
  });
}
