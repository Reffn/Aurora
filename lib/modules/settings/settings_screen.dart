import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/settings/sections/about_section.dart';
import 'package:dis_app/modules/settings/sections/debug_section.dart';
import 'package:dis_app/modules/settings/sections/location_section.dart';
import 'package:dis_app/modules/settings/sections/management_section.dart';
import 'package:dis_app/modules/settings/sections/notifications_section.dart';
import 'package:dis_app/modules/settings/sections/personal_section.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/animated_list_view.dart';
import 'package:dis_app/widgets/permission_guard.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Einstellungen. Setzt die Abschnitte aus `sections/` zusammen und
/// entscheidet, wer welchen sieht; jeder Abschnitt hält seinen Zustand selbst.
///
/// Fünf Gruppen in fester Reihenfolge (Regel 7). Jede Zeile zeigt ihren
/// Zustand und höchstens eine Handlung; Erklärungen liegen hinter ⓘ,
/// Kartenspeicher und Diagnose auf eigenen Seiten.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final sections = <Widget>[
      const SettingsPersonalSection(),
      const SettingsNotificationsSection(),
      // Wächter für „Tracking dauerhaft an“ sitzt in der Zeile selbst:
      // Standort und Offline-Karten sieht jeder Anteil.
      const SettingsLocationSection(),
      // „Anteile & Rechte“ ist auch der einzige Ort zum Pausieren und
      // Zurückholen. Wer nur „Anteile pausieren“ hat, kommt deshalb hinein;
      // die Schalter sind dort ohne „Rechte vergeben“ nur zu lesen.
      const AnyPermissionGuard(
        permissions: [
          Permission.managePermissions,
          Permission.deactivateProfiles,
        ],
        child: SettingsManagementSection(),
      ),
      const SettingsAboutSection(),
      if (kDebugMode) const SettingsDebugSection(),
    ];

    return Scaffold(
      appBar: StandardAppBar(title: l10n.settingsTitle),
      body: AnimatedListView(
        // Unten nicht fest 8: Die App läuft randlos, und ein festes Polster
        // schaltet das automatische der `ListView` ab. Am Scrollende lag
        // „Sprache“ dann unter der Navigationsleiste, und weiteres Wischen
        // half nicht, weil das Ende erreicht war (wie bei der Puzzle-Auswahl).
        padding: EdgeInsets.fromLTRB(
          8,
          8,
          8,
          context.safeBottomPaddingWithMargin(8),
        ),
        itemCount: sections.length,
        itemBuilder: (context, index) => sections[index],
      ),
    );
  }
}
