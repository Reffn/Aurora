import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/startup_locale.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/supported_languages.dart';
import 'package:dis_app/modules/settings/sections/settings_section_parts.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// „Für dich“: Sprache und Zeitformat.
class SettingsPersonalSection extends StatelessWidget {
  const SettingsPersonalSection({super.key});

  String _getTimeFormatLabel(String format, AppLocalizations l10n) {
    switch (format) {
      case '12h':
        return l10n.settingsTimeFormat12h;
      case '24h':
        return l10n.settingsTimeFormat24h;
      case 'system':
      default:
        return l10n.settingsTimeFormatSystem;
    }
  }

  /// Verfügbare Sprachen mit Flaggen-Emojis
  static const _availableLanguages = [
    ('de', '🇩🇪', 'Deutsch'),
    ('en', '🇬🇧', 'English'),
    ('es', '🇪🇸', 'Español'),
    ('fr', '🇫🇷', 'Français'),
    ('it', '🇮🇹', 'Italiano'),
  ];

  String _getLanguageName(String? localeCode, AppLocalizations l10n) {
    if (localeCode == null) return l10n.miscSystemDefault;
    for (final lang in _availableLanguages) {
      if (lang.$1 == localeCode) {
        return '${lang.$2} ${lang.$3}';
      }
    }
    return l10n.miscSystemDefault;
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    String? currentLocale,
  ) async {
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsLanguage),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _availableLanguages.map((lang) {
              final (code, flag, name) = lang;
              final isSelected = currentLocale == code;

              return ListTile(
                leading: Text(flag, style: const TextStyle(fontSize: 24)),
                title: Text(name),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                selected: isSelected,
                onTap: () async {
                  // Hol context vor dem await
                  final nav = Navigator.of(dialogContext);
                  final snackContext = dialogContext;
                  final successMsg = '✅ ${l10n.settingsLanguageChanged}';
                  await getIt<DataEntry>().settingsBox.put(
                    'selected_locale',
                    code,
                  );
                  // Damit schon der nächste Ladebildschirm diese Sprache
                  // spricht — er kommt zu früh, um Hive zu fragen.
                  await StartupLocale.merken(code);
                  if (context.mounted && snackContext.mounted) {
                    nav.pop();
                    showCustomSnackBar(
                      snackContext,
                      message: successMsg,
                      type: SnackBarType.success,
                    );
                  }
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.actionCancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(l10n.settingsSectionPersonal),

        // Sprach-Einstellung
        ValueListenableBuilder(
          valueListenable: getIt<DataEntry>().settingsBox.listenable(),
          builder: (context, box, _) {
            final currentLocale = box.get('selected_locale') as String?;
            final currentLanguageName = _getLanguageName(
              currentLocale,
              l10n,
            );
            // Die Sprache des Anteils geht vor (main.dart). Ohne diesen
            // Satz stand hier „Deutsch ✓", während alles Italienisch
            // sprach — und ein Wechsel meldete „Sprache geändert",
            // ohne dass sich etwas änderte (Smoketest 06.10.2026).
            final eigene = getIt<DataEntry>()
                .getActiveProfile()
                ?.preferredLanguage;
            final eigeneGilt = eigene != null && eigene != currentLocale;

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Colors.teal,
                  size: 28,
                ),
                title: Text(
                  l10n.settingsLanguage,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  eigeneGilt
                      ? '$currentLanguageName\n'
                            '${l10n.settingsLanguageProfileWins(languageNameFor(eigene) ?? eigene)}'
                      : currentLanguageName,
                  style: const TextStyle(fontSize: 12),
                ),
                isThreeLine: eigeneGilt,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, currentLocale),
              ),
            );
          },
        ),

        // Zeitformat-Einstellung
        ValueListenableBuilder(
          valueListenable: getIt<DataEntry>().settingsBox.listenable(),
          builder: (context, box, _) {
            final currentFormat =
                box.get('time_format_preference', defaultValue: 'system')
                    as String;

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.access_time,
                  color: Colors.blue,
                  size: 28,
                ),
                title: Text(
                  l10n.settingsTimeFormat,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  _getTimeFormatLabel(currentFormat, l10n),
                  style: const TextStyle(fontSize: 12),
                ),
                children: [
                  RadioGroup<String>(
                    groupValue: currentFormat,
                    onChanged: (value) {
                      getIt<DataEntry>().settingsBox.put(
                        'time_format_preference',
                        value,
                      );
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(l10n.settingsTimeFormatSystem),
                          subtitle: Text(
                            l10n.settingsTimeFormatSystemSubtitle,
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: 'system',
                        ),
                        RadioListTile<String>(
                          title: Text(l10n.settingsTimeFormat12h),
                          subtitle: Text(
                            l10n.settingsTimeFormat12hExample,
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: '12h',
                        ),
                        RadioListTile<String>(
                          title: Text(l10n.settingsTimeFormat24h),
                          subtitle: Text(
                            l10n.settingsTimeFormat24hExample,
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: '24h',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const Divider(height: 32),
      ],
    );
  }
}
