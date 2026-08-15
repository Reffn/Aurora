import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/events/calendar_events.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/services/comment_service.dart';
import 'package:hive_ce/hive.dart';

/// Calendar-Service - Verwaltet Kalender-Events mit Hive-Persistierung
/// Verwendet Hive ValueListenable für reaktive UI-Updates
class CalendarService extends BaseService {
  CalendarService(super.eventBus);
  late Box<CalendarEvent> _eventsBox;

  @override
  Future<void> openBoxes() async {
    _eventsBox = await Hive.openBox<CalendarEvent>(HiveBoxNames.calendarEvents);
  }

  @override
  void subscribeToEvents() {
    eventBus.on<CalendarEventCreatedEvent>().listen(_handleEventCreated);
    eventBus.on<CalendarEventUpdatedEvent>().listen(_handleEventUpdated);
    eventBus.on<CalendarEventDeletedEvent>().listen(_handleEventDeleted);
  }

  @override
  Future<void> closeBoxes() async {
    await _eventsBox.close();
  }

  /// Zugriff auf Events-Box für ValueListenable
  /// UI kann damit ValueListenableBuilder nutzen für automatische Updates
  Box<CalendarEvent> get eventsBox => _eventsBox;

  /// Alle Events abrufen (für nicht-reaktive Zugriffe)
  List<CalendarEvent> get events =>
      List.unmodifiable(_eventsBox.values.toList());

  /// Events für ein bestimmtes Datum abrufen
  List<CalendarEvent> getEventsForDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _eventsBox.values.where((event) {
      return event.startTime.isBefore(dayEnd) &&
          event.endTime.isAfter(dayStart);
    }).toList();
  }

  /// Events für einen Monat abrufen
  List<CalendarEvent> getEventsForMonth(int year, int month) {
    final monthStart = DateTime(year, month);
    final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);

    return _eventsBox.values.where((event) {
      return event.startTime.isBefore(monthEnd) &&
          event.endTime.isAfter(monthStart);
    }).toList();
  }

  /// Event per ID abrufen
  CalendarEvent? getEventById(String id) {
    try {
      return _eventsBox.values.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Event-Erstellung
  void _handleEventCreated(CalendarEventCreatedEvent event) {
    try {
      _eventsBox.add(event.event);
      // Hive notified automatisch alle ValueListenable Listener!
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error creating calendar event',
        data: {'eventId': event.event.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Event-Aktualisierung
  void _handleEventUpdated(CalendarEventUpdatedEvent event) {
    try {
      dynamic eventKey;
      try {
        eventKey = _eventsBox.keys.firstWhere(
          (key) => _eventsBox.get(key)?.id == event.event.id,
        );
      } catch (e) {
        logger.warning(
          LogCategory.service,
          'Calendar event not found for update',
          data: {'eventId': event.event.id},
        );
        return;
      }

      _eventsBox.put(eventKey, event.event);
      // Hive notified automatisch alle ValueListenable Listener!
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error updating calendar event',
        data: {'eventId': event.event.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Event-Löschung
  void _handleEventDeleted(CalendarEventDeletedEvent event) {
    try {
      dynamic eventKey;
      try {
        eventKey = _eventsBox.keys.firstWhere(
          (key) => _eventsBox.get(key)?.id == event.eventId,
        );
      } catch (e) {
        logger.warning(
          LogCategory.service,
          'Calendar event not found for deletion',
          data: {'eventId': event.eventId},
        );
        return;
      }

      _eventsBox.delete(eventKey);

      // Cascade delete: Alle unified Comments löschen
      final commentService = getIt<CommentService>();
      commentService.deleteCommentsForParent(
        CommentableType.calendar,
        event.eventId,
      );

      // Hive notified automatisch alle ValueListenable Listener!
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error deleting calendar event',
        data: {'eventId': event.eventId, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Alle Kalender-Events löschen (Debug-Option)
  Future<void> clearAll() async {
    await _eventsBox.clear();
    // Hive notified automatisch alle ValueListenable Listener!
  }
}
