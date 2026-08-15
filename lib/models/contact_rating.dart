import 'package:hive_ce/hive.dart';

part 'contact_rating.g.dart';

/// ContactRating-Model - Bewertung eines Kontakts durch ein Profil
/// Ermöglicht individuelle Bewertungen pro Anteil
@HiveType(typeId: 17)
class ContactRating {
  ContactRating({
    required this.id,
    required this.contactId,
    required this.profileId,
    required this.rating,
    required this.createdAt,
    this.editedAt,
  }) : assert(
         rating >= 1 && rating <= 5,
         'Rating muss zwischen 1 und 5 liegen',
       );
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String contactId;

  @HiveField(2)
  final String profileId;

  @HiveField(3)
  final int rating; // 1-5 (1 = negativ/rot, 3 = neutral/orange, 5 = positiv/grün)

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime? editedAt;

  /// Kopie mit geänderten Werten
  ContactRating copyWith({
    String? id,
    String? contactId,
    String? profileId,
    int? rating,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return ContactRating(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      profileId: profileId ?? this.profileId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  /// Zu Map konvertieren (für Logging/Debugging)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'profileId': profileId,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ContactRating(id: $id, contactId: $contactId, profileId: $profileId, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactRating && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
