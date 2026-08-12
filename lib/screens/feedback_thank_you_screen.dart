import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/contact_config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Thank You Screen nach erfolgreichem Feedback-Versand
///
/// Zeigt Bestätigung und Community-Links
class FeedbackThankYouScreen extends StatelessWidget {
  const FeedbackThankYouScreen({
    this.userEmail,
    super.key,
  });

  /// Optional: User-Email (wenn angegeben)
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.inkDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 4),

              // Success Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(
                    ContactConfig.auroraPurple,
                  ).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 28,
                  color: Color(ContactConfig.auroraPurple),
                ),
              ),

              const SizedBox(height: 8),

              // Danke-Nachricht
              Text(
                l10n.feedbackThankYouTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              Text(
                userEmail != null && userEmail!.isNotEmpty
                    ? l10n.feedbackThankYouReceived
                    : l10n.feedbackThankYouMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              // Zurück zur App Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(ContactConfig.auroraPurple),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.thankYouBackToApp,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Community-Links
              Text(
                l10n.feedbackStayInTouch,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 16),

              // Discord
              if (ContactConfig.discordInviteUrl.isNotEmpty) ...[
                _buildCommunityLink(
                  context,
                  icon: Icons.discord,
                  label: l10n.feedbackAuroraDiscord,
                  subtitle: l10n.feedbackCommunityJoin,
                  url: ContactConfig.discordInviteUrl,
                  color: const Color(0xFF5865F2),
                ),
                const SizedBox(height: 12),
              ],

              // Website
              if (ContactConfig.websiteUrl.isNotEmpty) ...[
                _buildCommunityLink(
                  context,
                  icon: Icons.language,
                  label: l10n.feedbackWebsite,
                  subtitle: ContactConfig.websiteUrl.replaceAll('https://', ''),
                  url: ContactConfig.websiteUrl,
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 12),
              ],

              // Email
              _buildCommunityLink(
                context,
                icon: Icons.email,
                label: l10n.feedbackEmail,
                subtitle: ContactConfig.supportEmail,
                url: 'mailto:${ContactConfig.supportEmail}',
                color: const Color(0xFF4CAF50),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityLink(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required String url,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _launchUrl(Uri.parse(url)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Silent fail - URL kann nicht geöffnet werden
    }
  }
}
