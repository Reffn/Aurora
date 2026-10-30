import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/anchor/anchor_action_bar.dart';
import 'package:dis_app/modules/anchor/anchor_header.dart';
import 'package:dis_app/modules/anchor/anchor_menu_screen.dart';
import 'package:dis_app/modules/anchor/anchor_row.dart';
import 'package:dis_app/modules/anchor/anker_kopfblock.dart';
import 'package:dis_app/widgets/time_map.dart';
import 'package:dis_app/widgets/today_overview_line.dart';
import 'package:dis_app/widgets/zeit_band.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/echte_schrift.dart';
import '../../support/text_scale_harness.dart';
import '../profile/profile_selection_test_setup.dart';

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
/// keine Fläche kennt. Die Zusage steht jetzt im Anker selbst: Block, erste
/// Überschrift und erste Reihe teilen sich die sichtbare Höhe, und nur der
/// Block gibt nach (seit 3.0.25; vorher eine feste Reserve, die bei großer
/// Schrift nicht mitwuchs). Diese Prüfung hält die Zusage fest, nicht die
/// Rechnung.
void main() {
  testWidgets('die erste Kachelreihe steht ohne Rollen ganz da', (
    tester,
  ) async {
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
          resetHinweis: zusatz == 0
              ? null
              : SizedBox(height: zusatz, width: 100),
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

    testWidgets('und auch dann, wenn jemand einen Nachbarn ergänzt', (
      tester,
    ) async {
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

  // Abnahme am Emulator, 3.0.25, Systemschrift 200 %: Von „Chat“ und
  // „Kalender“ standen nur die Symbole über der festen Leiste, die Wörter
  // lagen dahinter. Der Kopf war gewachsen (Band zweizeilig, Gruß, Knopf),
  // die Karte zeigte den Standorthinweis dreizeilig — und die Reserve für die
  // erste Reihe war eine feste Zahl, die bei großer Schrift nicht mitwuchs.
  //
  // Dieser Test baut den Anker so zusammen wie `main.dart`: Zeitband und
  // `AnchorHeader` als Kopf, der echte `AnkerKopfblock` mit der echten
  // Zeitkarte, darunter die Gruppen und die feste Leiste.
  //
  // Mit der echten Schrift (Roboto aus dem Flutter-Cache): Mit der
  // Testschrift liefe das Zeitband bei 200 % fünfzeilig statt zweizeilig,
  // und der Test prüfte einen Schirm, den es nicht gibt.
  group('zusammengesetzt wie in main.dart', () {
    setUpAll(ladeEchteSchrift);

    final lina = Profile.withColor(
      id: 'lina',
      name: 'Lina',
      preferredColor: Colors.pink,
      createdAt: DateTime(2026, 9, 1),
    );

    Widget anker() => Scaffold(
      appBar: AppBar(title: const Text('Aurora')),
      body: AnchorMenu(
        header: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: ZeitBand(jetzt: () => DateTime(2026, 9, 30, 21, 48)),
            ),
            AnchorHeader(profile: lina, onSwitchProfile: () {}),
          ],
        ),
        banner: (verfuegbar) => AnkerKopfblock(
          verfuegbar: verfuegbar,
          karteBauen: (platz) => TimeMap.fromServices(
            profile: lina,
            height: TimeMap.hoeheFuerBlock(platz),
          ),
          tagesUeberblick: TodayOverviewLine(
            profile: lina,
            gateByPermissions: false,
            countEventsForDay: (_) => 1,
            countMedicationsToday: () => 2,
          ),
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
            entries: [
              _eintrag('Chat'),
              _eintrag('Kalender'),
              _eintrag('Tagebuch'),
              _eintrag('Kontakte'),
            ],
          ),
        ],
      ),
    );

    for (final skala in [1.0, 2.0]) {
      for (final standort in [false, true]) {
        testWidgets('die erste Reihe steht ganz über der Leiste '
            '(A14, $skala, Standortrecht $standort)', (tester) async {
          await profilAufbau(mitStandortrecht: standort);
          await pumpScaled(
            tester,
            anker(),
            scale: skala,
            deviceSize: geraetA14.size,
            pixelRatio: geraetA14.ratio,
            settle: false,
          );
          await tester.pump(const Duration(milliseconds: 100));
          tester.takeException();

          // Über der Leiste und über dem Saum, in dem die Liste ausblendet
          // (24 dp) — ein Wort im Saum ist halb durchsichtig.
          final grenze = tester.getRect(find.byType(AnchorActionBar)).top - 24;
          for (final wort in ['Chat', 'Kalender']) {
            expect(
              tester.getRect(find.text(wort)).bottom,
              lessThanOrEqualTo(grenze + 0.5),
              reason: '„$wort“ liegt hinter der Leiste oder im Saum.',
            );
          }
        });
      }
    }
  });
}
