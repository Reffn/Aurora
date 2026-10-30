import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/settings/screens/diagnostics_screen.dart';
import 'package:dis_app/modules/settings/sections/settings_section_parts.dart';
import 'package:dis_app/modules/settings/widgets/impressum_overlay.dart';
import 'package:dis_app/modules/settings/widgets/privacy_overlay.dart';
import 'package:dis_app/modules/transparency/transparency_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Über Aurora: was Aurora sendet, Datenschutz, Impressum, Diagnose und die
/// Fassung.
///
/// „Was Aurora sendet“ steht oben und auf dem Hauptschirm, nicht auf einer
/// Unterseite: Dort liegt der Schalter für die Telemetrie, und dass jede
/// Übertragung einsehbar ist, ist eine Zusage.
class SettingsAboutSection extends StatefulWidget {
  const SettingsAboutSection({super.key});

  @override
  State<SettingsAboutSection> createState() => _SettingsAboutSectionState();
}

class _SettingsAboutSectionState extends State<SettingsAboutSection>
    with AutomaticKeepAliveClientMixin {
  // Die Liste baut weit entfernte Abschnitte ab. Laufende Abläufe,
  // geladene Zahlen und Schalterzustände sollen das überleben.
  @override
  bool get wantKeepAlive => true;

  String _appVersion = '...'; // Will be loaded in initState

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(l10n.settingsSectionAbout),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(
              Icons.outbox_outlined,
              color: Colors.blue,
              size: 28,
            ),
            title: Text(
              l10n.settingsWhatAuroraSends,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.settingsWhatAuroraSendsSubtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const TransparencyScreen(),
              ),
            ),
          ),
        ),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: Colors.green,
              size: 28,
            ),
            title: Text(
              l10n.settingsPrivacy,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.settingsPrivacySubtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog<bool?>(
                context: context,
                builder: (context) => const PrivacyOverlay(),
              );
            },
          ),
        ),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(
              Icons.article_outlined,
              color: Colors.blue,
              size: 28,
            ),
            title: Text(
              l10n.settingsImpressum,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.settingsImpressumSubtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog<bool?>(
                context: context,
                builder: (context) => const ImpressumOverlay(),
              );
            },
          ),
        ),

        // Debug-Log und vorgemerkte Erinnerungen: wichtig, wenn etwas nicht
        // geht, sonst nicht. Deshalb eine Zeile statt zwei Kästen.
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.troubleshoot, size: 28),
            title: Text(
              l10n.settingsDiagnosticsTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const DiagnosticsScreen(),
              ),
            ),
          ),
        ),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Colors.grey.shade400,
              size: 28,
            ),
            title: Text(
              l10n.settingsAppVersion,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              _appVersion,
              style: const TextStyle(fontSize: 12),
            ),
            enabled: false,
          ),
        ),

        const Divider(height: 32),
      ],
    );
  }
}
