import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Template-Widget für eine Pre-Onboarding Seite
/// Zeigt Icon/Logo, Headline, Beschreibung und optionale Bullet-Points
class PreOnboardingPage extends StatelessWidget {
  const PreOnboardingPage({
    required this.headline,
    this.icon,
    this.iconWidget,
    this.subline,
    this.description,
    this.bulletPoints,
    this.backgroundColor,
    super.key,
  }) : assert(
         icon != null || iconWidget != null,
         'Either icon or iconWidget must be provided',
       );

  final String headline;
  final IconData? icon;
  final Widget? iconWidget;
  final String? subline;
  final String? description;
  final List<String>? bulletPoints;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color:
          backgroundColor ?? AppColors.ink, // Einfarbiger dunkler Hintergrund
      child: SafeArea(
        bottom: false, // Navigation-Container handles bottom SafeArea
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon oder Logo
              if (iconWidget != null)
                iconWidget!
              else if (icon != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFB6C1), // Pastell Rosa
                        Color(0xFF87CEEB), // Pastell Blau
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 40),

              // Headline
              Text(
                headline,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.paperBright, // Cremeweiß
                  fontSize: 28,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              // Subline
              if (subline != null) ...[
                const SizedBox(height: 12),
                Text(
                  subline!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFE8D4C0), // Warmes Beige
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Description
              if (description != null) ...[
                const SizedBox(height: 24),
                Text(
                  description!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFD4C5B9), // Sanftes Beige
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Bullet Points
              if (bulletPoints != null && bulletPoints!.isNotEmpty) ...[
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: bulletPoints!.map((point) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFFB6C1), // Pastell Rosa
                                  Color(0xFF87CEEB), // Pastell Blau
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              point,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFD4C5B9), // Warmes Beige
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
