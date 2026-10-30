import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/permissions/permissions_manager_screen.dart';
import 'package:dis_app/modules/settings/sections/settings_section_parts.dart';
import 'package:flutter/material.dart';

/// Verwaltung: der Weg zu „Anteile & Rechte“. Wer ihn sieht, entscheidet
/// `SettingsScreen`.
///
/// Eine Zeile ohne Erklärung: Was dort geht, zeigt der Schirm selbst. Das
/// Symbol ist ruhig; Bernstein sah nach Warnung aus, und kräftige Farbe
/// gehört Halt, Notfall und Hilfe (Regel 4).
class SettingsManagementSection extends StatelessWidget {
  const SettingsManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(l10n.settingsSectionManagement),
        Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: ListTile(
            leading: const Icon(Icons.admin_panel_settings, size: 28),
            title: Text(
              l10n.partsAndRightsTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (context) => const PermissionsManagerScreen(),
              ),
            ),
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }
}
