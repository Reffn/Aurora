import 'package:dis_app/core/events/app_event.dart';
import 'package:dis_app/models/chat_message.dart';

/// Event: Neue Chat-Nachricht wurde erstellt
class ChatMessageCreatedEvent extends AppEvent {
  ChatMessageCreatedEvent(this.message);
  final ChatMessage message;
}

/// Event: Chat-Nachricht wurde in Datenbank gespeichert
class ChatMessageSavedEvent extends AppEvent {
  ChatMessageSavedEvent(this.message);
  final ChatMessage message;
}

/// Event: Chat-Nachricht wurde als gelesen markiert
class ChatMessageReadEvent extends AppEvent {
  ChatMessageReadEvent(this.messageId);
  final String messageId;
}

/// Event: Chat-History angefordert
class ChatHistoryRequestedEvent extends AppEvent {
  ChatHistoryRequestedEvent({this.limit = 50, this.offset = 0});
  final int limit;
  final int offset;
}

/// Event: Chat-History wurde geladen
class ChatHistoryLoadedEvent extends AppEvent {
  ChatHistoryLoadedEvent(this.messages);
  final List<ChatMessage> messages;
}
