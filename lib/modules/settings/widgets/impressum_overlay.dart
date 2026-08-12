import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Impressum-Overlay - Zeigt rechtliche Informationen an
class ImpressumOverlay extends StatelessWidget {
  const ImpressumOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF1F1F1F),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Impressum',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance close button
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      l10n.imprintPerLaw,
                      '''
3ofus

Kirchstraße 3
01640 Coswig
Deutschland
''',
                    ),

                    _buildSection(
                      'Kontakt',
                      '''
E-Mail: info@3ofus.app
''',
                    ),

                    _buildSection(
                      'Vertreten durch',
                      '''
Nico Wojtera
''',
                    ),

                    _buildSection(
                      l10n.imprintResponsible,
                      '''
Nico Wojtera
Kirchstraße 3
01640 Coswig
''',
                    ),

                    _buildSection(
                      'Haftungsausschluss',
                      '''
Haftung für Inhalte

Die Inhalte unserer App wurden mit größter Sorgfalt erstellt. Für die Richtigkeit, Vollständigkeit und Aktualität der Inhalte können wir jedoch keine Gewähr übernehmen.

Als Diensteanbieter sind wir gemäß § 7 Abs.1 TMG für eigene Inhalte in dieser App nach den allgemeinen Gesetzen verantwortlich.

Haftung für Links

Diese App enthält keine Links zu externen Websites Dritter. Da die App offline funktioniert und keine Verbindung zum Internet herstellt, gibt es keine Haftung für externe Inhalte.

Urheberrecht

Die durch die Betreiber der App erstellten Inhalte und Werke in dieser App unterliegen dem deutschen Urheberrecht. Die Vervielfältigung, Bearbeitung, Verbreitung und jede Art der Verwertung außerhalb der Grenzen des Urheberrechtes bedürfen der schriftlichen Zustimmung des jeweiligen Autors bzw. Erstellers.
''',
                    ),

                    const SizedBox(height: 32),

                    Center(
                      child: Text(
                        'Stand: ${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Aurora',
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.paper,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content.trim(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
