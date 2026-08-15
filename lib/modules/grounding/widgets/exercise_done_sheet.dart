import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Die Leiter am Ende einer Übung
///
/// Drei Wege, gleich gewichtet, ohne Bewertung. Keine Frage, ob es geholfen
/// hat — die ließe sich mit Nein beantworten, und ein Misserfolgserlebnis
/// genau hier schadet.
class ExerciseDoneSheet extends StatelessWidget {
  const ExerciseDoneSheet({
    required this.onAgain,
    required this.onOther,
    required this.onCall,
    super.key,
  });

  final VoidCallback onAgain;
  final VoidCallback onOther;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            _DoneAction(
              key: const ValueKey('grounding-done-again'),
              icon: Icons.refresh,
              label: l10n.groundingDoneAgain,
              onTap: onAgain,
            ),
            const SizedBox(height: 12),
            _DoneAction(
              key: const ValueKey('grounding-done-other'),
              icon: Icons.more_horiz,
              label: l10n.groundingDoneOther,
              onTap: onOther,
            ),
            const SizedBox(height: 12),
            _DoneAction(
              key: const ValueKey('grounding-done-call'),
              icon: Icons.phone,
              label: l10n.groundingDoneCall,
              onTap: onCall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneAction extends StatelessWidget {
  const _DoneAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
