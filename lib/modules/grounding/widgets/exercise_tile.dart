import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/modules/grounding/widgets/step_view.dart';
import 'package:dis_app/widgets/animated_tap_card.dart';
import 'package:dis_app/widgets/state_symbol.dart';
import 'package:flutter/material.dart';

/// Eine Übungskachel: Symbol groß, Name klein darunter
class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    required this.exercise,
    required this.onTap,
    super.key,
  });

  final GroundingExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedTapCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: exercise.color.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StateSymbol(
              icon: exercise.icon,
              color: exercise.color,
              active: true,
              size: 56,
            ),
            const SizedBox(height: 8),
            Text(
              StepView.titleOf(l10n, exercise),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
