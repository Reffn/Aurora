import 'package:hive_ce/hive.dart';

part 'contact_comment.g.dart';

/// Kommentar zu einem Kontakt
/// Ermöglicht Anteilen, ihre Gedanken zu einer Person niederzuschreiben
@HiveType(typeId: 18)
class ContactComment {
  ContactComment({
    required this.id,
    required this.contactId,
    required this.profileId,
    required this.content,
    required this.timestamp,
    this.editedAt,
  });

  /// Von Map erstellen
  factory ContactComment.fromMap(Map<String, dynamic> map) {
    return ContactComment(
      id: map['id'] as String,
      contactId: map['contactId'] as String,
      profileId: map['profileId'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      editedAt: map['editedAt'] != null
          ? DateTime.parse(map['editedAt'] as String)
          : null,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String contactId;

  @HiveField(2)
  final String profileId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final DateTime? editedAt;

  /// Kopie mit geänderten Werten
  ContactComment copyWith({
    String? id,
    String? contactId,
    String? profileId,
    String? content,
    DateTime? timestamp,
    DateTime? editedAt,
  }) {
    return ContactComment(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      profileId: profileId ?? this.profileId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  /// Zu Map konvertieren (für Logging/Debugging)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'profileId': profileId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ContactComment(id: $id, contactId: $contactId, profileId: $profileId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactComment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
