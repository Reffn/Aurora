import 'package:flutter/material.dart';

/// Dot-Indikator für Onboarding-Seiten
/// Zeigt die aktuelle Position in einer Seiten-Sequenz an
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    required this.currentPage,
    required this.totalPages,
    this.activeColor,
    this.inactiveColor,
    super.key,
  });

  final int currentPage;
  final int totalPages;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? theme.colorScheme.primary;
    final effectiveInactiveColor =
        inactiveColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? effectiveActiveColor : effectiveInactiveColor,
          ),
        );
      }),
    );
  }
}
