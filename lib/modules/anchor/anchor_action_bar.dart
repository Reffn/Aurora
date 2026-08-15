import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:flutter/material.dart';

/// Ein Weg in der festen Leiste.
class AnchorAction {
  const AnchorAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.imageAsset,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? imageAsset;
}

/// Die feste Leiste unter dem Anker: Halt, Notfall, Hilfe.
///
/// Sie scrollt nicht. Das ist ihr ganzer Zweck.
///
/// Vorher standen diese drei als erste Gruppe oben im Menü — richtig nach
/// Regel 9 („der angebotene Schnellweg steht oben"), aber nur solange
/// niemand gescrollt hatte. Wer im Tagebuch war und die Liste hochgezogen
/// hatte, musste erst zurückscrollen, um zu Halt zu kommen. Genau in dem
/// Zustand, in dem man Halt braucht, ist das ein Schritt zu viel.
///
/// Am festen Platz erfüllt sie Regel 7 („Reihenfolge ist eine Zusage")
/// schärfer als vorher: Nicht nur die Reihenfolge steht fest, sondern der
/// Ort auf dem Schirm.
///
/// Die volle Farbfläche bleibt diesen dreien vorbehalten (Regel 4). Dass sie
/// anders gebaut sind als die neun Kacheln, ist kein Bruch der einen
/// Bauform, sondern die Grenze, die Regel 4 selbst zieht: „Halt, Notfall,
/// Hilfe tragen volle Farbe. Die neun anderen Bereiche tragen ihre Farbe als
/// Marke." Zwei Klassen, jede in sich einheitlich — nicht eine Klasse mit
/// drei Ausreißern.
class AnchorActionBar extends StatelessWidget {
  const AnchorActionBar({required this.actions, super.key});

  final List<AnchorAction> actions;

  /// Höhe eines Knopfes.
  ///
  /// Dieselben 110 dp wie Zeile und Kachel. Gerade hier wäre Sparen falsch:
  /// Die Begründung für das Maß — „more for unsteady hands" (WCAG 2.2) —
  /// beschreibt genau den Zustand, in dem diese drei Knöpfe gesucht werden.
  static const double buttonHeight = 110;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    // Kein Kasten und kein Schatten unter den Knöpfen.
    //
    // Beides stand hier, um die Leiste von der Liste zu trennen. Die Trennung
    // macht jetzt die Liste selbst: Sie blendet an ihrer Unterkante aus, statt
    // gegen eine Kante zu laufen. Was übrig bleibt, sind drei farbige Knöpfe
    // auf derselben Fläche wie alles andere — sie tragen ihre eigene Farbe und
    // brauchen keinen Rahmen, der sie ankündigt.
    return Padding(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        // Ohne den Systemleisten-Abstand lägen die Knöpfe am Gerät hinter den
        // Navigationsknöpfen — bei einer Leiste, die den Notruf trägt, ist
        // das nicht verhandelbar.
        8 + context.safeBottomPadding,
      ),
      child: Row(
        children: [
          for (final action in actions)
            Expanded(child: _ActionButton(action: action)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({required this.action});

  final AnchorAction action;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;

    return Semantics(
      button: true,
      label: action.label,
      // Ohne diesen Ausschluss sammelt der Baum den sichtbaren Text zusätzlich
      // ein und die Ansage lautet „Halt, Halt" statt „Halt". Dieselbe Stelle
      // stand am 10. August 2026 schon in AnchorRow; die Leiste hat sie geerbt.
      //
      // Der Ausschluss nimmt aber auch die Tipp-Handlung des GestureDetector
      // mit — der Knoten trüge dann einen Namen und keine Handlung, und
      // Vorlesehilfen böten ihn nicht mehr zum Antippen an. Deshalb steht
      // `onTap` hier oben: Name und Handlung auf demselben Knoten.
      excludeSemantics: true,
      onTap: action.onTap,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: action.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AnchorActionBar.buttonHeight,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: action.color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: action.color.withValues(alpha: 0.35),
                  blurRadius: _pressed ? 4 : 10,
                  offset: Offset(0, _pressed ? 1 : 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                if (action.imageAsset == null)
                  const Icon(Icons.circle, size: 40, color: Colors.white)
                else
                  // Die Figur über dem Wort, nicht daneben: Bei einem Drittel
                  // Bildschirmbreite steht „Notfall" nicht neben ihr, ohne
                  // dass eines von beidem unlesbar wird. Regel 5 verlangt
                  // beides zusammen, nicht nebeneinander.
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Image.asset(
                      action.imageAsset!,
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: Text(
                    action.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
