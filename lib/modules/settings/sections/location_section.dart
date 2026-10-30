import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/settings/screens/offline_maps_screen.dart';
import 'package:dis_app/modules/settings/sections/settings_section_parts.dart';
import 'package:dis_app/modules/settings/widgets/settings_info_sheet.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/widgets/permission_guard.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Karten & Standort: ob Aurora den Standort nutzen darf, „Tracking
/// dauerhaft an“ und der Weg zu den Offline-Karten.
///
/// Den Standort sieht jeder Anteil, wie vorher die Karten: Die Freigabe gilt
/// dem Gerät, und jede Karte fragt ohnehin selbst danach. Das Tracking für
/// alle steuert nur, wer Rechte vergeben darf.
class SettingsLocationSection extends StatefulWidget {
  const SettingsLocationSection({super.key});

  @override
  State<SettingsLocationSection> createState() =>
      _SettingsLocationSectionState();
}

class _SettingsLocationSectionState extends State<SettingsLocationSection>
    with AutomaticKeepAliveClientMixin {
  // Die Liste baut weit entfernte Abschnitte ab. Laufende Abläufe,
  // geladene Zahlen und Schalterzustände sollen das überleben.
  @override
  bool get wantKeepAlive => true;

  late final _gpsManager = getIt<GpsManager>();
  late final _trackingService = getIt<LocationTrackingService>();

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
                SettingsBulletPoint(l10n.settingsGpsBackgroundRuns),
                SettingsBulletPoint(l10n.settingsGpsOverridesAll),
                SettingsBulletPoint(l10n.permissionTrackingBullet3),
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
        // Recht fehlt doch: dieselben ruhigen Schritte wie in der Zeile
        // „Standort“, statt eines eigenen Warndialogs.
        if (mounted) {
          await _zeigeStandortSchritte();
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

  /// „Freigeben“: fragt das System nach dem Recht, sonst nichts.
  Future<void> _freigeben() async {
    final antwort = await _gpsManager.requestPermission();
    // Nachsehen hält den Stand ehrlich, auch wenn die Antwort und das, was
    // das System danach meldet, auseinandergehen.
    final erlaubt = await _gpsManager.refreshAndCheckTrackingPermission();
    if (!mounted || erlaubt) return;
    // Ein einfaches Nein lässt „Freigeben“ stehen; das System fragt beim
    // nächsten Mal wieder. Erst wenn es nicht mehr fragt, führt der Weg nur
    // noch über Android.
    if (antwort == LocationPermission.deniedForever) {
      await _zeigeStandortSchritte();
    }
  }

  Future<void> _einschalten() async {
    await _gpsManager.openLocationSettings();
  }

  Future<void> _inAndroidOeffnen() async {
    await _gpsManager.openAppSettings();
  }

  /// Die Schritte, die vorher immer auf dem Schirm standen, sobald etwas
  /// fehlte. Jetzt nur, wenn sie gebraucht werden.
  Future<void> _zeigeStandortSchritte() {
    final l10n = AppLocalizations.of(context);
    return showSettingsInfoSheet(
      context,
      icon: Icons.location_on_outlined,
      title: l10n.settingsHowToEnableLocation,
      children: [
        _Schritt(nummer: 1, text: l10n.settingsStepOpenSettings),
        _Schritt(nummer: 2, text: l10n.settingsStepPermissionLocation),
        _Schritt(nummer: 3, text: l10n.settingsStepChooseWhileUsing),
      ],
      // Schritt 1 nennt diesen Knopf beim Namen und sagt „unten“.
      action: OutlinedButton.icon(
        onPressed: _inAndroidOeffnen,
        icon: const Icon(Icons.settings),
        label: Text(l10n.settingsOpenAndroidSettings),
      ),
    );
  }

  Future<void> _zeigeTrackingErklaerung() {
    final l10n = AppLocalizations.of(context);
    return showSettingsInfoSheet(
      context,
      title: l10n.settingsWhatIsAlwaysOn,
      children: [
        SettingsInfoParagraph(l10n.settingsAdminTrackingExplanation),
        SettingsBulletPoint(l10n.settingsPositionAlways),
        SettingsBulletPoint(l10n.settingsGlobalTrackingBullet2),
        SettingsBulletPoint(l10n.settingsOverridesProfiles),
        SettingsBulletPoint(l10n.settingsAllProfilesTracked),
        // Eine Zusage, kein Warnton: Aufgezeichnet wird nur, solange die
        // Benachrichtigung steht.
        SettingsInfoNote(
          icon: Icons.notifications_outlined,
          text: l10n.settingsTrackingNotice,
        ),
        SettingsInfoNote(
          icon: Icons.lock_outline,
          text: l10n.settingsLocationStaysOffline,
        ),
      ],
    );
  }

  /// Zustandswort und höchstens eine Handlung.
  Widget _standortZeile(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ValueListenableBuilder<bool>(
        valueListenable: _gpsManager.isGpsServiceEnabled,
        builder: (context, dienstAn, _) {
          return ValueListenableBuilder<bool>(
            // Nicht nur `permissionStatus`: Den setzt der GpsManager erst
            // beim Nachsehen, `hasGpsPermission` schon bei der Anfrage.
            valueListenable: _gpsManager.hasGpsPermission,
            builder: (context, erlaubt, _) {
              return ValueListenableBuilder<LocationPermission>(
                valueListenable: _gpsManager.permissionStatus,
                builder: (context, status, _) {
                  final zustand = _Standort.ermitteln(
                    dienstAn: dienstAn,
                    erlaubt: erlaubt,
                    status: status,
                  );
                  final (wort, handlung) = switch (zustand) {
                    _Standort.freigegeben => (
                      l10n.settingsLocationStateAllowed,
                      null,
                    ),
                    _Standort.dienstAus => (
                      l10n.settingsLocationStateOff,
                      OutlinedButton.icon(
                        onPressed: _einschalten,
                        icon: const Icon(Icons.power_settings_new),
                        label: Text(l10n.settingsLocationActionTurnOn),
                      ),
                    ),
                    _Standort.nichtFreigegeben => (
                      l10n.settingsLocationStateNotAllowed,
                      OutlinedButton.icon(
                        onPressed: _freigeben,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(l10n.settingsLocationActionAllow),
                      ),
                    ),
                    _Standort.abgelehnt => (
                      l10n.settingsLocationStateBlocked,
                      OutlinedButton.icon(
                        onPressed: _zeigeStandortSchritte,
                        icon: const Icon(Icons.open_in_new),
                        label: Text(l10n.settingsLocationActionOpenAndroid),
                      ),
                    ),
                  };

                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, size: 28),
                    title: Text(
                      l10n.settingsLocationTitle,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      wort,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: handlung,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _trackingZeile(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            valueListenable: _gpsManager.isGpsServiceEnabled,
            builder: (context, serviceEnabled, _) {
              return ValueListenableBuilder<LocationPermission>(
                valueListenable: _gpsManager.permissionStatus,
                builder: (context, permission, _) {
                  final canEnable =
                      _gpsManager.hasTrackingPermission && serviceEnabled;

                  return ListTile(
                    leading: Icon(
                      isGlobalTrackingOn
                          ? Icons.my_location
                          : Icons.location_off,
                      color: isGlobalTrackingOn ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                    title: Text(
                      l10n.settingsTrackingAlwaysOn,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      isGlobalTrackingOn
                          ? l10n.settingsGpsRunsForAll
                          : canEnable
                          ? l10n.settingsTrackingPermanentOff
                          : l10n.settingsTrackingPermissionRequired,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SettingsInfoButton(
                          onPressed: _zeigeTrackingErklaerung,
                        ),
                        Switch(
                          value: isGlobalTrackingOn,
                          onChanged: canEnable || isGlobalTrackingOn
                              ? (value) => _toggleGlobalTracking(
                                  value,
                                  canEnable,
                                )
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(l10n.settingsSectionMaps),
        _standortZeile(l10n),
        PermissionGuard(
          permission: Permission.managePermissions,
          child: _trackingZeile(l10n),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.map_outlined, size: 28),
            title: Text(
              l10n.settingsOfflineMapsTitle,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const OfflineMapsScreen(),
              ),
            ),
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }
}

/// Was die Zeile „Standort“ zeigt.
enum _Standort {
  freigegeben,
  dienstAus,
  nichtFreigegeben,
  abgelehnt;

  /// Ist die Ortung am Gerät aus, fragt das System gar nicht erst nach dem
  /// Recht. Deshalb kommt sie zuerst.
  ///
  /// `abgelehnt` sieht man auf Android nur kurz: `deniedForever` kommt dort
  /// allein als Antwort auf eine Anfrage, und das nächste Nachsehen meldet
  /// wieder `denied`. Deshalb zeigt „Freigeben“ die Schritte selbst, sobald
  /// die Anfrage `deniedForever` ergibt.
  static _Standort ermitteln({
    required bool dienstAn,
    required bool erlaubt,
    required LocationPermission status,
  }) {
    if (!dienstAn) return _Standort.dienstAus;
    if (erlaubt) return _Standort.freigegeben;
    if (status == LocationPermission.deniedForever) return _Standort.abgelehnt;
    return _Standort.nichtFreigegeben;
  }
}

/// Ein nummerierter Schritt, ruhig gesetzt: Die Nummer ordnet, sie warnt
/// nicht.
class _Schritt extends StatelessWidget {
  const _Schritt({required this.nummer, required this.text});

  final int nummer;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$nummer',
                style: const TextStyle(
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
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
