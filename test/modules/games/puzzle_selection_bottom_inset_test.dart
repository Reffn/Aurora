import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/games/puzzle_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Startknopf der Puzzle-Auswahl und die Android-Navigationsleiste.
///
/// Codex hat am 10. August auf einem A14 gemessen: Am maximalen Scrollende
/// reichte „Bild auswählen & starten" bis y=2341, während die
/// Navigationsleiste bereits bei y≈2273 beginnt. Der Knopf lag also unter der
/// Systemfläche und ließ sich nicht mehr vollständig treffen — weiteres
/// Scrollen half nicht, weil das Ende erreicht war.
///
/// Ein Overflow entsteht dabei nicht: Die Fläche rollt, sie ist nur zu kurz.
/// Deshalb greift `expect(tester.takeException(), isNull)` hier nicht, und
/// deshalb muss die Geometrie selbst geprüft werden.
void main() {
  /// Höhe der Android-Navigationsleiste in logischen Pixeln. Die
  /// Drei-Tasten-Navigation ist der ungünstigere Fall; die Gestenleiste ist
  /// flacher.
  const systemleiste = 48.0;

  Future<void> zeigeAuswahl(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Builder(
          builder: (context) => MediaQuery(
            // Nur die Systemfläche setzen, alles andere behalten: Ein
            // vollständig neues MediaQueryData hätte auch die Bildschirmgröße
            // auf null gesetzt.
            data: MediaQuery.of(context).copyWith(
              viewPadding: const EdgeInsets.only(bottom: systemleiste),
              padding: const EdgeInsets.only(bottom: systemleiste),
            ),
            child: const PuzzleSelectionScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Bis zum Anschlag rollen. Mehrfach, weil ein einzelner Zug bei langen
  /// Flächen nicht bis ans Ende reicht.
  Future<void> rolleAnsEnde(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Der Startknopf bleibt über der Systemleiste', (tester) async {
    await zeigeAuswahl(tester);
    await rolleAnsEnde(tester);

    final knopf = tester.getRect(find.byType(ElevatedButton).last);
    final schirmhoehe = tester.view.physicalSize.height /
        tester.view.devicePixelRatio;

    expect(
      knopf.bottom,
      lessThanOrEqualTo(schirmhoehe - systemleiste),
      reason:
          'Der Startknopf endet bei ${knopf.bottom}, die Systemleiste beginnt '
          'bei ${schirmhoehe - systemleiste}. Am Scrollende ist er damit '
          'teilweise verdeckt und nicht mehr verlässlich zu treffen.',
    );
  });

  testWidgets('Auch bei 200 % Schrift bleibt er erreichbar', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await zeigeAuswahl(tester);
    await rolleAnsEnde(tester);

    final knopf = tester.getRect(find.byType(ElevatedButton).last);
    final schirmhoehe = tester.view.physicalSize.height /
        tester.view.devicePixelRatio;

    expect(knopf.bottom, lessThanOrEqualTo(schirmhoehe - systemleiste));
  });
}
