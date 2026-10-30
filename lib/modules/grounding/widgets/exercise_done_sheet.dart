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
    this.color,
    super.key,
  });

  final VoidCallback onAgain;
  final VoidCallback onOther;
  final VoidCallback onCall;

  /// Die Farbe der Übung, die gerade zu Ende ging. Ohne Angabe die
  /// Primärfarbe — Tests und ältere Aufrufer bleiben gültig.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tint = color ?? Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Derselbe ruhige Kreis wie auf den Schritten davor: Die Übung
            // ist zu Ende, nicht „geschafft" — kein Konfetti, kein Lob
            // (Richtlinie 11), nur ein Haken in der Farbe der Übung.
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tint.withValues(alpha: 0.18),
              ),
              child: Icon(Icons.check, size: 52, color: tint),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.groundingDoneTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, height: 1.4),
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
