import 'package:dis_app/services/reminders/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

/// Die Wertobjekte tragen die Regel, die auf dem Gerät gefehlt hat:
/// eine Dosis gehört dem Körper, nicht dem Profil.
void main() {
  test('DoseTarget ist über Medikament, Tag und Uhrzeit gleich', () {
    final a = DoseTarget(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '12:50',
    );
    final b = DoseTarget(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '12:50',
    );
    expect(a, b);
    expect(<DoseTarget>{a, b}.length, 1);
  });

  test('Verschiedene Tage sind verschiedene Dosen', () {
    final heute = DoseTarget(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '12:50',
    );
    final morgen = DoseTarget(
      medicationId: 'm1',
      date: DateTime(2026, 8, 8),
      scheduledTime: '12:50',
    );
    expect(<DoseTarget>{heute, morgen}.length, 2);
  });

  test('DoseTarget.at setzt Datum und Uhrzeit zusammen', () {
    final dose = DoseTarget(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '08:05',
    );
    expect(dose.at, DateTime(2026, 8, 7, 8, 5));
  });

  test('DoseTarget.at versteht die Bedarfsform mit Praefix', () {
    final dose = DoseTarget(
      medicationId: 'prn1',
      date: DateTime(2026, 8, 7),
      scheduledTime: 'prn-15:00',
    );
    expect(dose.at, DateTime(2026, 8, 7, 15));
  });

  test('Der Dosisschluessel traegt kein Profil', () {
    final dose = DoseTarget(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '15:00',
    );
    expect(dose.toString(), isNot(contains('profile')));
  });

  test('Zwei Reminder derselben Dosis und Art sind gleich', () {
    final dose = DoseTarget(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '12:50',
    );
    final a = Reminder(
      target: dose,
      kind: ReminderKind.before10,
      fireAt: DateTime(2026, 8, 7, 12, 40),
    );
    final b = Reminder(
      target: dose,
      kind: ReminderKind.before10,
      fireAt: DateTime(2026, 8, 7, 12, 40),
    );
    expect(<Reminder>{a, b}.length, 1);
  });

  test('Verschiedene Arten derselben Dosis sind verschieden', () {
    final dose = DoseTarget(
      medicationId: 'm1',
      date: DateTime(2026, 8, 7),
      scheduledTime: '12:50',
    );
    final arten = <Reminder>{
      for (final kind in ReminderKind.values)
        Reminder(target: dose, kind: kind, fireAt: dose.at),
    };
    expect(arten.length, ReminderKind.values.length);
  });

  // Der Schlüssel reist als Payload mit der Meldung. Nur über ihn lässt
  // sich bei einer schon angezeigten Meldung sagen, wozu sie gehört.
  group('Vom Schluessel zurueck zum Ziel', () {
    test('Dosis', () {
      final dose = DoseTarget(
        medicationId: 'm1',
        date: DateTime(2026, 8, 7),
        scheduledTime: '12:50',
      );
      expect(ReminderTarget.fromSeed(dose.seed), dose);
    });

    test('Bedarfsdosis mit Praefix', () {
      final dose = DoseTarget(
        medicationId: 'm1',
        date: DateTime(2026, 12, 31),
        scheduledTime: 'prn-14:05',
      );
      expect(ReminderTarget.fromSeed(dose.seed), dose);
    });

    test('Termin', () {
      final ziel = EventTarget(
        eventId: 'e1',
        startTime: DateTime(2026, 8, 7, 17, 30),
      );
      expect(ReminderTarget.fromSeed(ziel.seed), ziel);
    });

    test('Termin in UTC bleibt derselbe Zeitpunkt', () {
      final ziel = EventTarget(
        eventId: 'e1',
        startTime: DateTime.utc(2026, 8, 7, 15, 30),
      );
      expect(ReminderTarget.fromSeed(ziel.seed), ziel);
    });

    test('Unlesbares ergibt null statt einer Ausnahme', () {
      for (final kaputt in [
        null,
        '',
        'kaputt',
        'med|m1',
        'med|m1|2026-8|12:50',
        'med|m1|2026-8-7|1250',
        'evt|e1|kein-datum',
        'xyz|a|b|c',
      ]) {
        expect(ReminderTarget.fromSeed(kaputt), isNull, reason: '$kaputt');
      }
    });
  });
}
