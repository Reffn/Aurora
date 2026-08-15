import 'package:hive_ce/hive.dart';

part 'diary_comment.g.dart';

/// Kommentar zu einem Notfall-Tagebuch Eintrag
@HiveType(typeId: 12)
class DiaryComment {
  DiaryComment({
    required this.id,
    required this.entryId,
    required this.profileId,
    required this.content,
    required this.timestamp,
    this.editedAt,
  });

  /// Von Map erstellen
  factory DiaryComment.fromMap(Map<String, dynamic> map) {
    return DiaryComment(
      id: map['id'] as String,
      entryId: map['entryId'] as String,
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
  final String entryId;

  @HiveField(2)
  final String profileId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final DateTime? editedAt;

  /// Kopie mit geänderten Werten
  DiaryComment copyWith({
    String? id,
    String? entryId,
    String? profileId,
    String? content,
    DateTime? timestamp,
    DateTime? editedAt,
  }) {
    return DiaryComment(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
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
      'entryId': entryId,
      'profileId': profileId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DiaryComment(id: $id, entryId: $entryId, profileId: $profileId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryComment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
