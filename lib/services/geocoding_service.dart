import 'dart:convert';
import 'package:dis_app/constants/netz_kennung.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Geocoding-Service für Adress-Suche via Nominatim (OpenStreetMap)
///
/// Verwendung:
/// - Kostenlos
/// - Rate-Limit: 1 req/sec pro IP (pro Nutzer)
/// - Erfordert Internet-Verbindung
/// - User-Agent Pflicht — siehe [NetzKennung], warum er die Diagnose nicht
///   nennt
class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = NetzKennung.userAgent;

  /// Sucht eine Adresse und gibt Koordinaten + Display-Name zurück
  ///
  /// Beispiel:
  /// ```dart
  /// final result = await geocodingService.searchAddress('Kirchstrasse 3, Coswig');
  /// if (result != null) {
  ///   print('Gefunden: ${result.displayName}');
  ///   print('Koordinaten: ${result.coordinates}');
  /// }
  /// ```
  ///
  /// Wirft Exception bei Netzwerkfehlern
  Future<GeocodingResult?> searchAddress(String query) async {
    if (query.trim().isEmpty) return null;

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'q': query.trim(),
        'format': 'json',
        'limit': '1',
        'addressdetails': '1',
      },
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': _userAgent},
    );

    if (response.statusCode != 200) {
      throw Exception('Nominatim API error: ${response.statusCode}');
    }

    final results = json.decode(response.body) as List<dynamic>;

    if (results.isEmpty) {
      return null; // Keine Ergebnisse gefunden
    }

    final firstResult = results[0] as Map<String, dynamic>;

    return GeocodingResult(
      coordinates: LatLng(
        double.parse(firstResult['lat'] as String),
        double.parse(firstResult['lon'] as String),
      ),
      displayName: firstResult['display_name'] as String,
    );
  }

  /// Sucht eine Adresse und gibt mehrere Vorschläge zurück (für Autocomplete)
  ///
  /// Beispiel:
  /// ```dart
  /// final suggestions = await geocodingService.searchAddressMultiple('Kirchstrasse');
  /// for (var suggestion in suggestions) {
  ///   print('Vorschlag: ${suggestion.displayName}');
  /// }
  /// ```
  ///
  /// Gibt bis zu 5 Ergebnisse zurück
  /// Wirft Exception bei Netzwerkfehlern
  Future<List<GeocodingResult>> searchAddressMultiple(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'q': query.trim(),
        'format': 'json',
        'limit': '5',
        'addressdetails': '1',
      },
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': _userAgent},
    );

    if (response.statusCode != 200) {
      throw Exception('Nominatim API error: ${response.statusCode}');
    }

    final results = json.decode(response.body) as List<dynamic>;

    return results.map((result) {
      final r = result as Map<String, dynamic>;
      return GeocodingResult(
        coordinates: LatLng(
          double.parse(r['lat'] as String),
          double.parse(r['lon'] as String),
        ),
        displayName: r['display_name'] as String,
      );
    }).toList();
  }

  /// Reverse Geocoding: Koordinaten → Adresse
  ///
  /// Beispiel:
  /// ```dart
  /// final address = await geocodingService.reverseGeocode(
  ///   LatLng(51.1305, 13.5779),
  /// );
  /// if (address != null) {
  ///   print('Adresse: $address'); // "Kirchstraße 3, 01640 Coswig, Deutschland"
  /// }
  /// ```
  ///
  /// Gibt Adresse als String zurück oder null bei Fehler
  Future<String?> reverseGeocode(LatLng coordinates) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(
      queryParameters: {
        'lat': coordinates.latitude.toString(),
        'lon': coordinates.longitude.toString(),
        'format': 'json',
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final result = json.decode(response.body) as Map<String, dynamic>;
      return result['display_name'] as String?;
    } catch (e) {
      return null;
    }
  }
}

/// Ergebnis einer Geocoding-Suche
class GeocodingResult {
  const GeocodingResult({
    required this.coordinates,
    required this.displayName,
  });

  final LatLng coordinates;
  final String displayName;
}
