import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// App-Info Overlay - Zeigt Features und Beschreibung der Aurora App
class AppInfoOverlay extends StatelessWidget {
  const AppInfoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.ink,
                    AppColors.inkDeep.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.aboutTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/logo_rainbow.png',
                        height: 80,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Beschreibung
                    Text(
                      l10n.onboardingSubline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.paper,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Features
                    _buildSectionTitle('✨ Features'),
                    const SizedBox(height: 16),

                    _buildFeatureItem(
                      Icons.chat_bubble_outline,
                      'Interner Chat',
                      l10n.aboutChat,
                    ),

                    _buildFeatureItem(
                      Icons.calendar_today,
                      'Kalender & Termine',
                      l10n.aboutCalendar,
                    ),

                    _buildFeatureItem(
                      Icons.medication,
                      'Medikamenten-Tracker',
                      l10n.aboutMedication,
                    ),

                    _buildFeatureItem(
                      Icons.emergency,
                      'Notfall-Tagebuch',
                      l10n.aboutEmergencyDiary,
                    ),

                    _buildFeatureItem(
                      Icons.contacts,
                      'Kontaktverwaltung',
                      l10n.aboutContacts,
                    ),

                    _buildFeatureItem(
                      Icons.search,
                      'Finder',
                      l10n.aboutFinder,
                    ),

                    _buildFeatureItem(
                      Icons.security,
                      'Datenschutz',
                      l10n.aboutLocalOnly,
                    ),

                    const SizedBox(height: 32),

                    // Version Info
                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.paper.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.paper,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
