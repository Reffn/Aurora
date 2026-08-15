import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/exercise_player_screen.dart';
import 'package:dis_app/modules/grounding/grounding_screen.dart';
import 'package:dis_app/modules/grounding/widgets/anchor_button.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_tile.dart';
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
  group('GroundingScreen', () {
    testWidgets('zeigt den grossen Knopf und vier Kacheln', (tester) async {
      await tester.pumpWidget(_app(const GroundingBody()));
      await tester.pumpAndSettle();

      expect(find.byType(AnchorButton), findsOneWidget);
      expect(find.byType(ExerciseTile), findsNWidgets(4));
    });

    testWidgets('der Anker startet die Orientierungsuebung', (tester) async {
      await tester.pumpWidget(_app(const GroundingBody()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AnchorButton));
      await tester.pumpAndSettle();

      final player = tester.widget<ExercisePlayerScreen>(
        find.byType(ExercisePlayerScreen),
      );
      expect(player.exercise.id, 'orientation');
    });

    testWidgets('eine Kachel startet ihre eigene Uebung', (tester) async {
      await tester.pumpWidget(_app(const GroundingBody()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('grounding-tile-breath')));
      await tester.pumpAndSettle();

      final player = tester.widget<ExercisePlayerScreen>(
        find.byType(ExercisePlayerScreen),
      );
      expect(player.exercise.id, 'breath');
    });

    testWidgets('der Bildschirm-Inhalt fragt kein Profil ab',
        (tester) async {
      // Der Body ist nicht rechtegesteuert. Nur der Body wird getestet,
      // nicht die StandardAppBar. Der Body rendert komplett ohne Services.
      await tester.pumpWidget(_app(const GroundingBody()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AnchorButton), findsOneWidget);
      expect(find.byType(ExerciseTile), findsNWidgets(4));
    });
  });
}
