import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/events/chat_events.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/chat_message.dart';
import 'package:hive_ce/hive.dart';

/// Chat-Service - Verwaltet Chat-Nachrichten mit Hive-Persistierung
/// Nutzt Hive ValueListenable für reaktive UI-Updates
class ChatService extends BaseService {
  ChatService(super.eventBus);
  late Box<ChatMessage> _messageBox;

  @override
  Future<void> openBoxes() async {
    _messageBox = await Hive.openBox<ChatMessage>(HiveBoxNames.chatMessages);
  }

  @override
  void subscribeToEvents() {
    eventBus.on<ChatMessageCreatedEvent>().listen(_handleMessageCreated);
    eventBus.on<ChatMessageReadEvent>().listen(_handleMessageRead);
    eventBus.on<ChatHistoryRequestedEvent>().listen(_handleHistoryRequested);
  }

  @override
  Future<void> closeBoxes() async {
    await _messageBox.close();
  }

  /// Zugriff auf Messages-Box für ValueListenable
  /// UI kann damit ValueListenableBuilder nutzen für automatische Updates
  Box<ChatMessage> get messagesBox => _messageBox;

  /// Alle Nachrichten abrufen (für nicht-reaktive Zugriffe), nach Zeitpunkt
  /// geordnet — älteste zuerst.
  ///
  /// Hier stand `_messageBox.values.toList()`, also die Reihenfolge, in der
  /// die Kiste beschrieben wurde. Solange nur laufend angehängt wird, ist das
  /// dasselbe Ergebnis. Es kippt still, sobald etwas nachgetragen, importiert
  /// oder wiederhergestellt wird — und seit der Verlauf nach Tagen getrennt
  /// wird, würde daraus sichtbarer Unsinn: derselbe Tag zweimal als
  /// Überschrift, mit fremden Nachrichten dazwischen.
  ///
  /// Die Ordnung gehört hierher und nicht in die Fläche: Wer Nachrichten
  /// liest, bekommt sie in der Reihenfolge, in der sie geschrieben wurden.
  List<ChatMessage> get messages {
    final sortiert = _messageBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return List.unmodifiable(sortiert);
  }

  /// Nachricht erstellt
  void _handleMessageCreated(ChatMessageCreatedEvent event) {
    try {
      _messageBox.add(event.message);
      // Hive notified automatisch alle ValueListenable Listener!

      // Bestätigung publishen
      eventBus.publish(ChatMessageSavedEvent(event.message));
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error creating chat message',
        data: {'messageId': event.message.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Nachricht als gelesen markieren
  void _handleMessageRead(ChatMessageReadEvent event) {
    try {
      dynamic messageKey;
      try {
        messageKey = _messageBox.keys.firstWhere(
          (key) => _messageBox.get(key)?.id == event.messageId,
        );
      } catch (e) {
        // Nachricht nicht gefunden - das ist ok, einfach ignorieren
        return;
      }

      final message = _messageBox.get(messageKey);
      if (message != null) {
        _messageBox.put(messageKey, message.copyWith(isRead: true));
        // Hive notified automatisch alle ValueListenable Listener!
      }
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error marking message as read',
        data: {'messageId': event.messageId, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Chat-History abrufen
  void _handleHistoryRequested(ChatHistoryRequestedEvent event) {
    final allMessages = _messageBox.values.toList();
    final start = event.offset;
    final end = (start + event.limit).clamp(0, allMessages.length);

    final requestedMessages = allMessages.sublist(
      start.clamp(0, allMessages.length),
      end,
    );

    eventBus.publish(ChatHistoryLoadedEvent(requestedMessages));
  }

  /// Alle Nachrichten löschen (Debug-Option)
  Future<void> clearAll() async {
    await _messageBox.clear();
    // Hive notified automatisch alle ValueListenable Listener!
  }
}
