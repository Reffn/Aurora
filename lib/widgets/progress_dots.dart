import 'package:flutter/material.dart';

/// Punktereihe als abzählbare Fortschrittsanzeige
///
/// Gefüllt heißt erledigt oder aktiv, offen heißt ausstehend. Gedacht für
/// Stellen, an denen eine Zahl allein nicht trägt, weil niemand liest.
///
/// Ab [maxDots] Einheiten wird nichts gezeichnet — eine Reihe aus zwanzig
/// Punkten ist nicht mehr abzählbar und damit nutzlos.
class ProgressDots extends StatelessWidget {
  const ProgressDots({
    required this.active,
    required this.total,
    required this.color,
    this.maxDots = 12,
    super.key,
  });

  final int active;
  final int total;
  final Color color;
  final int maxDots;

  @override
  Widget build(BuildContext context) {
    if (total <= 0 || total > maxDots) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        total,
        (i) => ProgressDotsDot(filled: i < active, color: color),
      ),
    );
  }
}

/// Einzelner Punkt einer [ProgressDots]-Reihe
///
/// Eigene Klasse, damit Tests den Zustand einzelner Punkte prüfen können,
/// statt gegen gemalte Pixel zu assertieren.
class ProgressDotsDot extends StatelessWidget {
  const ProgressDotsDot({
    required this.filled,
    required this.color,
    super.key,
  });

  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? color : Colors.transparent,
          border: Border.all(
            color: filled ? color : color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
