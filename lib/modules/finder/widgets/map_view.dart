import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// MapView Widget - Read-Only Karte mit Marker
/// Für DetailScreens (Finder, Contact)
/// Basiert auf OverviewMap mit Zoom Controls, GPS Status und Location Button
class MapView extends StatelessWidget {
  const MapView({
    required this.latitude,
    required this.longitude,
    super.key,
    this.title,
    this.showOpenInMapsButton = true,
    this.finderLocations,
  });

  final double latitude;
  final double longitude;
  final String? title;
  final bool showOpenInMapsButton;
  final List<FinderItem>? finderLocations;

  @override
  Widget build(BuildContext context) {
    final mapService = getIt<MapService>();
    final gpsManager = getIt<GpsManager>();
    final location = LatLng(latitude, longitude);

    logger.info(
      LogCategory.ui,
      '🗺️ MAPVIEW: Building map for location',
      data: {
        'lat': latitude,
        'lng': longitude,
        'formatted': gpsManager.formatCoordinates(latitude, longitude),
        'title': title ?? 'no title',
        'tilesDownloaded': mapService.areTilesDownloaded,
      },
    );

    // Karte nur anzeigen wenn User Kartendaten aktiviert hat
    if (!mapService.areTilesDownloaded) {
      return _buildNoMapPlaceholder(context, gpsManager);
    }

    return Column(
      children: [
        // Karte mit OverviewMap (Zoom Controls, GPS Status, Location Button)
        SizedBox(
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: OverviewMap(
              showUserLocation: true,
              showFinderLocations: true,
              showZoomControls: true,
              showLocationButton: true,
              initialCenter: location,
              finderLocations: finderLocations,
            ),
          ),
        ),
      ],
    );
  }

  /// Platzhalter wenn Kartendaten nicht geladen
  Widget _buildNoMapPlaceholder(BuildContext context, GpsManager gpsManager) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              AppTexts.current.mapNotAvailable,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
