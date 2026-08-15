import 'package:dis_app/modules/anchor/anchor_action_bar.dart';
import 'package:dis_app/modules/anchor/anchor_menu_screen.dart';
import 'package:dis_app/modules/anchor/anchor_row.dart';
import 'package:dis_app/modules/anchor/anchor_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AnchorEntry _entry(String label, {VoidCallback? onTap}) {
  return AnchorEntry(
    icon: Icons.circle,
    label: label,
    color: Colors.teal,
    onTap: onTap ?? () {},
  );
}

AnchorGroup _group(
  String label,
  List<AnchorEntry> entries, {
  AnchorEmphasis emphasis = AnchorEmphasis.quiet,
}) {
  return AnchorGroup(label: label, entries: entries, emphasis: emphasis);
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Wie [_wrap], aber mit einer Systemleiste am unteren Rand.
///
/// Die Standard-Testfläche hat keine, also kann sie den Befund gar nicht
/// zeigen: Am Gerät lag die unterste Karte hinter den Navigationsknöpfen —
/// ausgerechnet „Hilfe".
Widget _wrapMitSystemleiste(Widget child, {double unten = 48}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      viewPadding: EdgeInsets.only(bottom: unten),
      padding: EdgeInsets.only(bottom: unten),
    ),
    child: Scaffold(body: child),
  ),
);

