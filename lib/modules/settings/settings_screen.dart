import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/delete_all_data.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/startup_locale.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/permissions/permissions_manager_screen.dart';
import 'package:dis_app/modules/settings/widgets/impressum_overlay.dart';
import 'package:dis_app/modules/settings/widgets/privacy_overlay.dart';
import 'package:dis_app/modules/transparency/transparency_screen.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/navigation_service.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:dis_app/services/password_reset_service.dart';
import 'package:dis_app/services/tile_cache_manager.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/debug_log_generator.dart';
import 'package:dis_app/widgets/animated_list_view.dart';
import 'package:dis_app/widgets/debug_log_overlay.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/permission_guard.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Einstellungen-Screen
/// Geplante Features:
/// - App-Konfiguration
/// - Datenschutz-Einstellungen
/// - Datenbank-Backup/Restore
/// - PIN/Biometrie-Schutz
/// - Theme-Anpassungen
/// - Benachrichtigungs-Einstellungen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _navigationService = getIt<NavigationService>();
  late final _tileCacheManager = getIt<TileCacheManager>();
  late final _gpsManager = getIt<GpsManager>();
  late final _trackingService = getIt<LocationTrackingService>();
  late final _notificationService = getIt<NotificationService>();

  /// Wie viele Erinnerungen beim Betriebssystem vorgemerkt sind.
  ///
  /// Einmal beim Oeffnen geholt, nicht im `build`: dort erzeugte jeder
  /// Neuaufbau ein neues Future und damit einen weiteren Umlauf zum
  /// Benachrichtigungs-Plugin. Dieselbe Falle, die die Avatare langsam
  /// gemacht hat.
  late final Future<int> _vorgemerkteErinnerungen = _notificationService
      .countScheduledReminders();

  /// Groesse und Anzahl der Kartenkacheln, ebenfalls einmal beim Oeffnen und
  /// nicht im `build` -- dort entstand pro Neuaufbau ein neues Future auf den
  /// Kachelspeicher.
  late final Future<Map<String, dynamic>> _kachelZahlen =
      Future.wait([
        _tileCacheManager.getCacheSizeMB(),
        _tileCacheManager.getTileCount(),
      ]).then(
        (results) => {
          'sizeMB': results[0],
          'count': results[1],
          'limitMB': _tileCacheManager.maxCacheSizeMB,
        },
      );
  bool _isDeleting = false;
  bool _isGeneratingLog = false;
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

  Future<void> _showLanguageDialog(String? currentLocale) async {
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
                  final nav = Navigator.of(context);
                  final snackContext = context;
                  final successMsg = '✅ ${l10n.settingsLanguageChanged}';
                  await getIt<DataEntry>().settingsBox.put(
                    'selected_locale',
                    code,
                  );
                  // Damit schon der nächste Ladebildschirm diese Sprache
                  // spricht — er kommt zu früh, um Hive zu fragen.
                  await StartupLocale.merken(code);
                  if (mounted && snackContext.mounted) {
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
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: l10n.settingsDeleteConfirmTitle,
      message: l10n.settingsDeleteConfirmMessage,
      actionText: l10n.settingsDeleteAll,
    );

    if (confirmed) {
      await _deleteAllData();
    }
  }

  Future<void> _clearMapCache() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: l10n.settingsClearCache,
      message:
          '${l10n.settingsMapCacheClearQuestion}\n\n'
          '${l10n.settingsCacheClearHint}',
      confirmText: l10n.settingsClearCache,
      confirmColor: Colors.orange,
      icon: Icons.delete_sweep,
    );

    if (confirmed == ConfirmationResult.confirm) {
      try {
        await _tileCacheManager.clearCache();
        if (mounted) {
          showCustomSnackBar(
            context,
            message: l10n.settingsMapCacheCleared,
            type: SnackBarType.success,
          );
          setState(() {}); // Trigger rebuild
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
  }

  Future<void> _showPreDownloadDialog() async {
    final l10n = AppLocalizations.of(context);
    // TODO: Implement pre-download dialog with radius selection
    // Will be implemented in Phase 4
    if (mounted) {
      showCustomSnackBar(
        context,
        message: l10n.settingsMapPredownloadComingSoon,
      );
    }
  }

  Future<void> _showCacheLimitDialog() async {
    final l10n = AppLocalizations.of(context);
    final currentLimit = _tileCacheManager.maxCacheSizeMB;
    var newLimit = currentLimit.toDouble();

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.settingsCacheLimitTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsCacheLimitValue(newLimit.round()),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: newLimit,
                min: 100,
                max: 2000,
                divisions: 19,
                label: l10n.settingsCacheLimitMegabytes(newLimit.round()),
                onChanged: (value) {
                  setDialogState(() {
                    newLimit = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settingsCacheLimitExplanation,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, newLimit.round()),
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );

    if (result != null && result != currentLimit) {
      try {
        await _tileCacheManager.setMaxCacheSizeMB(result);
        if (mounted) {
          showCustomSnackBar(
            context,
            message: l10n.settingsCacheLimitSet(result),
            type: SnackBarType.success,
          );
          setState(() {}); // Trigger rebuild
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
  }

  /// Generiert Debug-Log und zeigt Overlay
  Future<void> _generateDebugLog() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isGeneratingLog = true;
    });

    try {
      // Generiere Debug-Report
      final logContent = await DebugLogGenerator.generateFullReport();

      if (mounted) {
        setState(() {
          _isGeneratingLog = false;
        });

        // Zeige Overlay mit Logs
        await showDialog<void>(
          context: context,
          builder: (context) => DebugLogOverlay(logContent: logContent),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingLog = false;
        });

        showCustomSnackBar(
          context,
          message: l10n.settingsDebugLogError(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _deleteAllData() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isDeleting = true;
    });

    try {
      // Ein einziger Löschweg für Einstellungen und Notfall-Reset. Vorher
      // stand hier eine eigene Fassung, die Boxen und Anhänge kannte, den
      // Standortverlauf und das Übertragungsprotokoll aber nicht — und die
      // Löschfehler verschluckte, um danach Erfolg zu melden.
      final ergebnis = await deleteAllLocalData();
      await _navigationService.clearAll();

      if (mounted) {
        showCustomSnackBar(
          context,
          message: ergebnis.isComplete
              ? l10n.settingsAllDataDeleted
              : l10n.settingsDeleteIncomplete,
          type: ergebnis.isComplete ? SnackBarType.success : SnackBarType.error,
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
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _toggleGlobalTracking(bool enable, bool canEnable) async {
    final l10n = AppLocalizations.of(context);
    final settingsBox = Hive.box<dynamic>('settings');

    if (enable) {
      // Enabling: Check permission first
      if (!canEnable) {
        if (mounted) {
          showCustomSnackBar(
            context,
            message: l10n.settingsTrackingPermissionRequired,
            type: SnackBarType.warning,
          );
        }
        return;
      }

      // Show detailed explanation dialog
      //
      // Der Dialog nennt den Stand, den das System wirklich hält. Vorher stand
      // hier „Immer erlaubt (Bereit!)", sobald die Aufzeichnung laufen durfte —
      // seit „Bei Nutzung" genügt, wäre das schlicht falsch gewesen.
      final permissionStatus = _gpsManager.hasAlwaysPermission
          ? l10n.settingsGpsStatusAlways
          : _gpsManager.hasWhileInUsePermission
          ? l10n.settingsGpsWhileInUse
          : l10n.settingsGpsStatusLine(l10n.settingsGpsNotAllowed);

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.my_location, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.settingsTrackingEnableTitle,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsTrackingWhatItDoes,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                _buildBulletPoint(l10n.settingsGpsBackgroundRuns),
                _buildBulletPoint(l10n.settingsGpsOverridesAll),
                _buildBulletPoint(l10n.permissionTrackingBullet3),
                const SizedBox(height: 16),

                // Privacy Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.settingsDataStaysHere,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.settingsLocalOnly,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Battery Warning
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.battery_alert,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.settingsBackgroundGpsBattery,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Permission Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _gpsManager.hasTrackingPermission
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _gpsManager.hasTrackingPermission
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _gpsManager.hasTrackingPermission
                            ? Icons.check_circle
                            : Icons.warning,
                        color: _gpsManager.hasTrackingPermission
                            ? Colors.green
                            : Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.settingsAndroidStatus,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              permissionStatus,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.settingsActivate),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Enable global tracking
      await settingsBox.put('global_tracking_always_on', true);

      // Frisch beim System nachfragen statt den zwischengespeicherten Wert zu
      // lesen: Die Nutzerin kommt hier oft direkt aus den Systemeinstellungen
      // zurück, und die Auffrischung beim Wiedereintritt läuft nebenläufig.
      if (await _gpsManager.refreshAndCheckTrackingPermission()) {
        // Läuft die Aufzeichnung gerade? Nicht: ist sie gewünscht.
        //
        // Hier stand `settingsBox.get('gps_tracking_enabled')` — das ist der
        // Wunsch, und der bleibt absichtlich stehen, wenn der Positionsstrom
        // abbricht (GPS aus, Berechtigung entzogen, Dienst gestorben). Wer
        // danach „immer aufzeichnen" bestätigte, traf auf einen Wunsch, der
        // schon `true` war — also wurde nicht gestartet, und es lief nichts.
        // Bestätigt, und Stille. Bei einer Funktion, deren Zweck „wo war ich?"
        // nach einem Blackout ist.
        if (!_trackingService.isTrackingRunning.value) {
          await _trackingService.toggleTracking();
        }

        if (mounted) {
          showCustomSnackBar(
            context,
            message: l10n.settingsTrackingEnabled,
            type: SnackBarType.success,
          );
        }
      } else {
        // Permission missing - Show guidance dialog
        if (mounted) {
          await _showPermissionGuidanceDialog();
        }
      }
    } else {
      // Disabling: Show confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.settingsTrackingDisableTitle),
          content: Text(
            l10n.settingsTrackingDisableFull,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.settingsDeactivate),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Disable global tracking
      await settingsBox.put('global_tracking_always_on', false);

      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.settingsTrackingDisabled,
        );
      }
    }
  }

  // Helper Widget: Instruction Step für Schritt-für-Schritt Anleitung
  Widget _buildInstructionStep({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget: Bullet Point für Listen
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  // Permission Guidance Dialog - Zeigt Anleitung wenn Permission fehlt
  Future<void> _showPermissionGuidanceDialog() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.settingsAndroidSettingNeeded,
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsTrackingPermissionNeeded,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.settingsStepByStep,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              // Schritt 1
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 12,
                          child: Text(
                            '1',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.settingsOpenAndroidSettings,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _gpsManager.openAppSettings();
                        },
                        icon: const Icon(Icons.settings, size: 18),
                        label: Text(l10n.settingsOpenNow),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Schritt 2 & 3
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 12,
                          child: Text(
                            '2',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.settingsInTheSettings,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildBulletPoint(l10n.settingsStepTapPermission),
                    _buildBulletPoint(l10n.settingsStepTapLocation),
                    _buildBulletPoint(l10n.settingsStepChooseWhileUsing),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Schritt 3 - Zurück
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 12,
                      child: Text(
                        '3',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.settingsBackToAurora,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settingsUnderstood),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build list of all settings items
    final settingsItems = <Widget>[];

    // Add items to list based on conditions
    void addItems(List<Widget> items) {
      settingsItems.addAll(items);
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: StandardAppBar(title: l10n.settingsTitle),
      body: Builder(
        builder: (context) {
          settingsItems.clear(); // Reset on rebuild

          addItems([
            // Debug-Section (nur in Entwicklung sichtbar)
            if (kDebugMode) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.settingsSectionDebug,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.settingsDebugInfo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Debug-Button: Reset-Timer auf 20s setzen
              ValueListenableBuilder(
                valueListenable: getIt<DataEntry>().profilesBox.listenable(),
                builder: (context, Box<Profile> box, _) {
                  final passwordResetService = getIt<PasswordResetService>();
                  // Fristen sitzen am Profil; für den Debug-Sprung zählt der
                  // erste noch laufende Reset.
                  final laufend = box.values
                      .where((p) => p.hasActiveReset && !p.isResetExpired)
                      .toList();

                  if (laufend.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final profile = laufend.first;
                  final profileName = profile.name;
                  final rest = profile.resetEndsAt!.difference(DateTime.now());

                  final timeText = rest.inHours > 0
                      ? '${rest.inHours}h ${rest.inMinutes.remainder(60)}m'
                      : rest.inMinutes > 0
                      ? '${rest.inMinutes}m ${rest.inSeconds.remainder(60)}s'
                      : '${rest.inSeconds.clamp(0, 60)}s';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.orange.shade900.withValues(alpha: 0.3),
                    child: ListTile(
                      leading: const Icon(
                        Icons.fast_forward,
                        color: Colors.orange,
                        size: 32,
                      ),
                      title: Text(
                        l10n.settingsDebugSkipCooldown,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        l10n.settingsResetPendingFor(profileName, timeText),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        // Hol context vor dem await
                        final snackContext = context;
                        final success = await passwordResetService
                            .skipToLastTwentySeconds(profile.id);
                        if (mounted && snackContext.mounted) {
                          showCustomSnackBar(
                            snackContext,
                            message: success
                                ? l10n.settingsDebugCooldownSet
                                : l10n.settingsDebugCooldownError,
                            type: success
                                ? SnackBarType.warning
                                : SnackBarType.error,
                          );
                        }
                      },
                    ),
                  );
                },
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.red.shade900.withValues(alpha: 0.3),
                child: ListTile(
                  leading: _isDeleting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                          size: 32,
                        ),
                  title: Text(
                    l10n.settingsDeleteAllData,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    l10n.settingsDeleteAllDataSubtitle,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: _isDeleting
                      ? null
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  enabled: !_isDeleting,
                  onTap: _isDeleting ? null : _showDeleteConfirmation,
                ),
              ),
              const Divider(height: 32),
            ],

            // Permissions Section (nur für Admins)
            PermissionGuard(
              permission: Permission.managePermissions,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l10n.settingsSectionManagement,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.amber,
                        size: 32,
                      ),
                      title: Text(
                        l10n.settingsPermissions,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        l10n.settingsPermissionsSubtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                const PermissionsManagerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 32),
                ],
              ),
            ),

            // Globale Einstellungen Section (Admin Only)
            PermissionGuard(
              permission: Permission.managePermissions,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l10n.settingsSectionGlobal,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Erklärungstext: Was ist "Tracking dauerhaft an"?
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            // Flexible, sonst laeuft die Zeile ueber, sobald die
                            // Uebersetzung laenger ist als die deutsche Vorlage.
                            Flexible(
                              child: Text(
                                l10n.settingsWhatIsAlwaysOn,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.settingsAdminTrackingExplanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildBulletPoint(l10n.settingsPositionAlways),
                        _buildBulletPoint(l10n.settingsGlobalTrackingBullet2),
                        _buildBulletPoint(l10n.settingsOverridesProfiles),
                        _buildBulletPoint(l10n.settingsAllProfilesTracked),
                        const SizedBox(height: 12),
                        // Kein Warnton mehr. Hier stand die Voraussetzung
                        // „Immer erlauben" in Orange — eine Hürde, die es nicht
                        // mehr gibt. Was jetzt hier steht, ist eine Zusage:
                        // Aufgezeichnet wird nur, solange die Benachrichtigung
                        // steht. Gesättigte Farbe gehört dem, was im
                        // schlechtesten Zustand gefunden werden muss.
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.settingsTrackingNotice,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // GPS Permission Status Card
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.gps_fixed,
                                color: Colors.blue,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.settingsGpsPermission,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder(
                            valueListenable: _gpsManager.hasGpsPermission,
                            builder: (context, hasPermission, _) {
                              return ValueListenableBuilder(
                                valueListenable:
                                    _gpsManager.isGpsServiceEnabled,
                                builder: (context, serviceEnabled, _) {
                                  return ValueListenableBuilder<
                                    LocationPermission
                                  >(
                                    valueListenable:
                                        _gpsManager.permissionStatus,
                                    builder: (context, permission, _) {
                                      // Determine status
                                      String statusText;
                                      Color statusColor;
                                      IconData statusIcon;

                                      if (!serviceEnabled) {
                                        statusText =
                                            l10n.settingsGpsStatusDisabled;
                                        statusColor = Colors.red;
                                        statusIcon = Icons.location_off;
                                      } else if (permission ==
                                          LocationPermission.denied) {
                                        statusText =
                                            l10n.settingsGpsStatusDenied;
                                        statusColor = Colors.orange;
                                        statusIcon = Icons.location_disabled;
                                      } else if (permission ==
                                          LocationPermission.deniedForever) {
                                        statusText =
                                            l10n.settingsGpsStatusDeniedForever;
                                        statusColor = Colors.red;
                                        statusIcon = Icons.block;
                                      } else if (permission ==
                                          LocationPermission.whileInUse) {
                                        // Grün, nicht gelb: Seit die Aufzeichnung
                                        // an einem Vordergrunddienst hängt, ist
                                        // „Bei Nutzung" der Zielzustand und kein
                                        // Mangel. Die gelbe Warnung verlangte eine
                                        // Freigabe, die es nicht mehr zu erteilen
                                        // gibt.
                                        statusText = l10n.settingsGpsWhileInUse;
                                        statusColor = Colors.green;
                                        statusIcon = Icons.check_circle;
                                      } else if (_gpsManager
                                          .hasTrackingPermission) {
                                        statusText =
                                            l10n.settingsGpsStatusAlways;
                                        statusColor = Colors.green;
                                        statusIcon = Icons.check_circle;
                                      } else {
                                        statusText =
                                            l10n.settingsGpsStatusUnknown;
                                        statusColor = Colors.grey;
                                        statusIcon = Icons.help_outline;
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Status Row
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: statusColor,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  statusIcon,
                                                  color: statusColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    statusText,
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 16),

                                          // Unterschiedliche Inhalte je nach Permission-Status
                                          if (_gpsManager
                                                  .hasTrackingPermission &&
                                              serviceEnabled) ...[
                                            // Success State
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      l10n.settingsBackgroundReady,
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.9,
                                                            ),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ] else ...[
                                            // Needs Configuration State - Ausführliche Anleitung
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Erklärung
                                                Text(
                                                  l10n.settingsHowToEnableLocation,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.9),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),

                                                // Schritt 1
                                                _buildInstructionStep(
                                                  number: '1',
                                                  text: l10n
                                                      .settingsStepOpenSettings,
                                                ),
                                                const SizedBox(height: 8),

                                                // Schritt 2
                                                _buildInstructionStep(
                                                  number: '2',
                                                  text: l10n
                                                      .settingsStepPermissionLocation,
                                                ),
                                                const SizedBox(height: 8),

                                                // Schritt 3
                                                _buildInstructionStep(
                                                  number: '3',
                                                  text: l10n
                                                      .settingsStepChooseWhileUsing,
                                                ),
                                                const SizedBox(height: 16),

                                                // Action Button
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      if (!serviceEnabled) {
                                                        await _gpsManager
                                                            .openLocationSettings();
                                                      } else {
                                                        await _gpsManager
                                                            .openAppSettings();
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.settings,
                                                      size: 20,
                                                    ),
                                                    label: Text(
                                                      !serviceEnabled
                                                          ? l10n.settingsOpenGpsSettings
                                                          : l10n.settingsOpenAndroidSettings,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 14,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),

                                                // Privacy-Hinweis
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.blue
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Icon(
                                                        Icons.lock,
                                                        color: Colors.blue,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          l10n.settingsLocationStaysOffline,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.8,
                                                                ),
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Global Tracking Toggle Card
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: Hive.box<dynamic>('settings').listenable(
                        keys: ['global_tracking_always_on'],
                      ),
                      builder: (context, box, _) {
                        final isGlobalTrackingOn =
                            box.get(
                                  'global_tracking_always_on',
                                  defaultValue: false,
                                )
                                as bool;

                        return ValueListenableBuilder(
                          valueListenable: _gpsManager.hasGpsPermission,
                          builder: (context, hasPermission, _) {
                            return ValueListenableBuilder(
                              valueListenable: _gpsManager.isGpsServiceEnabled,
                              builder: (context, serviceEnabled, _) {
                                return ValueListenableBuilder<
                                  LocationPermission
                                >(
                                  valueListenable: _gpsManager.permissionStatus,
                                  builder: (context, permission, _) {
                                    final canEnable =
                                        _gpsManager.hasTrackingPermission &&
                                        serviceEnabled;

                                    return ListTile(
                                      leading: Icon(
                                        isGlobalTrackingOn
                                            ? Icons.my_location
                                            : Icons.location_off,
                                        color: isGlobalTrackingOn
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 28,
                                      ),
                                      title: Text(
                                        l10n.settingsTrackingAlwaysOn,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        isGlobalTrackingOn
                                            ? l10n.settingsGpsRunsForAll
                                            : canEnable
                                            ? l10n.settingsTrackingPermanentOff
                                            : l10n.settingsTrackingPermissionRequired,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      trailing: Switch(
                                        value: isGlobalTrackingOn,
                                        onChanged:
                                            canEnable || isGlobalTrackingOn
                                            ? (value) => _toggleGlobalTracking(
                                                value,
                                                canEnable,
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const Divider(height: 32),
                ],
              ),
            ),

            // Rechtliches Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.settingsSectionLegal,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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

            // Diagnose & Support Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.settingsSectionDiagnostics,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: _isGeneratingLog
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      )
                    : const Icon(
                        Icons.bug_report,
                        color: Colors.blue,
                        size: 32,
                      ),
                title: Text(
                  l10n.settingsDebugLog,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  l10n.settingsDebugLogSubtitle,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: _isGeneratingLog
                    ? null
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                enabled: !_isGeneratingLog,
                onTap: _isGeneratingLog ? null : _generateDebugLog,
              ),
            ),

            const Divider(height: 32),

            // Benachrichtigungen Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.settingsSectionNotifications,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.settingsNotificationsSubtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Info Box: How Notifications Work
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          l10n.settingsHowNotificationsWork,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(l10n.settingsNotificationsBullet1),
                  _buildBulletPoint(l10n.settingsNotifAsNeeded),
                  _buildBulletPoint(l10n.settingsNotificationsBullet3),
                  _buildBulletPoint(l10n.settingsNotifWorksClosed),
                ],
              ),
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

            // Queue Status
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.pending_actions,
                          color: Colors.orange,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.settingsQueue,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Fragt das Betriebssystem, nicht die eigene Notiz.
                    // Vorher stand hier der Inhalt der Warteschlangen-Box —
                    // seit der Abgleich plant, schreibt die niemand mehr, und
                    // die Zahl waere immer null gewesen.
                    FutureBuilder<int>(
                      future: _vorgemerkteErinnerungen,
                      builder: (context, snapshot) {
                        final pendingCount = snapshot.data ?? 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.settingsScheduledNotifications,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  l10n.settingsCountValue(pendingCount),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            // Hier stand „naechste um …". Die Zeit kam aus
                            // dem ersten Warteschlangeneintrag; das
                            // Betriebssystem gibt sie nicht zurueck
                            // (pendingNotificationRequests liefert Kennung,
                            // Titel, Text und Payload — keinen Zeitpunkt).
                            // Eine Zeit zu zeigen, die wir nicht kennen,
                            // waere genau die Art Zusage, um die es bei
                            // diesem Umbau ging.
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 32),

            // Karten & Standort Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.settingsSectionMaps,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.settingsMapsSubtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Cache Statistics
            FutureBuilder<Map<String, dynamic>>(
              future: _kachelZahlen,
              builder: (context, snapshot) {
                final sizeMB = snapshot.data?['sizeMB'] as int? ?? 0;
                final count = snapshot.data?['count'] as int? ?? 0;
                final limitMB = snapshot.data?['limitMB'] as int? ?? 500;
                final percentage = limitMB > 0
                    ? (sizeMB / limitMB * 100).clamp(0, 100)
                    : 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.storage,
                              color: Colors.blue,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.settingsCacheStorage,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.settingsTilesCount(
                                      sizeMB.toString(),
                                      limitMB.toString(),
                                      count.toString().replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => '${m[1]}.',
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              l10n.settingsPercent(percentage.round()),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: percentage > 90
                                    ? Colors.red
                                    : percentage > 70
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade800,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage > 90
                                  ? Colors.red
                                  : percentage > 70
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Cache Limit Setting
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.tune,
                  color: Colors.purple,
                  size: 28,
                ),
                title: Text(
                  l10n.settingsCacheLimitLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  l10n.settingsMaxStorage(_tileCacheManager.maxCacheSizeMB),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showCacheLimitDialog,
              ),
            ),

            // Pre-Download
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.download_for_offline,
                  color: Colors.green,
                  size: 28,
                ),
                title: Text(
                  l10n.settingsPredownloadMaps,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  l10n.settingsPredownloadSubtitle,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showPreDownloadDialog,
              ),
            ),

            // Clear Cache
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.delete_sweep,
                  color: Colors.orange,
                  size: 28,
                ),
                title: Text(
                  l10n.settingsClearCache,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  l10n.settingsClearCacheSubtitle,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _clearMapCache,
              ),
            ),

            const Divider(height: 32),

            // App-Einstellungen Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.settingsSectionApp,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

            // Sprach-Einstellung
            ValueListenableBuilder(
              valueListenable: getIt<DataEntry>().settingsBox.listenable(),
              builder: (context, box, _) {
                final currentLocale = box.get('selected_locale') as String?;
                final currentLanguageName = _getLanguageName(
                  currentLocale,
                  l10n,
                );

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
                      currentLanguageName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(currentLocale),
                  ),
                );
              },
            ),
          ]);

          return AnimatedListView(
            padding: const EdgeInsets.all(8),
            itemCount: settingsItems.length,
            itemBuilder: (context, index) => settingsItems[index],
          );
        },
      ),
    );
  }
}
