import 'package:dis_app/l10n/app_texts.dart';
import 'package:hive_ce/hive.dart';

part 'finder_item.g.dart';

/// Typ des Finder-Eintrags
@HiveType(typeId: 16)
enum FinderItemType {
  @HiveField(0)
  location, // Orte (Wohnung, Arzt, Therapie)

  @HiveField(1)
  item; // Gegenstände (Schlüssel, Dokumente, etc.)

  /// Der Name des Typs auf dem Schirm.
  String get label {
    switch (this) {
      case FinderItemType.location:
        return AppTexts.current.finderTypeLocation;
      case FinderItemType.item:
        return AppTexts.current.finderTypeItem;
    }
  }

  /// Icon für UI
  String get iconName {
    switch (this) {
      case FinderItemType.location:
        return 'place';
      case FinderItemType.item:
        return 'inbox';
    }
  }
}

/// Finder-Item Model für Orte und Gegenstände
/// Hilft DIS-Patienten, wichtige Informationen zu speichern
@HiveType(typeId: 15)
class FinderItem {
  FinderItem({
    required this.id,
    required this.title,
    required this.type,
    required this.tags,
    required this.createdAt,
    required this.createdByProfileId,
    this.description,
    this.location,
    this.address,
    this.latitude,
    this.longitude,
    this.imagePath,
  });
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title; // z.B. "Wohnungsschlüssel", "Zuhause"

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final FinderItemType type;

  @HiveField(4)
  final String? location; // Für Items: "Küche, 2. Schublade links"

  @HiveField(5)
  final String? address; // Für Orte: "Musterstraße 123, 12345 Musterstadt"

  @HiveField(6)
  final double? latitude; // Für Orte: GPS-Koordinaten

  @HiveField(7)
  final double? longitude;

  @HiveField(8)
  final String? imagePath; // Optional: Foto vom Gegenstand/Ort

  @HiveField(9)
  final List<String> tags; // z.B. ["wichtig", "notfall", "täglich"]

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final String createdByProfileId;

  /// Kopie mit geänderten Werten
  FinderItem copyWith({
    String? id,
    String? title,
    String? description,
    FinderItemType? type,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    String? imagePath,
    List<String>? tags,
    DateTime? createdAt,
    String? createdByProfileId,
  }) {
    return FinderItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      createdByProfileId: createdByProfileId ?? this.createdByProfileId,
    );
  }

  /// Prüft ob Item wichtig markiert ist
  bool get isImportant => tags.contains('wichtig');

  /// Prüft ob Item als Notfall markiert ist
  bool get isEmergency => tags.contains('notfall');

  /// Zu Map konvertieren (für Logging/Debugging)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'createdByProfileId': createdByProfileId,
    };
  }

  @override
  String toString() {
    return 'FinderItem(id: $id, title: $title, type: ${type.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
