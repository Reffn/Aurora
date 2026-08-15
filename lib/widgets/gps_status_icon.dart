import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';

/// Kompaktes GPS-Status Icon für AppBar
///
/// Farbcodierung:
/// - 🔴 ROT: Android Permission fehlt ODER GPS-Service deaktiviert
/// - 🟡 GELB: Permission OK, aber Tracking deaktiviert
/// - 🟢 GRÜN: Tracking aktiv
class GpsStatusIcon extends StatefulWidget {
  const GpsStatusIcon({super.key});

  @override
  State<GpsStatusIcon> createState() => _GpsStatusIconState();
}

class _GpsStatusIconState extends State<GpsStatusIcon> {
  LocationTrackingService? _trackingService;
  GpsManager? _gpsManager;

  @override
  void initState() {
    super.initState();
    // Safe Access: Prüfe ob Services verfügbar sind (Deferred Init abgeschlossen)
    if (getIt.isRegistered<LocationTrackingService>()) {
      _trackingService = getIt<LocationTrackingService>();
    }
    if (getIt.isRegistered<GpsManager>()) {
      _gpsManager = getIt<GpsManager>();
    }
  }

  /// Bestimmt Status-Farbe basierend auf Permission + Tracking + Service
  Color _getStatusColor(
    bool hasPermission,
    bool isTracking,
    bool serviceEnabled,
  ) {
    // Priorität 1: Permission fehlt ODER GPS-Service aus → ROT
    if (!hasPermission || !serviceEnabled) {
      return Colors.red;
    }

    // Priorität 2: Permission OK, aber Tracking aus → GELB
    if (!isTracking) {
      return Colors.amber;
    }

    // Priorität 3: Alles aktiv → GRÜN
    return Colors.green;
  }

  /// Gibt Tooltip-Text basierend auf Status
  String _getTooltip(
    AppLocalizations l10n,
    bool hasPermission,
    bool isTracking,
    bool serviceEnabled,
  ) {
    if (!hasPermission) {
      return l10n.gpsPermissionMissing;
    }

    if (!serviceEnabled) {
      return l10n.gpsServiceDisabled;
    }

    if (!isTracking) {
      return l10n.gpsTrackingOffTap;
    }

    return l10n.gpsTrackingOnTap;
  }

  Future<void> _toggleTracking() async {
    final l10n = AppLocalizations.of(context);
    // Prüfe ob Service verfügbar ist
    if (_trackingService == null) return;

    try {
      // Dieser Tipp ist die Handlung der Nutzerin — hier darf gefragt werden.
      await _trackingService!.toggleTracking(askForPermission: true);
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          l10n.gpsNoPermissionHint,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wenn Services nicht verfügbar (noch nicht initialisiert), zeige nichts
    if (_trackingService == null || _gpsManager == null) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder(
      valueListenable: _trackingService!.hasLocationPermission,
      builder: (context, hasPermission, _) {
        return ValueListenableBuilder(
          valueListenable: _trackingService!.isTrackingRunning,
          builder: (context, isTracking, _) {
            return ValueListenableBuilder(
              valueListenable: _gpsManager!.isGpsServiceEnabled,
              builder: (context, serviceEnabled, _) {
                final color = _getStatusColor(
                  hasPermission,
                  isTracking,
                  serviceEnabled,
                );
                final tooltip = _getTooltip(
                  AppLocalizations.of(context),
                  hasPermission,
                  isTracking,
                  serviceEnabled,
                );

                return IconButton(
                  icon: Icon(Icons.satellite_alt, color: color),
                  tooltip: tooltip,
                  onPressed: _toggleTracking,
                );
              },
            );
          },
        );
      },
    );
  }
}
