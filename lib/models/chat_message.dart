import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

part 'chat_message.g.dart';

/// Nachrichten-Typ
@HiveType(typeId: 4)
enum MessageType {
  @HiveField(0)
  text,

  @HiveField(1)
  doodle,

  @HiveField(2)
  voice,

  @HiveField(3)
  image,

  @HiveField(4)
  video,
}

/// Chat-Nachricht Model
@HiveType(typeId: 1)
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.profileId,
    required this.content,
    required this.timestamp,
    required this.senderColorValue,
    this.isRead = false,
    this.messageType = MessageType.text,
    this.attachmentFilename,
  });

  /// Von Map erstellen (aus Datenbank)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: (map['is_read'] as int) == 1,
      messageType: MessageType.values[map['message_type'] as int? ?? 0],
      attachmentFilename: map['attachment_filename'] as String?,
      senderColorValue: map['sender_color_value'] as int? ?? 0xFF9C27B0,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String profileId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final bool isRead;

  @HiveField(5)
  final MessageType messageType;

  @HiveField(6)
  final String? attachmentFilename;

  @HiveField(7)
  final int senderColorValue;

  /// Computed property für Sender-Farbe
  Color get senderColor => Color(senderColorValue);

  /// Zu Map konvertieren (für Datenbank)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'message_type': messageType.index,
      'attachment_filename': attachmentFilename,
      'sender_color_value': senderColorValue,
    };
  }

  /// Kopie mit geänderten Werten erstellen
  ChatMessage copyWith({
    String? id,
    String? profileId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? messageType,
    String? attachmentFilename,
    int? senderColorValue,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
      attachmentFilename: attachmentFilename ?? this.attachmentFilename,
      senderColorValue: senderColorValue ?? this.senderColorValue,
    );
  }
}
