import 'package:dis_app/modules/anchor/anchor_menu_screen.dart';
import 'package:dis_app/modules/anchor/anchor_row.dart';
import 'package:dis_app/modules/anchor/anker_kopfblock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/text_scale_harness.dart';

AnchorEntry _eintrag(String label) => AnchorEntry(
      icon: Icons.circle,
      label: label,
      color: Colors.teal,
      onTap: () {},
    );

/// Der Anker mit einem Block, der seinen Platz voll ausschöpft.
///
/// Genau das tut der echte: Die Zeitkarte nimmt, was ihr der Anker zusagt.
/// Ein `SizedBox` in der zugesagten Höhe ist derselbe Fall, nur ohne Karten,
/// Dienste und Berechtigungen.
class _AnkerMitVollemBlock extends StatelessWidget {
  const _AnkerMitVollemBlock();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: AnchorMenu(
          banner: (verfuegbar) => SizedBox(height: verfuegbar),
          groups: [
            AnchorGroup(
              label: 'Sofort',
              emphasis: AnchorEmphasis.solid,
              entries: [
                _eintrag('Halt'),
                _eintrag('Notfall'),
                _eintrag('Hilfe'),
              ],
            ),
            AnchorGroup(
              label: 'Alltag',
              entries: [_eintrag('Chat'), _eintrag('Kalender')],
            ),
          ],
        ),
      );
}

/// Die erste Kachelreihe steht beim Öffnen ganz im Bild.
///
/// Am 11. August 2026 am S24 gesehen: „Chat" und „Kalender" zeigten ihre
/// Figur, das Wort darunter lag hinter der festen Leiste. Wer scrollt, sieht
/// beides — nur ist Scrollen genau das, was im schlechten Zustand nicht
/// passiert, und ein Bild ohne Wort ist die halbe Auskunft (Regel 5).
///
/// Ursache war eine feste 280 für die Zeitkarte, gesetzt an einer Stelle, die
/// keine Fläche kennt. Die Zusage steht jetzt im Anker selbst: Was er dem
/// Block zusagt, ist immer um [AnchorMenu.reserveFuerErsteReihe] kleiner als
/// seine Liste. Diese Prüfung hält die Zusage fest, nicht die Rechnung —
/// verschwindet der Deckel oder schrumpft die Reserve, fällt sie.
void main() {
  testWidgets('die erste Kachelreihe steht ohne Rollen ganz da',
      (tester) async {
    // 600 dp: Was vom S24 übrig bleibt, wenn Statusleiste, Kopfzeile und
    // Systemleiste ihren Teil genommen haben.
    await pumpScaled(
      tester,
      const Center(child: SizedBox(height: 600, child: _AnkerMitVollemBlock())),
      scale: 1,
      deviceSize: geraetS24.size,
      pixelRatio: geraetS24.ratio,
    );

    expectFullyVisible(tester, find.text('Chat'));
    expectFullyVisible(tester, find.text('Kalender'));
  });

  testWidgets('die drei Krisenwege bleiben davon unberührt', (tester) async {
    await pumpScaled(
      tester,
      const Center(child: SizedBox(height: 600, child: _AnkerMitVollemBlock())),
      scale: 1,
      deviceSize: geraetS24.size,
      pixelRatio: geraetS24.ratio,
    );

    expectFullyVisible(tester, find.text('Halt'));
    expectFullyVisible(tester, find.text('Notfall'));
    expectFullyVisible(tester, find.text('Hilfe'));
  });

  // Die beiden Prüfungen oben pumpen einen erfundenen Block, der genau das
  // nimmt, was ihm zugesagt wird. Sie halten damit die Zusage des Ankers fest
  // — aber nicht, ob ein echter Kopfblock sie einhält. Genau daran ist die
  // Reihe viermal gescheitert: Der Anker sagte richtig zu, der Block nahm
  // sich mehr.
  //
  // Diese Prüfungen pumpen den echten `AnkerKopfblock`.
  group('mit dem echten Kopfblock', () {
    Widget ankerMitKopfblock({double zusatz = 0}) => Scaffold(
          body: AnchorMenu(
            banner: (verfuegbar) => AnkerKopfblock(
              verfuegbar: verfuegbar,
              // `zusatz` steht für einen Nachbarn, den jemand später ergänzt
              // — so wie am 11. August der Telemetrie-Hinweis.
              resetHinweis:
                  zusatz == 0 ? null : SizedBox(height: zusatz, width: 100),
              // Eine gierige Karte: Sie nimmt alles bis zu ihrer Höchsthöhe.
              karteBauen: (platz) => SizedBox(
                height: platz.isFinite && platz < 280 ? platz : 280,
                width: 100,
              ),
              tagesUeberblick: const SizedBox(height: 50, width: 100),
            ),
            groups: [
              AnchorGroup(
                label: 'Sofort',
                emphasis: AnchorEmphasis.solid,
                entries: [
                  _eintrag('Halt'),
                  _eintrag('Notfall'),
                  _eintrag('Hilfe'),
                ],
              ),
              AnchorGroup(
                label: 'Alltag',
                entries: [_eintrag('Chat'), _eintrag('Kalender')],
              ),
            ],
          ),
        );

    testWidgets('die erste Reihe steht ganz da', (tester) async {
      await pumpScaled(
        tester,
        Center(child: SizedBox(height: 600, child: ankerMitKopfblock())),
        scale: 1,
        deviceSize: geraetS24.size,
        pixelRatio: geraetS24.ratio,
      );

      expectFullyVisible(tester, find.text('Chat'));
      expectFullyVisible(tester, find.text('Kalender'));
    });

    testWidgets('und auch dann, wenn jemand einen Nachbarn ergänzt',
        (tester) async {
      await pumpScaled(
        tester,
        Center(
          child: SizedBox(height: 600, child: ankerMitKopfblock(zusatz: 120)),
        ),
        scale: 1,
        deviceSize: geraetS24.size,
        pixelRatio: geraetS24.ratio,
      );

      expectFullyVisible(tester, find.text('Chat'));
      expectFullyVisible(tester, find.text('Kalender'));
    });
  });
}
