import 'package:hive_ce/hive.dart';

part 'location_history_entry.g.dart';

/// GPS-Positions-Eintrag für Timeline-Tracking
/// Speichert wo sich ein Profil zu einem bestimmten Zeitpunkt befunden hat
@HiveType(typeId: 23)
class LocationHistoryEntry {
  LocationHistoryEntry({
    required this.id,
    required this.profileId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.address,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String profileId; // Welches Profil war aktiv

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final double? accuracy; // GPS-Genauigkeit in Metern

  @HiveField(6)
  final String? address; // Reverse-Geocoded Adresse

  /// Prüft ob Eintrag älter als X Tage ist
  bool isOlderThan(int days) {
    final threshold = DateTime.now().subtract(Duration(days: days));
    return timestamp.isBefore(threshold);
  }

  /// Copy-With für Updates
  LocationHistoryEntry copyWith({
    String? id,
    String? profileId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? accuracy,
    String? address,
  }) {
    return LocationHistoryEntry(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'LocationHistoryEntry(id: $id, profileId: $profileId, '
        'lat: ${latitude.toStringAsFixed(4)}, '
        'lng: ${longitude.toStringAsFixed(4)}, '
        'time: $timestamp, accuracy: ${accuracy?.toStringAsFixed(1)}m)';
  }
}
