import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/modules/calendar/calendar_view_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('initialCalendarDraftTimes', () {
    test('wechselt kurz vor Mitternacht sauber auf den naechsten Tag', () {
      final draft = initialCalendarDraftTimes(DateTime(2026, 8, 8, 23, 47, 30));

      expect(draft.start, DateTime(2026, 8, 9));
      expect(draft.end, DateTime(2026, 8, 9, 1));
    });

    test('rundet vorwaerts auf die naechste Viertelstunde', () {
      final draft = initialCalendarDraftTimes(DateTime(2026, 8, 8, 10, 2));

      expect(draft.start, DateTime(2026, 8, 8, 10, 15));
      expect(draft.end.difference(draft.start), const Duration(hours: 1));
    });

    test('behaelt die Dauer, wenn der Beginn verschoben wird', () {
      const duration = Duration(minutes: 90);
      final draft = CalendarDraftTimes(
        start: DateTime(2026, 8, 8, 10),
        end: DateTime(2026, 8, 8, 10).add(duration),
      );

      final moved = draft.moveStartTo(DateTime(2026, 8, 9, 23, 30));

      expect(moved.start, DateTime(2026, 8, 9, 23, 30));
      expect(moved.end, DateTime(2026, 8, 10, 1));
    });
  });

  test('durationUntilNextDay wechselt exakt am lokalen Tagesende', () {
    final remaining = durationUntilNextDay(
      DateTime(2026, 8, 9, 23, 59, 59, 500),
    );

    expect(remaining, const Duration(milliseconds: 500));
  });

  group('CalendarAgenda', () {
    CalendarEvent event(String id, DateTime start) => CalendarEvent(
      id: id,
      title: id,
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
      profileIds: const ['p1'],
    );

    test('behaelt auch weit entfernte kommende Termine sichtbar', () {
      final now = DateTime(2026, 8, 8, 12);
      final agenda = CalendarAgenda.fromEvents([
        event('gestern', DateTime(2026, 8, 7, 9)),
        event('heute', DateTime(2026, 8, 8, 18)),
        event('naechste-woche', DateTime(2026, 8, 16, 10)),
        event('naechstes-jahr', DateTime(2027, 2, 3, 8)),
      ], today: now);

      expect(agenda.today.map((item) => item.id), ['heute']);
      expect(agenda.upcoming.map((item) => item.id), [
        'naechste-woche',
        'naechstes-jahr',
      ]);
    });

    test('liefert Termine eines frei gewaehlten Tages chronologisch', () {
      final agenda = CalendarAgenda.fromEvents([
        event('spaet', DateTime(2026, 9, 20, 16)),
        event('frueh', DateTime(2026, 9, 20, 8)),
        event('anderer-tag', DateTime(2026, 9, 21, 8)),
      ], today: DateTime(2026, 8, 8));

      expect(agenda.eventsOn(DateTime(2026, 9, 20)).map((item) => item.id), [
        'frueh',
        'spaet',
      ]);
    });

    test('verliert an der Zeitumstellung keinen Termin nach Mitternacht', () {
      // Am 29. März 2026 springt die mitteleuropäische Zeit um 02:00 auf 03:00.
      // Dieser Tag hat 23 Stunden. Mitternacht plus `Duration(days: 1)` landet
      // deshalb am 30. um 01:00 — und ein Termin um 00:30 gehörte weder zu
      // „heute" noch zu „kommend". Er verschwand aus der Ansicht.
      //
      // Der Test greift nur in einer Zeitzone mit Sommerzeit. In UTC läuft er
      // durch, ohne etwas zu beweisen; das ist der Preis dafür, dass die Logik
      // mit der lokalen Zeit des Geräts rechnet — und das muss sie, weil der
      // Kalender die Tage der Nutzerin zeigt, nicht die von Greenwich.
      final agenda = CalendarAgenda.fromEvents(
        [event('nachtschicht', DateTime(2026, 3, 30, 0, 30))],
        today: DateTime(2026, 3, 29, 12),
      );

      expect(
        agenda.upcoming.map((item) => item.id),
        ['nachtschicht'],
        reason: 'ein Termin darf an keinem Tag des Jahres verschwinden',
      );
    });
  });
}
