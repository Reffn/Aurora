import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Feature-Carousel für Pre-Onboarding
/// Zeigt horizontal wischbare Feature-Seiten mit Icon + Beschreibung
class FeatureCarouselPage extends StatefulWidget {
  const FeatureCarouselPage({super.key});

  @override
  State<FeatureCarouselPage> createState() => _FeatureCarouselPageState();
}

class _FeatureCarouselPageState extends State<FeatureCarouselPage> {
  late PageController _pageController;
  int _currentFeaturePage = 0;

  List<FeatureItem> _getFeatures(AppLocalizations l10n) => [
    FeatureItem(
      icon: Icons.chat_bubble_outline,
      iconColor: const Color(0xFFFFB6C1), // Pink
      title: l10n.featureCarouselChatTitle,
      subtitle: l10n.featureCarouselChatSubtitle,
      description: l10n.featureCarouselChatDescription,
    ),
    FeatureItem(
      icon: Icons.calendar_today,
      iconColor: const Color(0xFF87CEEB), // Sky Blue
      title: l10n.featureCarouselCalendarTitle,
      subtitle: l10n.featureCarouselCalendarSubtitle,
      description: l10n.featureCarouselCalendarDescription,
    ),
    FeatureItem(
      icon: Icons.book_outlined,
      iconColor: const Color(0xFFFFDAB9), // Peach
      title: l10n.featureCarouselDiaryTitle,
      subtitle: l10n.featureCarouselDiarySubtitle,
      description: l10n.featureCarouselDiaryDescription,
    ),
    FeatureItem(
      icon: Icons.location_on_outlined,
      iconColor: const Color(0xFFB4E7CE), // Mint
      title: l10n.featureCarouselFinderTitle,
      subtitle: l10n.featureCarouselFinderSubtitle,
      description: l10n.featureCarouselFinderDescription,
    ),
    FeatureItem(
      icon: Icons.medication_outlined,
      iconColor: const Color(0xFFFFF4A3), // Yellow
      title: l10n.featureCarouselMedicationTitle,
      subtitle: l10n.featureCarouselMedicationSubtitle,
      description: l10n.featureCarouselMedicationDescription,
    ),
    FeatureItem(
      icon: Icons.games_outlined,
      iconColor: const Color(0xFFDDA0DD), // Lavender
      title: l10n.featureCarouselGamesTitle,
      subtitle: l10n.featureCarouselGamesSubtitle,
      description: l10n.featureCarouselGamesDescription,
    ),
    FeatureItem(
      icon: Icons.emergency_outlined,
      iconColor: const Color(0xFFFF6B6B), // Soft Red
      title: l10n.featureCarouselEmergencyTitle,
      subtitle: l10n.featureCarouselEmergencySubtitle,
      description: l10n.featureCarouselEmergencyDescription,
    ),
    FeatureItem(
      icon: Icons.info_outline,
      iconColor: const Color(0xFF87CEEB), // Sky Blue
      title: l10n.featureCarouselInfoTitle,
      subtitle: l10n.featureCarouselInfoSubtitle,
      description: l10n.featureCarouselInfoDescription,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = _getFeatures(l10n);

    return ColoredBox(
      color: AppColors.ink, // Dunkler Hintergrund
      child: SafeArea(
        bottom: false, // Navigation-Container handles bottom SafeArea
        child: Column(
          children: [
            const SizedBox(height: 48),

            // Headline
            Text(
              l10n.featureCarouselHeadline,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.paperBright, // Cremeweiß
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subline mit Wisch-Hinweis
            Text(
              l10n.featureCarouselSwipeHint,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFFE8D4C0).withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 32),

            // Feature Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentFeaturePage = index;
                  });
                },
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return _buildFeaturePage(features[index]);
                },
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_currentFeaturePage + 1} / ${features.length}',
                    style: const TextStyle(
                      color: Color(0xFFE8D4C0),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ...List.generate(features.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentFeaturePage == index
                            ? const Color(0xFFFFB6C1) // Active: Pink
                            : const Color(0xFF4A4458), // Inactive: Dark Grey
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePage(FeatureItem feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon mit Gradient-Container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: feature.iconColor.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: feature.iconColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              feature.icon,
              size: 64,
              color: feature.iconColor,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            feature.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.paperBright, // Cremeweiß
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            feature.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFE8D4C0), // Warmes Beige
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            feature.description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFD4C5B9), // Sanftes Beige
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Feature-Item Datenklasse
class FeatureItem {
  const FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
}
