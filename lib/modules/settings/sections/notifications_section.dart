import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/settings/sections/settings_section_parts.dart';
import 'package:dis_app/modules/settings/widgets/settings_info_sheet.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';

/// Benachrichtigungen: diskrete Erinnerungen und Testmeldung. Wie
/// Erinnerungen arbeiten, steht hinter dem ⓘ; wie viele das System
/// vorgemerkt hat, unter Diagnose.
class SettingsNotificationsSection extends StatefulWidget {
  const SettingsNotificationsSection({super.key});

  @override
  State<SettingsNotificationsSection> createState() =>
      _SettingsNotificationsSectionState();
}

class _SettingsNotificationsSectionState
    extends State<SettingsNotificationsSection>
    with AutomaticKeepAliveClientMixin {
  // Die Liste baut weit entfernte Abschnitte ab. Laufende Abläufe,
  // geladene Zahlen und Schalterzustände sollen das überleben.
  @override
  bool get wantKeepAlive => true;

  late final _notificationService = getIt<NotificationService>();

  /// Zeigt die Erinnerung ihren Inhalt auf dem Sperrbildschirm?
  bool get _discreetReminders => _notificationService.discreetReminders;

  Future<void> _setDiscreetReminders(bool value) async {
    await _notificationService.setDiscreetReminders(value);
    if (mounted) setState(() {});
  }

  /// Send test notification
  Future<void> _sendTestNotification() async {
    final l10n = AppLocalizations.of(context);
    try {
      await _notificationService.sendTestNotification();

      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.settingsTestNotificationSent,
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.errorWithDetail(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _zeigeErklaerung() {
    final l10n = AppLocalizations.of(context);
    return showSettingsInfoSheet(
      context,
      title: l10n.settingsHowNotificationsWork,
      children: [
        SettingsInfoParagraph(l10n.settingsNotificationsSubtitle),
        SettingsBulletPoint(l10n.settingsNotificationsBullet1),
        SettingsBulletPoint(l10n.settingsNotifAsNeeded),
        SettingsBulletPoint(l10n.settingsNotificationsBullet3),
        SettingsBulletPoint(l10n.settingsNotifWorksClosed),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
          l10n.settingsSectionNotifications,
          trailing: SettingsInfoButton(onPressed: _zeigeErklaerung),
        ),

        // Diskrete Erinnerungen
        //
        // Eine Erinnerung erscheint auf dem Sperrbildschirm, also auch vor
        // Augen, für die sie nicht gedacht ist. Wer nicht allein wohnt,
        // schaltet hier den Inhalt ab.
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SwitchListTile(
            secondary: const Icon(Icons.visibility_off),
            title: Text(l10n.settingsDiscreetRemindersTitle),
            subtitle: Text(
              _discreetReminders
                  ? l10n.settingsDiscreetRemindersOn
                  : l10n.settingsDiscreetRemindersOff,
            ),
            value: _discreetReminders,
            onChanged: _setDiscreetReminders,
          ),
        ),

        // Test Notification Button
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(
              Icons.notification_add,
              color: Colors.blue,
              size: 28,
            ),
            title: Text(
              l10n.settingsSendTestNotification,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.settingsCheckNotificationsWork,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _sendTestNotification,
          ),
        ),

        const Divider(height: 32),
      ],
    );
  }
}
