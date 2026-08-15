import 'dart:async';

import 'package:dis_app/core/events/app_event.dart';
import 'package:dis_app/core/logger.dart';
import 'package:rxdart/rxdart.dart';

/// Zentrale Event-Bus-Implementierung mit RxDart
/// Verteilt Events per Stream an alle Subscriber
/// Nutzt Dependency Injection (über GetIt) statt Singleton Pattern
class EventBus {
  // Broadcast-Subject für Event-Verteilung
  final _eventController = PublishSubject<AppEvent>();

  /// Stream für alle Events
  Stream<AppEvent> get stream => _eventController.stream;

  /// Gefilterten Stream für spezifischen Event-Typ
  ///
  /// Beispiel:
  /// ```dart
  /// eventBus.on<ChatMessageCreatedEvent>().listen((event) {
  ///   print('Neue Chat-Nachricht: ${event.message}');
  /// });
  /// ```
  Stream<T> on<T extends AppEvent>() {
    return _eventController.stream.where((event) => event is T).cast<T>();
  }

  /// Event publishen/veröffentlichen
  ///
  /// Beispiel:
  /// ```dart
  /// eventBus.publish(ChatMessageCreatedEvent(message));
  /// ```
  void publish(AppEvent event) {
    if (_eventController.isClosed) {
      logger.warning(
        LogCategory.eventBus,
        'Tried to publish event to closed EventBus',
        data: {'eventType': event.runtimeType.toString()},
      );
      return;
    }
    _eventController.add(event);
  }

  /// Event-Bus schließen (bei App-Shutdown)
  void dispose() {
    _eventController.close();
  }

  /// Prüfen, ob Event-Bus geschlossen ist
  bool get isClosed => _eventController.isClosed;
}
