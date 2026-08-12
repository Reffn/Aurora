import 'package:dis_app/l10n/app_texts.dart';
import 'package:hive_ce/hive.dart';

part 'contact.g.dart';

/// Kategorie für Kontakte
@HiveType(typeId: 14)
enum ContactCategory {
  @HiveField(0)
  family,

  @HiveField(1)
  friends,

  @HiveField(2)
  therapists,

  @HiveField(3)
  doctors,

  @HiveField(4)
  emergency,

  @HiveField(5)
  other;

  /// Der Name der Kategorie auf dem Schirm.
  ///
  /// Über [AppTexts], nicht über den BuildContext: Ein Model sieht keinen
  /// Widget-Baum. Vorher standen hier deutsche Zeichenketten — auf einer
  /// französischen Oberfläche stand dann „Freunde" unter „Catégorie".
  String get label {
    final texts = AppTexts.current;
    switch (this) {
      case ContactCategory.family:
        return texts.contactCategoryFamily;
      case ContactCategory.friends:
        return texts.contactCategoryFriends;
      case ContactCategory.therapists:
        return texts.contactCategoryTherapists;
      case ContactCategory.doctors:
        return texts.contactCategoryDoctors;
      case ContactCategory.emergency:
        return texts.contactCategoryEmergency;
      case ContactCategory.other:
        return texts.contactCategoryOther;
    }
  }
}

/// Kontakt-Model für Personen im Umfeld des Betroffenen
@HiveType(typeId: 13)
class Contact {
  // 1-5, Bewertung vom Ersteller

  Contact({
    required this.id,
    required this.name,
    required this.category,
    required this.createdByProfileId,
    required this.createdAt,
    required this.defaultRating,
    this.relation,
    this.phone,
    this.email,
    this.notes,
    this.imagePath,
    this.latitude,
    this.longitude,
    this.address,
    this.isEmergencyContact = false,
  });
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? relation; // z.B. "Mutter", "Therapeutin", etc.

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? imagePath;

  @HiveField(7)
  final ContactCategory category;

  @HiveField(8)
  final String createdByProfileId;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final int defaultRating;

  @HiveField(11)
  final double? latitude; // GPS-Koordinaten (v3.1)

  @HiveField(12)
  final double? longitude;

  @HiveField(13)
  final String? address; // Adresse als Text

  @HiveField(14)
  final bool isEmergencyContact; // Notfallkontakt-Markierung

  /// Kopie mit geänderten Werten
  Contact copyWith({
    String? id,
    String? name,
    String? relation,
    String? phone,
    String? email,
    String? notes,
    String? imagePath,
    ContactCategory? category,
    String? createdByProfileId,
    DateTime? createdAt,
    int? defaultRating,
    double? latitude,
    double? longitude,
    String? address,
    bool? isEmergencyContact,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      createdByProfileId: createdByProfileId ?? this.createdByProfileId,
      createdAt: createdAt ?? this.createdAt,
      defaultRating: defaultRating ?? this.defaultRating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
    );
  }

  /// Prüft ob Kontakt GPS-Koordinaten hat
  bool get hasLocation => latitude != null && longitude != null;

  /// Zu Map konvertieren (für Logging/Debugging)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'phone': phone,
      'email': email,
      'notes': notes,
      'imagePath': imagePath,
      'category': category.name,
      'createdByProfileId': createdByProfileId,
      'createdAt': createdAt.toIso8601String(),
      'defaultRating': defaultRating,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isEmergencyContact': isEmergencyContact,
    };
  }

  @override
  String toString() {
    // `name`, nicht `label`: Ein Log soll in jeder Sprache gleich lesbar sein
    // und nicht davon abhängen, ob schon eine Oberfläche gebaut wurde.
    return 'Contact(id: $id, name: $name, category: ${category.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
