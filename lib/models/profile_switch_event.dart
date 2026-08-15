import 'package:hive_ce/hive.dart';

part 'profile_switch_event.g.dart';

/// Event für Profil-Wechsel
/// Trackt wann welches Profil in den Vordergrund kam
@HiveType(typeId: 24)
class ProfileSwitchEvent {
  ProfileSwitchEvent({
    required this.id,
    required this.toProfileId,
    required this.timestamp,
    this.fromProfileId,
    this.latitude,
    this.longitude,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? fromProfileId; // Von welchem Profil (null = App-Start)

  @HiveField(2)
  final String toProfileId; // Zu welchem Profil

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final double? latitude; // Optional: Wo war der Wechsel

  @HiveField(5)
  final double? longitude;

  /// Prüft ob Event älter als X Tage ist
  bool isOlderThan(int days) {
    final threshold = DateTime.now().subtract(Duration(days: days));
    return timestamp.isBefore(threshold);
  }

  /// War dies ein App-Start? (kein vorheriges Profil)
  bool get isAppStart => fromProfileId == null;

  /// Copy-With für Updates
  ProfileSwitchEvent copyWith({
    String? id,
    String? fromProfileId,
    String? toProfileId,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
  }) {
    return ProfileSwitchEvent(
      id: id ?? this.id,
      fromProfileId: fromProfileId ?? this.fromProfileId,
      toProfileId: toProfileId ?? this.toProfileId,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    final from = fromProfileId ?? 'App-Start';
    return 'ProfileSwitchEvent(id: $id, from: $from → to: $toProfileId, '
        'time: $timestamp, location: ${latitude != null ? "(${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)})" : "none"})';
  }
}
