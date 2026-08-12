import 'package:dis_app/modules/anchor/anchor_menu_screen.dart';
import 'package:dis_app/modules/anchor/anchor_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';

AnchorEntry _eintrag(String label) => AnchorEntry(
      icon: Icons.circle,
      label: label,
      color: Colors.teal,
      onTap: () {},
    );

/// Der Prüfanker. Öffentlich, weil der Semantik-Inventartest aus Aufgabe 8
/// dieselbe Fläche verwendet.
Widget ankerFuerTest() => Scaffold(
      body: AnchorMenu(
        groups: [
          AnchorGroup(
            label: 'Sofort',
            emphasis: AnchorEmphasis.solid,
            entries: [_eintrag('Halt'), _eintrag('Notfall'), _eintrag('Hilfe')],
          ),
          AnchorGroup(
            label: 'Alltag',
            entries: [
              for (final l in ['Kontakte', 'Finder', 'Spiele', 'Zeitachse', 'Feedback'])
                _eintrag(l),
            ],
          ),
        ],
      ),
    );

/// Der Prüfanker als `const`-fähiges Widget, damit er in ein `SizedBox` mit
/// fester Höhe passt.
class _AnkerFlaeche extends StatelessWidget {
  const _AnkerFlaeche();

  @override
  Widget build(BuildContext context) => ankerFuerTest();
}

void main() {
  testWidgets('Die drei Krisenwege bleiben nach dem Rollen sichtbar', (tester) async {
    await pumpScaled(tester, ankerFuerTest(), scale: 1,
        deviceSize: geraetA14.size, pixelRatio: geraetA14.ratio);

    await tester.scrollUntilVisible(find.text('Feedback'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();

    expectFullyVisible(tester, find.text('Halt'));
    expectFullyVisible(tester, find.text('Notfall'));
    expectFullyVisible(tester, find.text('Hilfe'));
  });

  testWidgets('Die drei Krisenwege stehen ohne Rollen vollstaendig da',
      (tester) async {
    // 600 dp: Was vom S24 übrig bleibt, wenn Statusleiste, Kopfzeile und
    // Systemleiste ihren Teil genommen haben. Die Gerätehöhe (780) ist nicht
    // die Fläche, die der Anker hat — genau daran ist es gebrochen.
    await pumpScaled(
      tester,
      const Center(child: SizedBox(height: 600, child: _AnkerFlaeche())),
      scale: 1,
      deviceSize: geraetS24.size,
      pixelRatio: geraetS24.ratio,
    );

    // Geprüft wird die Zusage, nicht die Bauform. Wo die drei Wege sitzen —
    // fester Kopf, feste Leiste unten — darf sich ändern; dass sie ohne Geste
    // ganz dastehen, nicht. Am 11. August 2026 war „Hilfe" unten um 40 dp
    // angeschnitten und nur über ein Rollen erreichbar, das nichts ankündigt.
    // Deshalb `expectFullyVisible` und nicht „ist das Wort zu finden": Das Wort
    // sitzt in der Mitte der Fläche und war auch damals zu sehen.
    expectFullyVisible(tester, find.text('Halt'));
    expectFullyVisible(tester, find.text('Notfall'));
    expectFullyVisible(tester, find.text('Hilfe'));
  });

  testWidgets('Der feste Kopf frisst bei 200 % nicht die Liste', (tester) async {
    await pumpScaled(tester, ankerFuerTest(), scale: 2,
        deviceSize: geraetA14.size, pixelRatio: geraetA14.ratio);

    expectFullyVisible(tester, find.text('Halt'));
    // Der Rest bleibt erreichbar, auch wenn der Kopf gewachsen ist.
    await tester.scrollUntilVisible(find.text('Feedback'), 100,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    expectFullyVisible(tester, find.text('Feedback'));
  });
}
