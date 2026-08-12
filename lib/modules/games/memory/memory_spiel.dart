import 'dart:math';

/// Zustand einer einzelnen Karte.
enum KartenZustand {
  /// Liegt mit dem Rücken nach oben.
  verdeckt,

  /// Ist aufgedeckt und wartet auf ihr Gegenstück.
  offen,

  /// Ihr Paar ist gefunden; sie bleibt liegen.
  gefunden,
}

/// Eine Karte im Spiel.
///
/// `platz` ist der feste Ort im Raster und ändert sich nie — die Fläche darf
/// Karten nicht umsortieren, sonst verliert das Spiel seinen Sinn. `bild`
/// benennt das Motiv und ist damit zugleich die Paar-Kennung: Zwei Karten
/// gehören zusammen, wenn sie dasselbe Motiv tragen.
class MemoryKarte {
  MemoryKarte({
    required this.platz,
    required this.bild,
    this.zustand = KartenZustand.verdeckt,
  });

  final int platz;
  final String bild;
  KartenZustand zustand;
}

/// Memory ohne Uhr und ohne Punkte.
///
/// Die Fläche verspricht wörtlich „keine Timer, keine Punkte — nur Ruhe", und
/// die Oberflächen-Richtlinien verbieten Belohnungsschleifen (Regel 11).
/// Deshalb zählt dieses Modell nichts mit: Es kennt Karten, ihren Zustand und
/// die Frage, ob alle Paare liegen. Mehr wäre eine Wertung, und eine Wertung
/// wäre Druck.
///
/// Die Regeln liegen hier und nicht in der Fläche — dann sind sie prüfbar,
/// ohne ein Widget zu bauen, und der Zufall ist über `random` steuerbar.
class MemorySpiel {
  MemorySpiel._(this.karten);

  /// Legt ein Spiel aus je zwei Karten pro Motiv und mischt es.
  ///
  /// Aus `motive` werden `paare` Stück gezogen — bei mehr Motiven als Paaren
  /// sieht deshalb nicht jede Runde gleich aus.
  factory MemorySpiel.neu({
    required List<String> motive,
    required int paare,
    Random? random,
  }) {
    assert(paare > 0, 'Ein Spiel ohne Paare wäre kein Spiel.');
    assert(
      motive.length >= paare,
      'Es müssen mindestens so viele Motive wie Paare da sein.',
    );

    final zufall = random ?? Random();
    final vorrat = List<String>.from(motive)..shuffle(zufall);
    final gezogen = vorrat.take(paare);

    final blatt = <String>[
      for (final motiv in gezogen) ...[motiv, motiv],
    ]..shuffle(zufall);

    return MemorySpiel._([
      for (var i = 0; i < blatt.length; i++)
        MemoryKarte(platz: i, bild: blatt[i]),
    ]);
  }

  final List<MemoryKarte> karten;

  /// Die gerade aufgedeckten Karten, die noch kein Paar sind.
  List<MemoryKarte> get offene =>
      karten.where((k) => k.zustand == KartenZustand.offen).toList();

  /// Zwei Karten liegen offen und passen nicht zusammen.
  ///
  /// In diesem Zustand darf sich die Fläche Zeit lassen, bevor sie umdreht —
  /// wer langsam liest oder langsam erkennt, braucht sie.
  bool get wartetAufZurueckdrehen => offene.length >= 2;

  /// Alle Paare liegen.
  bool get fertig => karten.every((k) => k.zustand == KartenZustand.gefunden);

  /// Deckt die Karte an diesem Platz auf.
  ///
  /// Gibt zurück, ob sich etwas geändert hat — daran hängt, ob die Fläche
  /// neu zeichnen muss.
  ///
  /// Ein Griff auf eine bereits offene oder gefundene Karte tut nichts. Wer
  /// bei zwei offenen Karten eine dritte greift, dreht die beiden damit
  /// zurück: Der Weg endet nie in einer Sperre, auf die man warten muss
  /// (Errorless Learning — die richtige Handlung wird angeboten, statt einen
  /// Fehlerpfad entstehen zu lassen).
  bool aufdecken(int platz) {
    final karte = karten.firstWhere((k) => k.platz == platz);
    if (karte.zustand != KartenZustand.verdeckt) return false;

    if (wartetAufZurueckdrehen) zurueckdrehen();

    karte.zustand = KartenZustand.offen;

    final jetztOffen = offene;
    if (jetztOffen.length == 2 &&
        jetztOffen.first.bild == jetztOffen.last.bild) {
      for (final gefunden in jetztOffen) {
        gefunden.zustand = KartenZustand.gefunden;
      }
    }

    return true;
  }

  /// Dreht die offenen Karten wieder um. Gefundene Paare bleiben liegen.
  void zurueckdrehen() {
    for (final karte in offene) {
      karte.zustand = KartenZustand.verdeckt;
    }
  }
}
