import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/widgets/step_view.dart';
import 'package:dis_app/widgets/animated_tap_card.dart';
import 'package:flutter/material.dart';

/// Der große Anker
///
/// Ein Tippen, sofort in der Orientierungsübung. Wer nicht wählen kann, muss
/// nicht wählen — im dissoziativen Zustand ist Auswählen selbst schon
/// Überforderung.
class AnchorButton extends StatelessWidget {
  const AnchorButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = GroundingExercises.anchor.color;

    return AnimatedTapCard(
      onTap: onTap,
      borderRadius: 24,
      child: Container(
        // Volle Breite: Der Anker ist das Ziel, das niemand verfehlen darf.
        // Ohne diese Angabe schrumpft der Container auf die Breite seines
        // Inhalts und wird zur schmalen Säule.
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(GroundingExercises.anchor.icon, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              // Der Knopf trägt den Namen der Übung, die er startet.
              // „Anker" stand vorher hier: eine Metapher, die Lesen und
              // Deuten verlangt — beides fehlt genau dann, wenn dieser Knopf
              // gebraucht wird.
              StepView.titleOf(l10n, GroundingExercises.anchor),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
