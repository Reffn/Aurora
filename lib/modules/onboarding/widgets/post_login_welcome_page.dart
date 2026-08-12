import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Template-Widget für eine Post-Login Welcome Seite
/// Ähnlich wie PreOnboardingPage, aber mit optionalem Gradient-Header für personalisierte Begrüßung
class PostLoginWelcomePage extends StatelessWidget {
  const PostLoginWelcomePage({
    required this.headline,
    this.icon,
    this.iconWidget,
    this.subline,
    this.description,
    this.content,
    this.bulletPoints,
    this.gradientColors,
    super.key,
  });

  final String headline;
  final IconData? icon;
  final Widget? iconWidget;
  final String? subline;
  final String? description;
  final Widget? content;
  final List<String>? bulletPoints;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink, // Dark solid background
      child: SafeArea(
        bottom: false, // Navigation-Container handles bottom SafeArea
        child: SingleChildScrollView(
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
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
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
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(height: 32),

                // Headline
                Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.paperBright, // Cream White
                  ),
                  textAlign: TextAlign.center,
                ),

                // Subline
                if (subline != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    subline!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFE8D4C0), // Warm Beige
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Description
                if (description != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFD4C5B9), // Soft Beige
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Custom Content Widget
                if (content != null) ...[
                  const SizedBox(height: 32),
                  content!,
                ],

                // Bullet Points
                if (bulletPoints != null && bulletPoints!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: bulletPoints!.map((point) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
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
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFFE8D4C0), // Warm Beige
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
      ),
    );
  }
}