void main() {
  group('AnchorMenu', () {
    testWidgets('zeigt eine Kachel je ruhigem Eintrag', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group('Wenn es schwer ist', [_entry('Halt')]),
              _group('Alltag', [_entry('Chat'), _entry('Kalender')]),
            ],
          ),
        ),
      );

      expect(find.byType(AnchorTile), findsNWidgets(3));
      expect(find.text('Halt'), findsOneWidget);
      expect(find.text('Kalender'), findsOneWidget);
    });

    // Die drei Wege für den schlechtesten Zustand stehen nicht mehr in der
    // Liste, sondern in einer Leiste, die nicht scrollt. Vorher standen sie
    // oben — richtig, solange niemand gescrollt hatte.
    testWidgets('die laute Gruppe wandert in die feste Leiste', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group(
                'Wenn es schwer ist',
                [_entry('Halt'), _entry('Notfall'), _entry('Hilfe')],
                emphasis: AnchorEmphasis.solid,
              ),
              _group('Alltag', [_entry('Chat')]),
            ],
          ),
        ),
      );

      final leiste = tester.widget<AnchorActionBar>(
        find.byType(AnchorActionBar),
      );
      expect(
        leiste.actions.map((a) => a.label),
        ['Halt', 'Notfall', 'Hilfe'],
      );

      // Und nur der Alltag steht als Kachel in der Liste.
      expect(find.byType(AnchorTile), findsOneWidget);
    });

    testWidgets('zeigt die Überschrift jeder Gruppe', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group('Wenn es schwer ist', [_entry('Halt')]),
              _group('Alltag', [_entry('Chat')]),
            ],
          ),
        ),
      );

      // Normalschreibung, nicht Versalien: Großbuchstaben nehmen den Wörtern
      // die Umrissform und gelten für kognitiv belastete Leser als schwerer
      // (W3C COGA). Der Abstand trägt die Gruppe, nicht die Lautstärke.
      expect(find.text('Wenn es schwer ist'), findsOneWidget);
      expect(find.text('Alltag'), findsOneWidget);
      expect(find.text('WENN ES SCHWER IST'), findsNothing);
    });

    // Die Reihenfolge ist eine Zusage: Was gestern an dritter Stelle stand,
    // steht morgen an dritter Stelle. Eine Sortierung nach Nutzung wäre für
    // Menschen, die sich an Orte statt an Namen erinnern, ein Ortswechsel
    // ohne Vorwarnung.
    testWidgets('behält Reihenfolge der Gruppen und der Kacheln darin', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group('Wenn es schwer ist', [_entry('Halt'), _entry('Notfall')]),
              _group('Alltag', [_entry('Chat')]),
            ],
          ),
        ),
      );

      final kacheln = tester.widgetList<AnchorTile>(find.byType(AnchorTile));
      expect(kacheln.map((k) => k.label), ['Halt', 'Notfall', 'Chat']);
    });

    // Sättigung hat hier eine Aufgabe: Sie zeigt, was im schlechtesten Zustand
    // gefunden werden muss. Wäre alles farbig, zeigte sie nichts mehr.
    //
    // Seit dem Umbau trägt die Bauform selbst die Trennung: Was volle Farbe
    // hat, steht in der Leiste; was in der Liste steht, ist ruhig. Damit kann
    // eine laute Kachel gar nicht mehr entstehen.
    testWidgets('nur die Notgruppe trägt volle Farbe', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group(
                'Wenn es schwer ist',
                [_entry('Halt')],
                emphasis: AnchorEmphasis.solid,
              ),
              _group('Alltag', [_entry('Chat')]),
            ],
          ),
        ),
      );

      final leiste = tester.widget<AnchorActionBar>(
        find.byType(AnchorActionBar),
      );
      expect(leiste.actions.map((a) => a.label), ['Halt']);

      final kacheln = tester.widgetList<AnchorTile>(find.byType(AnchorTile));
      expect(kacheln.map((k) => k.label), ['Chat']);
    });

    testWidgets('eine Zeile antippen ruft ihre Handlung', (tester) async {
      var opened = '';

      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group('Alltag', [
                _entry('Halt', onTap: () => opened = 'Halt'),
                _entry('Chat', onTap: () => opened = 'Chat'),
              ]),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      expect(opened, 'Chat');
    });

    testWidgets('ohne Profil erscheint keine Profilkarte', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group('Alltag', [_entry('Chat')]),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.swap_horiz), findsNothing);
    });

    // Der aktive Anteil stand hier als Karte über den Gruppen und ist in die
    // Titelzeile gewandert: Dort bleibt er beim Scrollen sichtbar, und die
    // rund neunzig Punkte Höhe gehören jetzt der Zeitkarte. Der Test hält
    // fest, dass das Menü ihn nicht mehr trägt — sonst stünde er zweimal auf
    // demselben Schirm.
    testWidgets('trägt den aktiven Anteil nicht mehr selbst', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group('Alltag', [_entry('Chat')]),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.swap_horiz), findsNothing);
      expect(find.text('Mia'), findsNothing);
    });

    testWidgets('zeigt den übergebenen Hinweis über den Zeilen', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group('Alltag', [_entry('Chat')]),
            ],
            banner: (_) => const Text('Passwort zurücksetzen läuft'),
          ),
        ),
      );

      expect(find.text('Passwort zurücksetzen läuft'), findsOneWidget);
    });

    testWidgets('die Leiste bleibt über der Systemleiste', (tester) async {
      // Der Befund vom Geraetedurchlauf: Die letzte Karte lag hinter den
      // Navigationsknöpfen und war nicht antippbar. Es traf „Hilfe" — die
      // Zeile, die jemand sucht, der gerade nicht weiterweiß. Seit dem Umbau
      // steht dort die Leiste, also gilt der Befund für sie.
      tester.view
        ..physicalSize =
            const Size(1080, 2340) // Galaxy S24
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      const systemleiste = 48.0;
      await tester.pumpWidget(
        _wrapMitSystemleiste(
          AnchorMenu(
            groups: [
              _group(
                'Wenn es schwer ist',
                [_entry('Halt'), _entry('Notfall'), _entry('Hilfe')],
                emphasis: AnchorEmphasis.solid,
              ),
              _group('Alltag', [
                _entry('Chat'),
                _entry('Kalender'),
                _entry('Tagebuch'),
                _entry('Kontakte'),
                _entry('Medikamente'),
              ]),
              _group('Wenn Ruhe ist', [
                _entry('Spiele'),
                _entry('Finder'),
                _entry('Zeitachse'),
              ]),
            ],
          ),
        ),
      );

      final schirmhoehe =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;

      // Der Knopf, nicht die Leiste: Die Leiste trägt den Abstand als Polster
      // und darf bis an den Rand reichen. Antippbar sein muss der Knopf.
      final knopf = tester.getRect(find.text('Hilfe'));
      expect(knopf.bottom, lessThanOrEqualTo(schirmhoehe - systemleiste));
    });

    // Der eigentliche Grund für die Leiste. Vorher stand Halt oben in der
    // Liste — richtig nach Regel 9, aber weg, sobald jemand bis zum Tagebuch
    // gescrollt hatte. Genau dann wird es gebraucht.
    testWidgets('Halt bleibt erreichbar, auch ganz unten in der Liste', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      var geoeffnet = '';

      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group(
                'Wenn es schwer ist',
                [_entry('Halt', onTap: () => geoeffnet = 'Halt')],
                emphasis: AnchorEmphasis.solid,
              ),
              _group('Alltag', [
                for (final n in ['Chat', 'Kalender', 'Tagebuch', 'Kontakte'])
                  _entry(n),
              ]),
              _group('Wenn Ruhe ist', [
                for (final n in [
                  'Spiele',
                  'Finder',
                  'Zeitachse',
                  'Rückmeldung',
                ])
                  _entry(n),
              ]),
            ],
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Halt'));
      await tester.pumpAndSettle();

      expect(
        geoeffnet,
        'Halt',
        reason: 'Nach dem Scrollen muss Halt ohne Zurückscrollen gehen.',
      );
    });

    // Feste Höhen und große Schrift sind der klassische Overflow. WCAG 2.2
    // verlangt, dass Text bis 200 % vergrößerbar bleibt, ohne dass Inhalt
    // verloren geht — und wer diese App benutzt, hat oft gute Gründe dafür.
    testWidgets('bei 200 % Schrift läuft nichts über', (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: AnchorMenu(
                groups: [
                  _group(
                    'Wenn es schwer ist',
                    [_entry('Halt'), _entry('Notfall'), _entry('Hilfe')],
                    emphasis: AnchorEmphasis.solid,
                  ),
                  _group('Alltag', [
                    _entry('Medikamente'),
                    _entry('Kalender'),
                    _entry('Chat'),
                  ]),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Medikamente'), findsOneWidget);
    });

    testWidgets('Kachel und Knopf halten die Trefferfläche ein', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group(
                'Wenn es schwer ist',
                [_entry('Halt'), _entry('Notfall'), _entry('Hilfe')],
                emphasis: AnchorEmphasis.solid,
              ),
              _group('Alltag', [_entry('Chat'), _entry('Kalender')]),
            ],
          ),
        ),
      );

      // 110 dp, nicht die 24 aus WCAG 2.2: Die Norm sagt ausdrücklich „more
      // for unsteady hands", und unruhige Hände sind hier der Normalfall.
      expect(
        tester.getSize(find.byType(AnchorTile).first).height,
        greaterThanOrEqualTo(AnchorTile.minHeight),
      );
      expect(
        tester.getSize(find.byType(AnchorActionBar)).height,
        greaterThanOrEqualTo(AnchorActionBar.buttonHeight),
      );
    });

    // Der Befund vom A14: Der Kacheltext klebte in der linken oberen Ecke
    // statt mittig zu stehen. Der Streifen lag damals in einem `Stack`, und
    // der gab der Spalte lockere Constraints — sie schrumpfte auf ihre
    // Inhaltsbreite. Der Test davor verglich nur Positionen zueinander und
    // sah davon nichts.
    testWidgets('der Kachelinhalt steht mittig', (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          AnchorMenu(
            groups: [
              _group('Alltag', [_entry('Chat'), _entry('Kalender')]),
            ],
          ),
        ),
      );

      final kachel = tester.getRect(find.byType(AnchorTile).first);
      final wort = tester.getRect(find.text('Chat'));

      expect(
        wort.center.dx,
        closeTo(kachel.center.dx, 1),
        reason: 'Das Wort gehört in die Mitte der Kachel, nicht an den Rand.',
      );
    });

    // Bricht ein Wort um und das daneben nicht, streckt `IntrinsicHeight` die
    // kürzere Kachel. Der Streifen ist deshalb ein Rahmen und kein Kind — er
    // kann gar nicht mitrutschen. Der Test hält fest, dass beide Kacheln
    // einer gemischten Reihe gleich hoch bleiben und der Inhalt mittig steht.
    testWidgets('ungleiche Kacheln bleiben in Form', (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: AnchorMenu(
                groups: [
                  // Ein langes Wort neben einem kurzen: „Medikamente" bricht
                  // bei 200 % um, „Chat" nicht.
                  _group('Alltag', [_entry('Medikamente'), _entry('Chat')]),
                ],
              ),
            ),
          ),
        ),
      );

      final links = tester.getRect(find.byType(AnchorTile).at(0));
      final rechts = tester.getRect(find.byType(AnchorTile).at(1));

      expect(
        rechts.height,
        closeTo(links.height, 0.5),
        reason: 'Beide Kacheln einer Reihe tragen dieselbe Höhe.',
      );

      // Und der Inhalt steht in beiden mittig, auch in der gestreckten.
      for (final wort in ['Medikamente', 'Chat']) {
        final kachel = find.ancestor(
          of: find.text(wort),
          matching: find.byType(AnchorTile),
        );
        expect(
          tester.getRect(find.text(wort)).center.dx,
          closeTo(tester.getRect(kachel).center.dx, 1),
          reason: '„$wort" gehört in die Mitte seiner Kachel.',
        );
      }
    });
  });

  group('AnchorRow.onDark', () {
    // Braun und Dunkelblau verschwinden auf dunklem Grund. Angehoben halten
    // sie den 3:1-Kontrast, den WCAG 2.2 für Bedienelemente verlangt.
    test('hebt dunkle Farben an, helle bleiben unberührt', () {
      const braun = Color(0xFF6D4C41);
      final angehoben = AnchorRow.onDark(braun);

      expect(
        HSLColor.fromColor(angehoben).lightness,
        greaterThanOrEqualTo(0.62),
      );

      const hell = Color(0xFFFFCC80);
      expect(AnchorRow.onDark(hell), hell);
    });

    test('behält den Farbton, damit der Bereich erkennbar bleibt', () {
      const braun = Color(0xFF6D4C41);

      // Ein Grad Toleranz: Der Weg über 8-Bit-Kanäle rundet, der Farbton
      // verschiebt sich dabei um Bruchteile eines Grades. Sichtbar ist das
      // nicht, prüfbar auf drei Nachkommastellen wäre es nur zufällig.
      expect(
        HSLColor.fromColor(AnchorRow.onDark(braun)).hue,
        closeTo(HSLColor.fromColor(braun).hue, 1),
      );
    });
  });
}
