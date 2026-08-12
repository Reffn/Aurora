import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Die Datenschutzerklärung, wie sie im Gerät steht.
///
/// Sie stand hier als hartkodierter deutscher Text und behauptete, Aurora
/// übertrage „KEINE Daten an Server, Cloud-Dienste oder Dritte" und
/// funktioniere „vollständig offline". Das war falsch: Feedback und — nach
/// Zustimmung — Telemetrie gehen an Firestore, und jede Karte lädt Kacheln
/// von OpenStreetMap. Damit standen zwei einander widersprechende Erklärungen
/// im selben Erzeugnis, und die im Gerät war die unrichtige.
///
/// Der Text folgt jetzt `docs/datenschutz.html` und läuft durch die
/// Sprachpakete. Ändert sich, was das Gerät verlässt, gehören beide Fassungen
/// mit geändert — und `docs/play-data-safety.md` dazu.
class PrivacyOverlay extends StatelessWidget {
  const PrivacyOverlay({super.key});

  /// Der Tag der letzten Änderung dieser Erklärung.
  ///
  /// Fest eingetragen, nicht aus der Uhr: Vorher stand hier das laufende Jahr,
  /// womit sich die Erklärung bei jedem Öffnen selbst für aktuell erklärte.
  /// Ein Stand, der immer heute ist, ist kein Stand.
  static const String lastChanged = '6. August 2026';

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
                  Expanded(
                    child: Text(
                      l10n.privacyTitle,
                      style: const TextStyle(
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
                      l10n.privacyAtAGlance,
                      l10n.privacyGlanceBody,
                    ),
                    _buildSection(
                      l10n.privacyWhatIsStored,
                      l10n.privacyStoredBody,
                    ),
                    _buildSection(
                      l10n.privacyTransmission,
                      l10n.privacyTransmissionBody,
                    ),
                    _buildSection(
                      l10n.privacyPermissions,
                      l10n.privacyPermissionsBody,
                    ),
                    _buildSection(
                      l10n.privacySecurity,
                      l10n.privacySecurityBody,
                    ),
                    _buildSection(
                      l10n.privacyDeletion,
                      l10n.privacyDeletionBody,
                    ),
                    _buildSection(l10n.privacyRights, l10n.privacyRightsBody),
                    _buildSection(l10n.privacyMinors, l10n.privacyMinorsBody),
                    _buildSection(l10n.privacyChanges, l10n.privacyChangesBody),
                    // Name und Anschrift stehen unübersetzt: Eine ladungsfähige
                    // Anschrift wird nicht übersetzt, sie wird abgeschrieben.
                    _buildSection(
                      l10n.privacyContact,
                      '3ofus\n'
                      'Kirchstraße 3\n'
                      '01640 Coswig\n'
                      'info@3ofus.app',
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        l10n.privacyAsOf(lastChanged),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        l10n.privacyClosing,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),
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
