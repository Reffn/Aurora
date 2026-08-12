import 'package:dis_app/modules/anchor/anker_kopfblock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Kopfblock des Ankers darf seine Obergrenze nie überschreiten — sonst
/// schiebt er die erste Kachelreihe aus dem Bild.
///
/// Das ist zwischen dem 9. und dem 11. August 2026 viermal passiert, weil eine
/// feste Zahl für „alles neben der Zeitkarte" stand und niemand sie mitpflegte.
/// Der bisherige Ankertest konnte es nicht sehen: Er pumpt einen erfundenen
/// Banner und prüft damit ein Versprechen, das er selbst gibt.
void main() {
  /// Baut den Block mit steuerbaren Nachbarn.
  Future<Size> pumpe(
    WidgetTester tester, {
    required double verfuegbar,
    double resetHoehe = 0,
    double ueberblickHoehe = 0,
    double kartenWunsch = 280,
  }) async {
    final schluessel = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnkerKopfblock(
              key: schluessel,
              verfuegbar: verfuegbar,
              resetHinweis: resetHoehe == 0
                  ? null
                  : SizedBox(height: resetHoehe, width: 100),
              tagesUeberblick: ueberblickHoehe == 0
                  ? null
                  : SizedBox(height: ueberblickHoehe, width: 100),
              // Eine Karte, die den angebotenen Platz nimmt, aber nie mehr
              // als ihren Wunsch — so verhält sich `TimeMap.hoeheFuerBlock`.
              karteBauen: (platz) => SizedBox(
                height: platz.isFinite && platz < kartenWunsch
                    ? platz
                    : kartenWunsch,
                width: 100,
              ),
            ),
          ),
        ),
      ),
    );

    return tester.getSize(find.byKey(schluessel));
  }

  group('Der Kopfblock hält seine Obergrenze', () {
    testWidgets('mit viel Platz nimmt die Karte ihren Wunsch', (tester) async {
      final groesse = await pumpe(tester, verfuegbar: 600);

      // 280 Karte + 12 Abstand oben/unten
      expect(groesse.height, 292);
    });

    testWidgets('mit knappem Platz schrumpft die Karte', (tester) async {
      final groesse = await pumpe(tester, verfuegbar: 200);

      expect(groesse.height, lessThanOrEqualTo(200));
    });

    testWidgets('ein Nachbar mehr schrumpft die Karte, nicht den Block',
        (tester) async {
      final ohne = await pumpe(tester, verfuegbar: 300);
      final mit = await pumpe(tester, verfuegbar: 300, ueberblickHoehe: 80);

      expect(
        mit.height,
        lessThanOrEqualTo(300),
        reason: 'Genau hier ist der Block viermal über seine Grenze '
            'gewachsen und hat die Kachelreihe verdrängt.',
      );
      expect(ohne.height, lessThanOrEqualTo(300));
    });

    testWidgets('zwei Nachbarn zugleich sprengen ihn auch nicht',
        (tester) async {
      final groesse = await pumpe(
        tester,
        verfuegbar: 300,
        resetHoehe: 60,
        ueberblickHoehe: 80,
      );

      expect(groesse.height, lessThanOrEqualTo(300));
    });

    testWidgets('Nachbarn, die allein schon zu hoch sind, kappen die Karte',
        (tester) async {
      final groesse = await pumpe(
        tester,
        verfuegbar: 150,
        resetHoehe: 100,
        ueberblickHoehe: 100,
      );

      // Der äußerste Fall: Die Karte ist schon auf null geschrumpft, die
      // starren Nachbarn passen trotzdem nicht. Dann meldet Flutter in der
      // Entwicklung einen Überlauf — laut und sichtbar. Genau das ist
      // gewollt: Der Block wächst **nicht** über seine Grenze und verdrängt
      // die Kachelreihe nicht; stattdessen fällt der Fehler dem auf, der ihn
      // verursacht hat. Im Release schneidet `ClipRect` sauber ab.
      expect(
        tester.takeException(),
        isFlutterError,
        reason: 'Der Überlauf soll in der Entwicklung auffallen, nicht '
            'stillschweigend die Kachelreihe verschieben.',
      );
      expect(groesse.height, lessThanOrEqualTo(150));
    });

    testWidgets('eine negative Vorgabe wirft nicht', (tester) async {
      final groesse = await pumpe(tester, verfuegbar: -50);

      expect(groesse.height, greaterThanOrEqualTo(0));
    });

    testWidgets('eine kleine Karte lässt den Block schrumpfen',
        (tester) async {
      // Ohne Standortberechtigung misst sich die Zeitkarte selbst und bleibt
      // deutlich unter dem Angebot. Der Block darf dann nicht auf die
      // Obergrenze aufblähen.
      final groesse = await pumpe(
        tester,
        verfuegbar: 600,
        kartenWunsch: 150,
      );

      expect(groesse.height, 162);
    });
  });
}
