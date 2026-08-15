import 'package:url_launcher/url_launcher.dart';

/// Location Helper - Koordinaten-Formatierung und Maps-Integration
///
/// Reine Utilities für Formatierung und Kartendarstellung.
/// GPS-Zugriffe (Permission, Service, Position) sollten über GpsManager erfolgen.
class LocationHelper {
  /// GPS-Koordinaten für UI formatieren
  /// Beispiel: "52.5200° N, 13.4050° E"
  static String formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    final latAbs = lat.abs().toStringAsFixed(4);
    final lngAbs = lng.abs().toStringAsFixed(4);
    return '$latAbs° $latDir, $lngAbs° $lngDir';
  }

  /// Ort in externer Maps-App öffnen (Google Maps/Apple Maps)
  static Future<bool> openInMaps(
    double lat,
    double lng, {
    String? label,
  }) async {
    // URL Schema für verschiedene Plattformen
    // iOS: Apple Maps
    // Android: Google Maps
    final query = label != null ? Uri.encodeComponent(label) : '';
    final url = Uri.parse('https://maps.google.com/?q=$lat,$lng($query)');

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
