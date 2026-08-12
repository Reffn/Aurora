import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// R7 sowie Horizont, Reinheit und Sommerzeit.
void main() {
  final jetzt = DateTime(2026, 8, 7, 0, 30);

  Medication med(String id, List<String> zeiten) => Medication(
        id: id,
        name: 'Med $id',
        dosage: '1 Tablette',
        timesOfDay: zeiten,
        profileIds: const ['lina'],
        createdAt: DateTime(2026, 8),
      );

  test('Vorwarnungen bleiben im kurzen Horizont, die Einnahmezeit nicht', () {
    final alle = desiredReminders(
      medications: [med('m1', const ['12:00'])],
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
    );
    final vorwarnTage = alle
        .where((r) => r.kind != ReminderKind.due)
        .map((r) => r.dose!.date)
        .toSet();
    final dueTage =
        alle.where((r) => r.kind == ReminderKind.due).map((r) => r.dose!.date).toSet();
    expect(vorwarnTage, {DateTime(2026, 8, 7), DateTime(2026, 8, 8)});
    expect(dueTage.length, greaterThanOrEqualTo(7));
  });

  test('Das Budget kuerzt und sagt, wie viel wegfiel', () {
    var verworfen = 0;
    final ergebnis = desiredReminders(
      medications: [
        for (var i = 0; i < 6; i++)
          med('m$i', const ['08:00', '12:00', '18:00', '22:00']),
      ],
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
      budget: 20,
      onDropped: (count) => verworfen = count,
    );
    expect(ergebnis, hasLength(20));
    expect(verworfen, greaterThan(0));
  });

  test('Die Meldungen zur Einnahmezeit ueberleben die Kuerzung', () {
    final ergebnis = desiredReminders(
      medications: [
        for (var i = 0; i < 6; i++)
          med('m$i', const ['08:00', '12:00', '18:00', '22:00']),
      ],
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
      budget: 24,
    );
    expect(
      ergebnis.where((r) => r.kind == ReminderKind.due),
      hasLength(24),
      reason: 'die Einnahmezeit zuerst, Vorwarnungen danach',
    );
  });

  test('Ohne Ueberschreitung wird nichts verworfen', () {
    var verworfen = -1;
    desiredReminders(
      medications: [med('m1', const ['12:00'])],
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
      onDropped: (count) => verworfen = count,
    );
    expect(verworfen, 0);
  });

  test('Die Funktion ist rein: gleiche Eingabe, gleiche Ausgabe', () {
    List<Medication> meds() => [med('m1', const ['12:00', '18:00'])];
    final a = desiredReminders(
      medications: meds(),
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
    );
    final b = desiredReminders(
      medications: meds(),
      logs: const [],
      notificationsAllowed: true,
      now: jetzt,
    );
    expect(a, b);
  });

  test('Sommerzeitende: die Dosiszeit bleibt Ortszeit', () {
    final ergebnis = desiredReminders(
      medications: [med('m1', const ['02:30'])],
      logs: const [],
      notificationsAllowed: true,
      now: DateTime(2026, 10, 25),
    );
    expect(ergebnis.map((r) => r.dose!.scheduledTime).toSet(), {'02:30'});
    expect(
      ergebnis.where((r) => r.dose!.date == DateTime(2026, 10, 25)),
      isNotEmpty,
      reason: 'der Umstellungstag faellt nicht aus',
    );
    expect(
      ergebnis.every((r) => r.fireAt.hour == 2 || r.fireAt.hour == 1 || r.fireAt.hour == 3),
      isTrue,
      reason: 'Vorwarnung, Einnahmezeit und Wiederholungen liegen um 02:30 herum',
    );
  });
}
