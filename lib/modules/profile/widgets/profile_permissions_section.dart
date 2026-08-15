import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Widget für Berechtigungs-Slider beim Profil erstellen/bearbeiten
class ProfilePermissionsSection extends StatelessWidget {
  const ProfilePermissionsSection({
    required this.tabSliderValues,
    required this.onSliderChanged,
    required this.onApplyChildPreset,
    required this.onApplyAdultPreset,
    super.key,
  });

  final Map<String, double> tabSliderValues;
  final void Function(String tabKey, double value) onSliderChanged;
  final VoidCallback onApplyChildPreset;
  final VoidCallback onApplyAdultPreset;

  /// Was jede Stufe eines Schiebers bedeutet.
  ///
  /// Die Saetze standen vorher als deutsche Liste in dieser Methode. Sie
  /// beschreiben, was ein Anteil auf der gewaehlten Stufe darf -- wer sie
  /// nicht lesen kann, schiebt blind.
  Map<String, List<String>> _getSliderDescriptions(AppLocalizations l10n) {
    return {
      'chat': [l10n.sliderChat0, l10n.sliderChat1],
      'calendar': [
        l10n.sliderCalendar0,
        l10n.sliderCalendar1,
        l10n.sliderCalendar2,
        l10n.sliderCalendar3,
      ],
      'medication': [
        l10n.sliderMedication0,
        l10n.sliderMedication1,
        l10n.sliderMedication2,
      ],
      'diary': [
        l10n.sliderDiary0,
        l10n.sliderDiary1,
        l10n.sliderDiary2,
        l10n.sliderDiary3,
      ],
      'contacts': [
        l10n.sliderContacts0,
        l10n.sliderContacts1,
        l10n.sliderContacts2,
        l10n.sliderContacts3,
      ],
      'finder': [
        l10n.sliderFinder0,
        l10n.sliderFinder1,
        l10n.sliderFinder2,
      ],
      'emergencyDiary': [
        l10n.sliderEmergencyDiary0,
        l10n.sliderEmergencyDiary1,
        l10n.sliderEmergencyDiary2,
        l10n.sliderEmergencyDiary3,
      ],
      'emergency': [
        l10n.sliderEmergency0,
        l10n.sliderEmergency1,
        l10n.sliderEmergency2,
        l10n.sliderEmergency3,
      ],
      'help': [l10n.sliderHelp0, l10n.sliderHelp1],
      'mantras': [l10n.sliderMantras0, l10n.sliderMantras1],
      'games': [l10n.sliderGames0, l10n.sliderGames1],
    };
  }

  /// Baut einen einzelnen Tab-Slider
  Widget _buildTabSlider({
    required BuildContext context,
    required String tabKey,
    required IconData icon,
    required String label,
    int maxLevel = 3, // Anzahl der Stufen (default: 4 Stufen = 0-3)
  }) {
    final l10n = AppLocalizations.of(context);
    final currentValue = tabSliderValues[tabKey] ?? 0.0;
    final descriptions = _getSliderDescriptions(l10n)[tabKey]!;
    final currentDescription = descriptions[currentValue.toInt()];

    // Farbe basierend auf Level
    Color sliderColor;
    if (currentValue == 0) {
      sliderColor = Colors.red;
    } else if (currentValue == maxLevel) {
      sliderColor = Colors.green;
    } else {
      sliderColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sliderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Label
          Row(
            children: [
              Icon(
                icon,
                color: sliderColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: sliderColor,
                  ),
                ),
              ),
              // Level-Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: sliderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.permissionsLevel(currentValue.toInt()),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: sliderColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: sliderColor,
              thumbColor: sliderColor,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              overlayColor: sliderColor.withValues(alpha: 0.3),
            ),
            child: Slider(
              value: currentValue,
              max: maxLevel.toDouble(),
              divisions: maxLevel,
              onChanged: (value) => onSliderChanged(tabKey, value),
            ),
          ),

          // Beschreibung
          Text(
            currentDescription,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.paper.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info-Text
        Text(
          l10n.permissionsSectionExplanation,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.paper.withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Preset-Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onApplyChildPreset,
                icon: Icon(
                  Icons.child_care,
                  size: 18,
                  color: Colors.blue[300],
                ),
                label: Text(
                  l10n.permissionsChildPreset,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[200],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[200],
                  side: BorderSide(
                    color: Colors.blue.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  backgroundColor: Colors.blue.withValues(alpha: 0.05),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onApplyAdultPreset,
                icon: Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.green[300],
                ),
                label: Text(
                  l10n.permissionsAdultPreset,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[200],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[200],
                  side: BorderSide(
                    color: Colors.green.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  backgroundColor: Colors.green.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Alle 11 Tab-Slider
        _buildTabSlider(
          context: context,
          tabKey: 'chat',
          icon: Icons.chat,
          label: l10n.permissionsCategoryChat,
          maxLevel: 1, // 2 Stufen (0-1)
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'calendar',
          icon: Icons.calendar_today,
          label: l10n.permissionsCategoryCalendar,
          // 4 Stufen (0-3) - default
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'medication',
          icon: Icons.medical_services,
          label: l10n.permissionsCategoryMedication,
          maxLevel: 2, // 3 Stufen (0-2)
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'diary',
          icon: Icons.book,
          label: l10n.permissionsCategoryDiary,
          // 4 Stufen (0-3) - default
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'contacts',
          icon: Icons.contacts,
          label: l10n.permissionsCategoryContacts,
          // 4 Stufen (0-3) - default
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'finder',
          icon: Icons.search,
          label: l10n.permissionsCategoryFinder,
          maxLevel: 2, // 3 Stufen (0-2)
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'emergencyDiary',
          icon: Icons.warning_amber,
          label: l10n.permissionsCategoryEmergencyDiary,
          // 4 Stufen (0-3) - default
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'emergency',
          icon: Icons.emergency,
          label: l10n.permissionsCategoryEmergency,
          // 4 Stufen (0-3) - default
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'help',
          icon: Icons.help,
          label: l10n.permissionsCategoryHelp,
          maxLevel: 1, // 2 Stufen (0-1)
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'mantras',
          icon: Icons.spa,
          label: l10n.permissionsCategoryMantras,
          maxLevel: 1, // 2 Stufen (0-1)
        ),
        _buildTabSlider(
          context: context,
          tabKey: 'games',
          icon: Icons.games,
          label: l10n.permissionsCategoryGames,
          maxLevel: 1, // 2 Stufen (0-1)
        ),

        const SizedBox(height: 8),

        // Hinweis für nachträgliche Anpassung
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.paper.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.permissionsChangeableLater,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.paper.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
