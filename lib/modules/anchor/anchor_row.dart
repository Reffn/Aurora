import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Wie laut eine Zeile auftritt.
///
/// Forschung zu Farbe in mHealth-Anwendungen (Health Informatics Journal 2024)
/// findet bei belasteten Menschen eine deutliche Vorliebe für Zurückhaltung:
/// Kräftige, fröhliche Farben stehen im Widerspruch zur eigenen Stimmung und
/// werden als körperlich unangenehm beschrieben. Zwölf gesättigte Flächen auf
/// einem Schirm sind genau das.
///
/// Deshalb bekommt Sättigung eine Aufgabe statt eines Dekors: Was man im
/// schlechtesten Zustand finden muss, ist farbig. Alles andere trägt seine
/// Farbe nur als Marke am Rand.
enum AnchorEmphasis {
  /// Volle Farbfläche. Nur für die Bereiche, die im Notfall gefunden werden.
  solid,

  /// Dunkle Fläche, Farbe als Streifen und im Symbol.
  quiet,
}

/// Eine Zeile im Ankermenü.
///
/// Volle Breite, groß genug, dass sie ohne Zielgenauigkeit zu treffen ist.
/// Das Symbol trägt, das Wort bestätigt nur — wer nicht liest, kommt trotzdem
/// an. Deshalb steht das Symbol links und ist größer als die Schrift.
///
/// **Der Anker rendert diese Zeile nicht mehr.** Zwölf davon untereinander
/// waren über drei Bildschirmhöhen; seit dem Kachel-Umbau stehen dort
/// `AnchorTile` und `AnchorActionBar`. Die Klasse bleibt, weil drei Dinge aus
/// ihr weiterleben und in den Oberflächen-Richtlinien unter diesem Namen
/// stehen: `AnchorEmphasis`, `onDark` und `markerWidth`. Wer eine Zeile in
/// voller Breite braucht, kann sie weiter verwenden.
class AnchorRow extends StatefulWidget {
  const AnchorRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.emphasis = AnchorEmphasis.quiet,
    this.imageAsset,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final AnchorEmphasis emphasis;

  /// Das Chamäleon für diesen Bereich. Fehlt es, trägt das Material-Icon.
  ///
  /// Der Übergang läuft bereichsweise: solange nicht alle zwölf Requisiten
  /// gezeichnet sind, stehen Bild und Icon nebeneinander im Menü.
  final String? imageAsset;

  /// Höhe einer Zeile. Etwa fünf passen auf einen üblichen Schirm.
  ///
  /// Weit über den 24 px, die WCAG 2.2 als Untergrenze nennt — die Norm sagt
  /// ausdrücklich „more for unsteady hands", und unruhige Hände sind hier der
  /// Normalfall, nicht die Ausnahme.
  static const double height = 110;

  /// Das weiße Feld, auf dem das Chamäleon sitzt.
  ///
  /// Größer als die 48 des Icons: Die Figur trägt einen Regenbogen, dessen
  /// gelb-grüne Mitte auf farbigem Grund verschwindet. Das weiße Feld gibt ihr
  /// den Kontrast zurück, und die 110 Zeilenhöhe haben den Platz dafür.
  ///
  /// Breiter als hoch, weil die Figur das Requisit vorhält und damit breiter
  /// baut als sie hoch ist. In einem quadratischen Feld schrumpfte der Kopf,
  /// um den vorgestreckten Arm unterzubringen — im Querformat behält er seine
  /// Größe. Die Zeile hat die Breite übrig, nicht die Höhe.
  ///
  /// Auf der ruhigen Zeile steht die Figur ohne Feld und darf deshalb den
  /// vollen Platz nehmen. Das hilft dort, wo sie am schwächsten ist: Schwanz
  /// und Beine liegen im blau-violetten Ende des Verlaufs und kommen der
  /// dunklen Fläche am nächsten — größer gezeichnet bleiben sie lesbar.
  static const double medallionWidth = 88;
  static const double medallionHeight = 72;

  /// Breite des Farbstreifens einer ruhigen Zeile.
  static const double markerWidth = 8;

  /// Hebt eine Bereichsfarbe so weit auf, dass sie auf dunklem Grund trägt.
  ///
  /// Braun oder Dunkelblau in Originalsättigung verschwinden auf der ruhigen
  /// Fläche. Angehoben auf mindestens 0,62 Helligkeit bleiben sie erkennbar
  /// und halten den 3:1-Kontrast, den WCAG 2.2 für Bedienelemente verlangt.
  static Color onDark(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness(hsl.lightness < 0.62 ? 0.62 : hsl.lightness)
        .toColor();
  }

  @override
  State<AnchorRow> createState() => _AnchorRowState();
}

class _AnchorRowState extends State<AnchorRow> {
  bool _pressed = false;

  bool get _isSolid => widget.emphasis == AnchorEmphasis.solid;

  @override
  Widget build(BuildContext context) {
    final accent = _isSolid ? Colors.white : AnchorRow.onDark(widget.color);
    final surface = _isSolid
        ? widget.color
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Semantics(
      button: true,
      label: widget.label,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: Container(
            height: AnchorRow.height,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isSolid
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.35),
                        blurRadius: _pressed ? 4 : 10,
                        offset: Offset(0, _pressed ? 1 : 4),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // Der Farbstreifen macht den Bereich am linken Rand
                // wiedererkennbar, ohne die ganze Fläche einzufärben.
                if (!_isSolid)
                  Container(width: AnchorRow.markerWidth, color: accent),
                const SizedBox(width: 20),
                if (widget.imageAsset == null)
                  Icon(widget.icon, size: 48, color: accent)
                else
                  // Kein Feld hinter der Figur, auf keiner Zeile. Das weiße
                  // Medaillon der drei farbigen Zeilen sollte ihre gelb-grüne
                  // Mitte retten — am Gerät nachgesehen tut es das nicht,
                  // weil Romys Figuren eine eigene dunkle Kontur tragen und
                  // damit auch auf Grün, Rot und Orange stehen. Was es
                  // stattdessen tat: es klebte ein Rechteck in die Zeile, das
                  // die anderen neun nicht haben — dieselbe Handlung, zwei
                  // Bauformen (Regel 7). Die Figur trägt jetzt überall
                  // gleich, und der Unterschied bleibt der, der zählt: die
                  // volle Farbfläche.
                  SizedBox(
                    width: AnchorRow.medallionWidth,
                    height: AnchorRow.medallionHeight,
                    child: Image.asset(widget.imageAsset!, fit: BoxFit.contain),
                  ),
                const SizedBox(width: 20),
                Expanded(
                  child: Semantics(
                    enabled: false,
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: _isSolid
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
