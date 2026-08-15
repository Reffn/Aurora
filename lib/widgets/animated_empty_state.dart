import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:flutter/material.dart';

/// Animierter Empty State mit pulsierendem Icon
/// Verwendung: AnimatedEmptyState(icon: Icons.event_note, title: '...', subtitle: '...')
///
/// Hält unten den Platz frei, den der schwebende „+"-Knopf einnimmt. Ohne das
/// verdeckt der Knopf genau den Satz, der auf ihn verweist — „Tippe auf +, um
/// einen Ort hinzuzufügen" endete auf dem Gerät bei „einen Ort hi". Ein leerer
/// Zustand scrollt nicht, also ist der verdeckte Teil dauerhaft unerreichbar.
/// Wo statt eines Knopfes eine Eingabezeile steht (Chat), gilt dasselbe.
class AnimatedEmptyState extends StatefulWidget {
  const AnimatedEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState> {
  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Scrollbar, damit die Darstellung nicht bricht, wenn die Tastatur den
    // Platz halbiert: im Chat meldete Flutter dann `BOTTOM OVERFLOWED BY 217
    // PIXELS` quer über den Bildschirm.
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(
          32,
          32,
          32,
          context.safeBottomPaddingForFab,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: reduceMotion ? 1 : 0.8, end: 1),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              onEnd: reduceMotion
                  ? null
                  : () {
                      if (mounted) setState(() {});
                    },
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
