import 'package:hive_ce/hive.dart';

part 'comment.g.dart';

/// Typ des kommentierbaren Objekts (Diary, Contact, Calendar, etc.)
@HiveType(typeId: 31)
enum CommentableType {
  @HiveField(0)
  diary,

  @HiveField(1)
  contact,

  @HiveField(2)
  calendar,

  @HiveField(3)
  medication,

  @HiveField(4)
  finder,
}

/// Unified Comment Model - Kommentare für alle Module (Diary, Contact, Calendar, etc.)
/// Ersetzt DiaryComment und ContactComment für ein konsistentes System
@HiveType(typeId: 30)
class Comment {
  Comment({
    required this.id,
    required this.type,
    required this.parentId,
    required this.profileId,
    required this.content,
    required this.timestamp,
    this.editedAt,
  });

  /// Von Map erstellen
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      type: CommentableType.values[map['type'] as int],
      parentId: map['parentId'] as String,
      profileId: map['profileId'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      editedAt: map['editedAt'] != null
          ? DateTime.parse(map['editedAt'] as String)
          : null,
    );
  }

  /// Unique Kommentar-ID
  @HiveField(0)
  final String id;

  /// Typ des Parent-Objekts (diary, contact, calendar, etc.)
  @HiveField(1)
  final CommentableType type;

  /// ID des Parent-Objekts (z.B. diaryEntryId, contactId, calendarEventId)
  @HiveField(2)
  final String parentId;

  /// Profil-ID des Autors
  @HiveField(3)
  final String profileId;

  /// Kommentar-Text
  @HiveField(4)
  final String content;

  /// Zeitstempel der Erstellung
  @HiveField(5)
  final DateTime timestamp;

  /// Zeitstempel der letzten Bearbeitung (null = nicht bearbeitet)
  @HiveField(6)
  final DateTime? editedAt;

  /// Kopie mit geänderten Werten
  Comment copyWith({
    String? id,
    CommentableType? type,
    String? parentId,
    String? profileId,
    String? content,
    DateTime? timestamp,
    DateTime? editedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
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
      'type': type.index,
      'parentId': parentId,
      'profileId': profileId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Comment(id: $id, type: $type, parentId: $parentId, profileId: $profileId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
