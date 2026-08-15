import 'package:flutter/material.dart';

/// Der Block über der Kachelliste: Reset-Hinweis, Zeitkarte, Tagesüberblick.
///
/// **Warum er ein eigenes Bauteil ist.** Vorher lag diese Aufteilung mitten in
/// `main.dart` und rechnete mit einer festen Zahl: `_bannerNebenDerZeitkarte
/// = 60` stand für alles, was neben der Zeitkarte im Block liegt. Wer dort
/// etwas ergänzte, änderte die Höhe und nicht die Zahl — und die erste
/// Kachelreihe fiel aus dem Bild. Das ist zwischen dem 9. und dem 11. August
/// 2026 viermal passiert, zuletzt durch den Telemetrie-Hinweis.
///
/// **Jetzt misst sich jeder selbst.** Der Block bekommt eine Obergrenze; die
/// Nachbarn nehmen ihre natürliche Höhe, und die Karte bekommt als einziges
/// `Flexible` den Rest. Kommt etwas dazu, schrumpft die Karte — nicht die
/// Kachelreihe darunter. Es gibt keine Zahl mehr, die jemand vergessen kann.
///
/// **Was die Karte daraus macht, entscheidet sie selbst.** `karteBauen`
/// bekommt den verbliebenen Platz und darf ihn unterschreiten: Ohne
/// Standortberechtigung zeichnet die Zeitkarte nur Kopfstrang und
/// Hinweisband und misst sich dabei selbst. Deshalb ist der Rest eine
/// Obergrenze und keine Vorgabe.
class AnkerKopfblock extends StatelessWidget {
  const AnkerKopfblock({
    required this.verfuegbar,
    required this.karteBauen,
    super.key,
    this.resetHinweis,
    this.tagesUeberblick,
  });

  /// Was der Block höchstens einnehmen darf.
  final double verfuegbar;

  /// Baut die Zeitkarte für den verbliebenen Platz.
  final Widget Function(double platz) karteBauen;

  /// Läuft gerade ein Passwort-Reset, steht er ganz oben.
  final Widget? resetHinweis;

  /// „Was dieser Tag trägt" — Termine und Medikamente.
  final Widget? tagesUeberblick;

  /// Abstand der Karte zu Rand und Nachbarn.
  static const EdgeInsets kartenAbstand = EdgeInsets.fromLTRB(12, 4, 12, 8);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      // Der Notausgang für den äußersten Fall: Wenn die starren Nachbarn
      // allein schon höher sind als der Platz, kann die Karte nicht mehr
      // weiter schrumpfen — sie ist dann bereits null. Ohne diesen Schnitt
      // wirft Flutter einen Überlauf.
      //
      // Abgeschnitten wird unten, also zuerst der Tagesüberblick. Das ist die
      // bewusst gewählte Reihenfolge: Der Reset-Hinweis oben trägt eine
      // laufende Frist und muss sichtbar bleiben, und die Kachelreihe
      // darunter darf auf keinen Fall verdrängt werden — sie war der Grund
      // für diese ganze Bauform.
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: verfuegbar.clamp(0.0, double.infinity),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?resetHinweis,
            Flexible(
              child: Padding(
                padding: kartenAbstand,
                child: LayoutBuilder(
                  builder: (context, platz) => karteBauen(platz.maxHeight),
                ),
              ),
            ),
            ?tagesUeberblick,
          ],
        ),
      ),
    );
  }
}
