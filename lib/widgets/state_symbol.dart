import 'package:dis_app/widgets/icon_container.dart';
import 'package:flutter/material.dart';

/// Rundes Symbol, dessen Zustand doppelt kodiert ist
///
/// Aktiv heißt: gefüllter Hintergrund **und** kräftige Farbe. Inaktiv heißt:
/// transparent **und** gedämpft. Nie nur eines von beidem — wer Farben schlecht
/// unterscheidet, erkennt den Zustand dann immer noch an der Füllung.
///
/// Setzt auf [IconContainer] auf, statt einen eigenen Kreis zu zeichnen.
class StateSymbol extends StatelessWidget {
  const StateSymbol({
    required this.icon,
    required this.color,
    required this.active,
    this.badge,
    this.badgeColor,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final Color color;
  final bool active;

  /// Optionales kleines Abzeichen unten rechts, z. B. ein Schloss
  final IconData? badge;
  final Color? badgeColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final symbol = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? color : color.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: IconContainer.circle(
        icon: icon,
        size: size,
        iconSize: size * 0.55,
        backgroundColor: active
            ? color.withValues(alpha: 0.18)
            : Colors.transparent,
        iconColor: active ? color : color.withValues(alpha: 0.35),
      ),
    );

    if (badge == null) return symbol;

    return SizedBox(
      width: size + 4,
      height: size + 4,
      child: Stack(
        children: [
          symbol,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
              ),
              child: Icon(
                badge,
                size: 13,
                color: badgeColor ?? Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
