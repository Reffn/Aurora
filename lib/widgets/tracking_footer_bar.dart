import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';

/// Globale Footer-Bar für GPS-Tracking Status
///
/// Zeigt:
/// - Ob Tracking aktiv ist
/// - Wann letztes Update war
/// - Toggle-Button zum An/Aus schalten
class TrackingFooterBar extends StatefulWidget {
  const TrackingFooterBar({super.key});

  @override
  State<TrackingFooterBar> createState() => _TrackingFooterBarState();
}

class _TrackingFooterBarState extends State<TrackingFooterBar> {
  late final LocationTrackingService _trackingService;
  late final GpsManager _gpsManager;

  @override
  void initState() {
    super.initState();
    _trackingService = getIt<LocationTrackingService>();
    _gpsManager = getIt<GpsManager>();
  }

  /// Formatiert die Zeitdifferenz in der Sprache der Nutzerin.
  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    final texts = AppTexts.current;

    if (difference.inSeconds < 60) {
      return texts.timeSecondsAgo(difference.inSeconds);
    } else if (difference.inMinutes < 60) {
      return texts.timeMinutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return texts.timeHoursAgo(difference.inHours);
    } else {
      return texts.timeDaysAgo(difference.inDays);
    }
  }

  Future<void> _toggleTracking() async {
    try {
      await _trackingService.toggleTracking();
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          AppLocalizations.of(context).trackingPermissionDeniedHint,
        );
      }
    }
  }

  /// Öffnet App-Einstellungen für GPS-Berechtigung
  Future<void> _openAppSettings() async {
    final l10n = AppLocalizations.of(context);
    final opened = await _gpsManager.openAppSettings();
    if (!opened && mounted) {
      context.showErrorSnackBar(
        l10n.settingsCouldNotOpen,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder(
      valueListenable: _trackingService.hasLocationPermission,
      builder: (context, hasPermission, _) {
        return ValueListenableBuilder(
          valueListenable: _trackingService.isTrackingRunning,
          builder: (context, isTracking, _) {
            // Determine state: No Permission, Active
            final noPermission = !hasPermission;
            final isActive = hasPermission && isTracking;

            // Color scheme based on state
            final backgroundColor = noPermission
                ? Colors.orange.shade900.withValues(alpha: 0.9)
                : (isActive
                      ? Colors.green.shade900.withValues(alpha: 0.9)
                      : Colors.grey.shade900.withValues(alpha: 0.9));

            final borderColor = noPermission
                ? Colors.orange.withValues(alpha: 0.3)
                : (isActive
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.3));

            final iconColor = noPermission
                ? Colors.orange.shade300
                : (isActive ? Colors.green.shade300 : Colors.grey.shade400);

            final statusColor = noPermission
                ? Colors.orange.shade300
                : (isActive ? Colors.green.shade300 : Colors.grey.shade400);

            // Status text based on state
            final statusText = noPermission
                ? l10n.permissionMissingShort
                : (isActive ? l10n.statusActive : l10n.statusPaused);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 44,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Status Icon
                      Icon(
                        isActive ? Icons.location_on : Icons.location_off,
                        size: 20,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10),

                      // Status Text
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  l10n.trackingLabel,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                                if (isActive)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Colors.green.shade300,
                                    ),
                                  ),
                              ],
                            ),
                            if (isActive) _buildLastUpdateText(),
                          ],
                        ),
                      ),

                      // Toggle Switch or Settings Button
                      if (noPermission)
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            size: 24,
                            color: Colors.orange.shade300,
                          ),
                          onPressed: _openAppSettings,
                          tooltip: l10n.settingsOpenAppSettings,
                        )
                      else
                        SizedBox(
                          height: 32,
                          child: FittedBox(
                            child: Switch(
                              value: isTracking,
                              onChanged: (_) => _toggleTracking(),
                              activeThumbColor: Colors.green.shade400,
                              activeTrackColor: Colors.green.shade700,
                              inactiveThumbColor: Colors.grey.shade600,
                              inactiveTrackColor: Colors.grey.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLastUpdateText() {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder(
      valueListenable: _trackingService.lastUpdate,
      builder: (context, lastUpdate, _) {
        if (lastUpdate == null) {
          return Text(
            l10n.gpsWaitingFirstUpdate,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          );
        }

        final timeAgo = _formatTimeAgo(lastUpdate);

        return Text(
          AppTexts.current.trackingLastUpdate(timeAgo),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        );
      },
    );
  }
}
