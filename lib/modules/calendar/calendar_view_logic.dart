import 'package:dis_app/models/calendar_event.dart';

/// Ein sicherer Vorschlag fuer einen neuen Termin.
///
/// Beginn und Ende bleiben absichtlich als ganze [DateTime]-Werte zusammen.
/// So kann Mitternacht nicht dazu fuehren, dass nur die Uhrzeit weiterlaeuft,
/// waehrend das Enddatum am Vortag stehen bleibt.
class CalendarDraftTimes {
  const CalendarDraftTimes({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  CalendarDraftTimes moveStartTo(DateTime newStart) {
    final currentDuration = end.difference(start);
    final safeDuration = currentDuration > Duration.zero
        ? currentDuration
        : const Duration(hours: 1);
    return CalendarDraftTimes(start: newStart, end: newStart.add(safeDuration));
  }
}

/// Beginnt in der naechsten Viertelstunde und dauert zunaechst eine Stunde.
CalendarDraftTimes initialCalendarDraftTimes(DateTime reference) {
  final minuteStart = DateTime(
    reference.year,
    reference.month,
    reference.day,
    reference.hour,
    reference.minute,
  );
  final isExactQuarter =
      reference.minute % 15 == 0 &&
      reference.second == 0 &&
      reference.millisecond == 0 &&
      reference.microsecond == 0;
  final minutesUntilQuarter = isExactQuarter ? 0 : 15 - (reference.minute % 15);
  final start = minuteStart.add(Duration(minutes: minutesUntilQuarter));

  return CalendarDraftTimes(
    start: start,
    end: start.add(const Duration(hours: 1)),
  );
}

/// Restzeit bis zum naechsten lokalen Kalendertag.
Duration durationUntilNextDay(DateTime reference) {
  final nextDay = DateTime(reference.year, reference.month, reference.day + 1);
  return nextDay.difference(reference);
}

/// Die ruhige Kalenderansicht: heute, danach alle kommenden Termine.
///
/// Kein Termin wird durch ein kuenstliches Zeitfenster ausgeblendet.
class CalendarAgenda {
  CalendarAgenda._({
    required List<CalendarEvent> all,
    required this.today,
    required this.upcoming,
  }) : _all = all;

  factory CalendarAgenda.fromEvents(
    Iterable<CalendarEvent> events, {
    required DateTime today,
  }) {
    final startOfToday = _day(today);
    // Kein `add(Duration(days: 1))`: an der Zeitumstellung hat ein Tag 23 oder
    // 25 Stunden, und 24 Stunden ab Mitternacht landen dann neben dem nächsten
    // Tagesbeginn. Termine in der entstehenden Lücke gehörten weder zu „heute"
    // noch zu „kommend" und verschwanden aus der Ansicht. `DateTime`
    // normalisiert einen überlaufenden Tageswert selbst — dasselbe Muster wie
    // in [durationUntilNextDay] weiter oben.
    final startOfTomorrow = DateTime(
      startOfToday.year,
      startOfToday.month,
      startOfToday.day + 1,
    );
    final all = events.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return CalendarAgenda._(
      all: all,
      today: all
          .where((event) => _day(event.startTime) == startOfToday)
          .toList(growable: false),
      upcoming: all
          .where((event) => !event.startTime.isBefore(startOfTomorrow))
          .toList(growable: false),
    );
  }

  final List<CalendarEvent> _all;
  final List<CalendarEvent> today;
  final List<CalendarEvent> upcoming;

  List<CalendarEvent> eventsOn(DateTime day) {
    final wanted = _day(day);
    return _all
        .where((event) => _day(event.startTime) == wanted)
        .toList(growable: false);
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
