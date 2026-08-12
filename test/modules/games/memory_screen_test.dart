import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/games/memory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';

void main() {
  Future<void> zeige(WidgetTester tester) async {
    // Echte Gerätemaße. Auf der Voreinstellung von 800×600 baut das Raster
    // nur sieben Karten — es baut faul, und eine fehlende Karte wäre dort
    // kein Befund, sondern eine Eigenschaft des Testfensters.
    tester.view.physicalSize = geraetS24.size;
    tester.view.devicePixelRatio = geraetS24.ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('de')],
        home: Scaffold(body: MemoryTisch()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('zwölf Karten liegen verdeckt auf dem Tisch', (tester) async {
    await zeige(tester);

    // Die Rückseiten, nicht alle Tippflächen — der Knopf für eine neue Runde
    // ist auch eine.
    expect(find.byIcon(Icons.help_outline), findsNWidgets(12));
  });

  testWidgets('zu Beginn ist kein Motiv zu sehen', (tester) async {
    await zeige(tester);

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('ein Griff deckt genau eine Karte auf', (tester) async {
    await zeige(tester);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('eine aufgedeckte Karte dreht sich nicht von selbst zurück',
      (tester) async {
    await zeige(tester);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    // Zehn Sekunden ohne Zutun. Ein übliches Memory hätte hier längst
    // umgedreht — diese Fläche verspricht wörtlich „keine Timer", und wer
    // langsam erkennt, braucht die Zeit.
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('der Weg zu einer neuen Runde steht von Anfang an da',
      (tester) async {
    await zeige(tester);

    // Nicht erst am Ende: Wer mittendrin aufhören will, braucht einen
    // Ausgang, ohne das Spiel zu Ende bringen zu müssen.
    expect(find.text('Neues Spiel'), findsOneWidget);
  });

  testWidgets('vor dem Ende steht kein Schlusssatz', (tester) async {
    await zeige(tester);

    expect(find.text('Alle Paare liegen.'), findsNothing);
  });

  testWidgets('jede Karte sagt, wo sie liegt und wie sie liegt',
      (tester) async {
    await zeige(tester);

    expect(find.bySemanticsLabel('Karte 1 von 12'), findsOneWidget);
    expect(find.bySemanticsLabel('Karte 12 von 12'), findsOneWidget);
  });
}
