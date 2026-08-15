import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kennungen müssen aus dem Inhalt herleitbar sein.
///
/// Nur so lässt sich vergleichen, was das Betriebssystem vorgemerkt hat,
/// mit dem, was gelten soll — ohne eine dritte Kopie der Wahrheit.
void main() {
  Reminder r({
    String med = 'm1',
    int day = 7,
    String time = '12:50',
    ReminderKind kind = ReminderKind.before10,
    int? repeat,
  }) =>
      Reminder(
        target: DoseTarget(
          medicationId: med,
          date: DateTime(2026, 8, day),
          scheduledTime: time,
        ),
        kind: kind,
        fireAt: DateTime(2026, 8, day, 12, 40),
        repeatIndex: repeat,
      );

  test('Gleiche Erinnerung ergibt gleiche Kennung', () {
    expect(reminderId(r()), reminderId(r()));
  });

  test('Anderer Tag ergibt andere Kennung', () {
    expect(reminderId(r()), isNot(reminderId(r(day: 8))));
  });

  test('Andere Art ergibt andere Kennung', () {
    expect(
      reminderId(r()),
      isNot(reminderId(r(kind: ReminderKind.before30))),
    );
  });

  test('Andere Wiederholung ergibt andere Kennung', () {
    expect(
      reminderId(r(kind: ReminderKind.repeat, repeat: 1)),
      isNot(reminderId(r(kind: ReminderKind.repeat, repeat: 2))),
    );
  });

  test('Kennungen liegen im Namensraum Medikament', () {
    expect(isMedicationId(reminderId(r())), isTrue);
    expect(isMedicationId(namespacedId(kNamespaceEvent, 'termin-1')), isFalse);
  });

  test('Kennungen passen in Androids 32-Bit-Bereich', () {
    final id = reminderId(r());
    expect(id, greaterThan(0));
    expect(id, lessThan(2147483647));
  });

  test('500 Dosen ergeben 500 verschiedene Kennungen', () {
    final ids = <int>{};
    for (var med = 0; med < 10; med++) {
      for (var day = 1; day <= 10; day++) {
        for (final time in ['08:00', '12:00', '18:00', '22:00', '23:30']) {
          ids.add(reminderId(r(med: 'med-$med', day: day, time: time)));
        }
      }
    }
    expect(ids.length, 500);
  });

  test('Termin-Kennungen kollidieren nicht mit Medikamenten-Kennungen', () {
    final termine = <int>{
      for (var i = 0; i < 200; i++) namespacedId(kNamespaceEvent, 'termin-$i'),
    };
    expect(termine.every((id) => !isMedicationId(id)), isTrue);
  });

  Reminder termin({String id = 'e1', int stunde = 15}) => Reminder(
        target: EventTarget(
          eventId: id,
          startTime: DateTime(2026, 8, 7, stunde),
        ),
        kind: ReminderKind.event,
        fireAt: DateTime(2026, 8, 7, stunde - 1),
      );

  test('Derselbe Termin zu zwei Startzeiten ergibt zwei Kennungen', () {
    expect(
      reminderId(termin()),
      isNot(reminderId(termin(stunde: 17))),
      reason: 'sonst ueberschreibt das Anmelden das Abmelden beim Verschieben',
    );
  });

  test('Termin-Kennungen liegen im Namensraum Termin', () {
    expect(isEventId(reminderId(termin())), isTrue);
    expect(isMedicationId(reminderId(termin())), isFalse);
    expect(isOwnId(reminderId(termin())), isTrue);
  });

  test('Fremde Namensraeume gehoeren dem Abgleich nicht', () {
    expect(isOwnId(namespacedId(3, 'fremd')), isFalse);
  });

  test('500 Dosen und 500 Termine ergeben 1000 verschiedene Kennungen', () {
    final ids = <int>{};
    for (var med = 0; med < 10; med++) {
      for (var day = 1; day <= 10; day++) {
        for (final time in ['08:00', '12:00', '18:00', '22:00', '23:30']) {
          ids.add(reminderId(r(med: 'med-$med', day: day, time: time)));
        }
      }
    }
    for (var e = 0; e < 500; e++) {
      ids.add(
        reminderId(
          Reminder(
            target: EventTarget(
              eventId: 'evt-$e',
              startTime: DateTime(2026, 8, 7, e % 24, e % 60),
            ),
            kind: ReminderKind.event,
            fireAt: DateTime(2026, 8, 7),
          ),
        ),
      );
    }
    expect(ids.length, 1000);
  });
}
