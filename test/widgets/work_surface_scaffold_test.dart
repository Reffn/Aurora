import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:dis_app/widgets/work_surface_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Baut einen Anker mit einem Knopf, der eine Arbeitsfläche darüber legt —
/// derselbe Aufbau wie in der App, nur ohne deren Dienste.
///
/// Die Delegates gehoeren dazu: die Arbeitsflaeche beschriftet ihr
/// Ankersymbol aus der Sprache. Eine MaterialApp ohne sie waere ein anderer
/// Baum als der echte — genau der Unterschied, an dem der Splash zerbrach.
Widget _appWithWorkSurface({
  Widget? fab,
  Profile? profile,
  VoidCallback? onProfileTap,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WorkSurfaceScaffold(
                  title: 'Kalender',
                  profile: profile,
                  onProfileTap: onProfileTap,
                  fab: fab,
                  child: const Text('Inhalt'),
                ),
              ),
            ),
            child: const Text('Zum Kalender'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('WorkSurfaceScaffold', () {
    testWidgets('zeigt den Namen des Bereichs und seinen Inhalt',
        (tester) async {
      await tester.pumpWidget(_appWithWorkSurface());
      await tester.tap(find.text('Zum Kalender'));
      await tester.pumpAndSettle();

      expect(find.text('Kalender'), findsOneWidget);
      expect(find.text('Inhalt'), findsOneWidget);
    });

    testWidgets('das Ankersymbol führt zurück', (tester) async {
      await tester.pumpWidget(_appWithWorkSurface());
      await tester.tap(find.text('Zum Kalender'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.anchor));
      await tester.pumpAndSettle();

      expect(find.text('Inhalt'), findsNothing);
      expect(find.text('Zum Kalender'), findsOneWidget);
    });

    // Ein Weg, zwei Auslöser: Die Zurück-Taste nimmt dieselbe Seite vom
    // Stapel wie das Ankersymbol. Wäre das getrennt programmiert, könnten die
    // beiden auseinanderlaufen.
    testWidgets('die Zurück-Taste tut dasselbe wie das Ankersymbol',
        (tester) async {
      await tester.pumpWidget(_appWithWorkSurface());
      await tester.tap(find.text('Zum Kalender'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Inhalt'), findsNothing);
      expect(find.text('Zum Kalender'), findsOneWidget);
    });

    testWidgets('zeigt den Plus-Knopf des Bereichs, wenn es einen gibt',
        (tester) async {
      await tester.pumpWidget(
        _appWithWorkSurface(
          fab: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      );
      await tester.tap(find.text('Zum Kalender'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    // „Wer bin ich gerade?" muss auf der Arbeitsfläche beantwortet sein —
    // Amnesie nach einem Wechsel ist der Normalfall, und der Rückweg zum
    // Anker nur zum Nachsehen wäre ein Umweg im schlechtesten Moment.
    testWidgets('zeigt, wer gerade hier ist: Avatar und Name', (tester) async {
      final sofia = Profile(
        id: 'p1',
        nameRaw: 'Sofia',
        preferredColorValue: 0xFFAA66CC,
        createdAt: DateTime(2026),
      );
      await tester.pumpWidget(_appWithWorkSurface(profile: sofia));
      await tester.tap(find.text('Zum Kalender'));
      await tester.pumpAndSettle();

      expect(find.text('Kalender'), findsOneWidget);
      expect(find.text('Sofia'), findsOneWidget);
      expect(find.byType(ProfileImageWidget), findsOneWidget);
    });

    testWidgets('ohne Profil steht nur der Bereichsname', (tester) async {
      await tester.pumpWidget(_appWithWorkSurface());
      await tester.tap(find.text('Zum Kalender'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileImageWidget), findsNothing);
    });

    // Die Zeile sah aus wie ein Knopf und war keiner. Wer den Weg zum Profil
    // oder zu den Einstellungen sucht, greift genau dorthin — jetzt führt sie
    // auch hin, und zwar von jeder Arbeitsfläche aus.
    testWidgets('die Anteilszeile führt ins Profilmenü', (tester) async {
      final sofia = Profile(
        id: 'p1',
        nameRaw: 'Sofia',
        preferredColorValue: 0xFFAA66CC,
        createdAt: DateTime(2026),
      );
      var gegriffen = 0;
      await tester.pumpWidget(
        _appWithWorkSurface(
          profile: sofia,
          onProfileTap: () => gegriffen++,
        ),
      );
      await tester.tap(find.text('Zum Kalender'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.text('Sofia'));
      await tester.pumpAndSettle();

      expect(gegriffen, 1);
    });

    // Ohne Rückruf bleibt die Zeile reine Auskunft — dann darf sie auch
    // nicht wie ein Knopf aussehen.
    testWidgets('ohne Rückruf trägt die Anteilszeile kein Zahnrad',
        (tester) async {
      final sofia = Profile(
        id: 'p1',
        nameRaw: 'Sofia',
        preferredColorValue: 0xFFAA66CC,
        createdAt: DateTime(2026),
      );
      await tester.pumpWidget(_appWithWorkSurface(profile: sofia));
      await tester.tap(find.text('Zum Kalender'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsNothing);
    });

    testWidgets('ohne Plus-Knopf bleibt die Fläche leer', (tester) async {
      await tester.pumpWidget(_appWithWorkSurface());
      await tester.tap(find.text('Zum Kalender'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
