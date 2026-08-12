import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Samsung A14: 1080x2408 bei 450 dpi.
const geraetA14 = (size: Size(1080, 2408), ratio: 2.4);

/// Samsung S24: 1080x2340 bei 480 dpi.
const geraetS24 = (size: Size(1080, 2340), ratio: 3.0);

/// Baut [kind] unter festem Schriftfaktor und fester Gerätegröße.
///
/// Der Schriftfaktor kommt über `MediaQuery`, nicht über einen Theme-Umweg:
/// Genau so setzt Android die Systemschrift, und genau dort ist der Bruch
/// vom 10. August 2026 entstanden.
///
/// Der [settle]-Schalter ist ein Fluchtweg für Schirme, die kontinuierliche
/// Animationen (GPS-Karte, Echtzeit-Updates, etc.) haben und nie vollständig
/// „settle" würden: `settle: false` pumpt genau einen Frame statt `pumpAndSettle()`.
/// Nach einem Frame ist das Layout stabil genug zum Testen, während die
/// Animationen im Hintergrund weiterlaufen, ohne den Test zu blockieren.
Future<void> pumpScaled(
  WidgetTester tester,
  Widget kind, {
  double scale = 1.0,
  Size deviceSize = const Size(1080, 2340),
  double pixelRatio = 3.0,
  Locale locale = const Locale('de'),
  bool settle = true,
}) async {
  tester.view.physicalSize = deviceSize;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, kern) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: kern!,
      ),
      // Scaffold bietet den Material-Vorfahr, den InkWell und andere Ink-Widgets brauchen.
      // Es traegt keine sichtbare Padding hinzu; die Rechteckmessungen bleiben unbeeinträchtigt.
      home: Scaffold(body: kind),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// Das Bildschirmrechteck eines Elements.
Rect rectOf(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Die sichtbare Fläche in logischen Pixeln.
Rect sichtbareFlaeche(WidgetTester tester) =>
    Offset.zero & (tester.view.physicalSize / tester.view.devicePixelRatio);

/// Zwei Elemente dürfen sich nicht überdecken.
///
/// `Stack`-Layouts werfen keinen Overflow, wenn sie einander verdecken. Nur
/// der Rechteckvergleich sieht das.
void expectNoOverlap(WidgetTester tester, Finder a, Finder b) {
  final ra = rectOf(tester, a);
  final rb = rectOf(tester, b);
  expect(
    ra.overlaps(rb),
    isFalse,
    reason: 'Ueberlagerung: $ra schneidet $rb',
  );
}

/// Das Element liegt vollständig innerhalb des Bildschirms.
void expectFullyVisible(WidgetTester tester, Finder finder) {
  final r = rectOf(tester, finder);
  final schirm = sichtbareFlaeche(tester);
  final drin = r.left >= schirm.left - 0.5 &&
      r.top >= schirm.top - 0.5 &&
      r.right <= schirm.right + 0.5 &&
      r.bottom <= schirm.bottom + 0.5;
  expect(drin, isTrue, reason: 'Abgeschnitten: $r liegt nicht ganz in $schirm');
}

void _walk(SemanticsNode node, void Function(SemanticsNode) besuch) {
  besuch(node);
  node.visitChildren((kind) {
    _walk(kind, besuch);
    return true;
  });
}

/// Jeder klickbare Knoten trägt eine Beschriftung.
///
/// Ein leerer „Button" zwingt Vorlesehilfen zum Probieren. Das ist bei
/// wechselnden kognitiven Zuständen besonders teuer.
void expectNoUnlabeledTapTargets(WidgetTester tester) {
  final wurzel = tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
  expect(wurzel, isNotNull, reason: 'Kein Semantikbaum — ensureSemantics() vergessen?');

  final fehler = <String>[];
  _walk(wurzel!, (node) {
    final daten = node.getSemanticsData();
    if (daten.hasAction(SemanticsAction.tap) && daten.label.trim().isEmpty) {
      fehler.add('Knoten ${node.id} bei ${node.rect}');
    }
  });

  expect(
    fehler,
    isEmpty,
    reason: 'Klickbare Knoten ohne Beschriftung:\n${fehler.join('\n')}',
  );
}

/// Die Beschriftung des einen klickbaren Knotens, der [teil] enthält.
///
/// Schlägt fehl, wenn keiner oder mehrere passen — dann ist die Ansage
/// doppelt und der Test soll das sehen.
String labelOfTapTarget(WidgetTester tester, String teil) {
  final wurzel = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
  final treffer = <String>[];
  _walk(wurzel, (node) {
    final daten = node.getSemanticsData();
    if (daten.hasAction(SemanticsAction.tap) && daten.label.contains(teil)) {
      treffer.add(daten.label);
    }
  });
  expect(treffer, hasLength(1), reason: 'Erwartet genau einen klickbaren Knoten mit "$teil", gefunden: $treffer');
  return treffer.single;
}
