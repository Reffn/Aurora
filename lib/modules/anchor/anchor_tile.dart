import 'package:dis_app/modules/anchor/anchor_row.dart';
import 'package:flutter/material.dart';

/// Eine Kachel im Ankermenü.
///
/// Halbe Breite statt voller. Der Grund ist Prüffrage 6 der
/// Oberflächen-Richtlinien — „liegt etwas außerhalb des Schirms, das man
/// nicht durch Scrollen erreicht?": Zwölf Zeilen à 110 dp sind über drei
/// Bildschirmhöhen. Halt stand zwar oben, war aber weg, sobald jemand bis
/// zum Tagebuch gescrollt hatte. Zwei Spalten halbieren die Strecke, und
/// die drei Wege für den schlechtesten Zustand wandern in eine feste
/// Leiste, die gar nicht erst scrollt (`AnchorActionBar`).
///
/// Was dabei nicht aufgegeben wird: Das Bild trägt, das Wort bestätigt
/// (Regel 5). Die Figur bleibt so groß, wie die Kachel es zulässt, und
/// steht über dem Wort statt daneben — in halber Breite ist nebeneinander
/// kein Platz für beides in lesbarer Größe.
class AnchorTile extends StatefulWidget {
  const AnchorTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.imageAsset,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  /// Das Chamäleon für diesen Bereich. Fehlt es, trägt das Material-Icon.
  final String? imageAsset;

  /// Mindesthöhe einer Kachel.
  ///
  /// Dieselben 110 dp wie die Zeile, aus demselben Grund: WCAG 2.2 nennt
  /// 24 px als Untergrenze und sagt ausdrücklich „more for unsteady hands".
  /// Eine Kachel ist schmaler als eine Zeile, also darf sie nicht auch noch
  /// niedriger werden — sonst schrumpft die Trefferfläche in beiden Achsen.
  ///
  /// Mindest-, nicht Festhöhe: Bei 200 % Systemschrift braucht das Wort zwei
  /// Zeilen. Eine feste Höhe würde dort abschneiden, was das Bild ohnehin nur
  /// bestätigen soll — die Kachel wächst stattdessen mit.
  static const double minHeight = 110;

  /// Kantenlänge der Figur auf der Kachel.
  ///
  /// Kleiner als das Querformat der Zeile (88×72), weil die Kachel die Breite
  /// nicht übrig hat. Über dem Wort statt daneben behält sie trotzdem mehr
  /// Fläche, als ein Drittel der Kachelbreite hergäbe.
  static const double figureSize = 56;

  @override
  State<AnchorTile> createState() => _AnchorTileState();
}

class _AnchorTileState extends State<AnchorTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = AnchorRow.onDark(widget.color);

    return Semantics(
      button: true,
      label: widget.label,
      // Wie in AnchorRow und der Aktionsleiste: Ohne den Ausschluss sagt die
      // Vorlesehilfe den Namen zweimal, und ohne `onTap` hier oben verlöre der
      // Knoten mit dem Ausschluss auch die Handlung.
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AnchorTile.minHeight,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              // Der Farbstreifen an der Oberkante statt links.
              //
              // Die Zeile trägt ihn links, weil dort auch der Inhalt anfängt.
              // Auf der mittig aufgebauten Kachel gäbe eine linke Kante eine
              // Leserichtung vor, die es hier nicht gibt — oben steht er quer
              // über der ganzen Marke.
              //
              // Als Rahmen und nicht als Layout-Kind. Zwei Versuche vorher
              // waren falsch: Im Fluss der Spalte rutschte er mit in die
              // Mitte, sobald `IntrinsicHeight` die Kachel streckte; in einem
              // `Stack` bekam die Spalte lockere Constraints, schrumpfte auf
              // ihre Inhaltsbreite und klebte in der linken oberen Ecke. Ein
              // Rahmen ist überhaupt kein Kind — er klebt immer oben und
              // lässt die Spalte in Ruhe.
              border: Border(
                top: BorderSide(color: accent, width: AnchorRow.markerWidth),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                if (widget.imageAsset == null)
                  Icon(widget.icon, size: 40, color: accent)
                else
                  SizedBox(
                    width: AnchorTile.figureSize,
                    height: AnchorTile.figureSize,
                    child: Image.asset(
                      widget.imageAsset!,
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    // Zwei Zeilen, nicht eine: „Medikamente" passt in
                    // halber Breite nicht in eine, und abgeschnitten wäre
                    // es schlechter lesbar als umgebrochen.
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
