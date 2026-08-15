import 'package:dis_app/core/events/app_event.dart';
import 'package:dis_app/models/calendar_event.dart';

/// Event: Neues Kalender-Event wurde erstellt
class CalendarEventCreatedEvent extends AppEvent {
  CalendarEventCreatedEvent(this.event);
  final CalendarEvent event;
}

/// Event: Kalender-Event wurde aktualisiert
class CalendarEventUpdatedEvent extends AppEvent {
  CalendarEventUpdatedEvent(this.event);
  final CalendarEvent event;
}

/// Event: Kalender-Event wurde gelöscht
class CalendarEventDeletedEvent extends AppEvent {
  CalendarEventDeletedEvent(this.eventId);
  final String eventId;
}
