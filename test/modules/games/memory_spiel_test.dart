import 'dart:math';

import 'package:dis_app/modules/games/memory/memory_spiel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const motive = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'];

  MemorySpiel spiel({int paare = 6, int seed = 1}) => MemorySpiel.neu(
        motive: motive,
        paare: paare,
        random: Random(seed),
      );

  /// Sucht die beiden Plätze, an denen dasselbe Motiv liegt.
  List<int> paarPlaetze(MemorySpiel s) {
    final motiv = s.karten.first.bild;
    return s.karten.where((k) => k.bild == motiv).map((k) => k.platz).toList();
  }

  /// Sucht zwei Plätze mit verschiedenen Motiven.
  List<int> ungleichePlaetze(MemorySpiel s) {
    final erste = s.karten.first;
    final andere = s.karten.firstWhere((k) => k.bild != erste.bild);
    return [erste.platz, andere.platz];
  }

  group('Das Blatt', () {
    test('trägt jedes Motiv genau zweimal', () {
      final s = spiel();

      final zaehlung = <String, int>{};
      for (final karte in s.karten) {
        zaehlung[karte.bild] = (zaehlung[karte.bild] ?? 0) + 1;
      }

      expect(s.karten.length, 12);
      expect(zaehlung.length, 6);
      expect(zaehlung.values.every((n) => n == 2), isTrue);
    });

    test('liegt zu Beginn vollständig verdeckt', () {
      expect(
        spiel().karten.every((k) => k.zustand == KartenZustand.verdeckt),
        isTrue,
      );
    });

    test('gibt jedem Platz genau eine Karte', () {
      final plaetze = spiel().karten.map((k) => k.platz).toList();

      expect(plaetze.toSet().length, plaetze.length);
      expect(plaetze..sort(), List.generate(12, (i) => i));
    });

    test('sieht bei gleichem Startwert gleich aus', () {
      final a = spiel(seed: 7).karten.map((k) => k.bild).toList();
      final b = spiel(seed: 7).karten.map((k) => k.bild).toList();

      expect(a, b);
    });

    test('zieht nicht immer dieselben Motive', () {
      // Neun Motive, sechs Paare — sonst wäre jede Runde dieselbe.
      final gezogen = <String>{};
      for (var seed = 0; seed < 12; seed++) {
        gezogen.addAll(spiel(seed: seed).karten.map((k) => k.bild));
      }

      expect(gezogen.length, greaterThan(6));
    });
  });

  group('Aufdecken', () {
    test('dreht eine verdeckte Karte um', () {
      final s = spiel();

      expect(s.aufdecken(0), isTrue);
      expect(s.karten[0].zustand, KartenZustand.offen);
    });

    test('auf eine offene Karte geschieht nichts', () {
      final s = spiel()..aufdecken(0);

      expect(s.aufdecken(0), isFalse);
      expect(s.offene.length, 1);
    });

    test('ein Paar bleibt liegen', () {
      final s = spiel();
      final paar = paarPlaetze(s);

      s
        ..aufdecken(paar.first)
        ..aufdecken(paar.last);

      expect(
        s.karten
            .where((k) => paar.contains(k.platz))
            .every((k) => k.zustand == KartenZustand.gefunden),
        isTrue,
      );
      expect(s.wartetAufZurueckdrehen, isFalse);
    });

    test('zwei ungleiche Karten bleiben offen und warten', () {
      final s = spiel();
      final zwei = ungleichePlaetze(s);

      s
        ..aufdecken(zwei.first)
        ..aufdecken(zwei.last);

      expect(s.offene.length, 2);
      expect(s.wartetAufZurueckdrehen, isTrue);
    });

    test('der dritte Griff dreht die beiden zurück, statt zu sperren', () {
      final s = spiel();
      final zwei = ungleichePlaetze(s);
      s
        ..aufdecken(zwei.first)
        ..aufdecken(zwei.last);

      final dritte =
          s.karten.firstWhere((k) => k.zustand == KartenZustand.verdeckt);
      expect(s.aufdecken(dritte.platz), isTrue);

      expect(
        s.offene.map((k) => k.platz),
        [dritte.platz],
        reason: 'Ein Griff, der nichts tut, wäre ein Fehlerpfad — die '
            'richtige Handlung wird angeboten (Errorless Learning).',
      );
    });

    test('ein gefundenes Paar dreht sich nie wieder um', () {
      final s = spiel();
      final paar = paarPlaetze(s);
      s
        ..aufdecken(paar.first)
        ..aufdecken(paar.last)
        ..zurueckdrehen();

      expect(
        s.karten
            .where((k) => paar.contains(k.platz))
            .every((k) => k.zustand == KartenZustand.gefunden),
        isTrue,
      );
    });
  });

  group('Ende', () {
    test('ist erst erreicht, wenn alle Paare liegen', () {
      final s = spiel();
      expect(s.fertig, isFalse);

      for (final motiv in s.karten.map((k) => k.bild).toSet()) {
        final paar =
            s.karten.where((k) => k.bild == motiv).map((k) => k.platz).toList();
        s
          ..aufdecken(paar.first)
          ..aufdecken(paar.last);
      }

      expect(s.fertig, isTrue);
      expect(
        s.karten.every((k) => k.zustand == KartenZustand.gefunden),
        isTrue,
      );
    });

    test('ein halb gelöstes Spiel gilt nicht als fertig', () {
      final s = spiel();
      final paar = paarPlaetze(s);
      s
        ..aufdecken(paar.first)
        ..aufdecken(paar.last);

      expect(s.fertig, isFalse);
    });
  });
}
