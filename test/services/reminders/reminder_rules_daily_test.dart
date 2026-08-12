import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// R1 und R2: Erlaubnis als Eingabe, Vorwarnungen und begrenzte
/// Wiederholungen je Dosis.
void main() {
  final heute = DateTime(2026, 8, 7);
  final jetzt = DateTime(2026, 8, 7, 12);

  Medication med({
    String id = 'm1',
    List<String> zeiten = const ['12:50'],
    DateTime? start,
    DateTime? ende,
    bool aktiv = true,
    bool erinnerungen = true,
    MedicationType typ = MedicationType.daily,
  }) =>
      Medication(
        id: id,
        name: 'Testmed',
        dosage: '1 Tablette',
        timesOfDay: zeiten,
        profileIds: const ['lina'],
        createdAt: DateTime(2026, 8),
        isActive: aktiv,
        remindersEnabled: erinnerungen,
        type: typ,
        startDate: start,
        endDate: ende,
      );

  Set<Reminder> soll(
    List<Medication> meds, {
    List<MedicationLog> logs = const [],
    DateTime? now,
    bool erlaubt = true,
  }) =>
      desiredReminders(
        medications: meds,
        logs: logs,
        notificationsAllowed: erlaubt,
        now: now ?? jetzt,
      );

  Iterable<Reminder> heutigeVorwarnungen(Set<Reminder> alle) => alle.where(
        (r) => r.dose!.date == heute && r.kind != ReminderKind.due,
      );

  test('Ohne Erlaubnis entsteht keine einzige Erinnerung', () {
    expect(soll([med()], erlaubt: false), isEmpty);
  });

  test('Mit Erlaubnis entstehen Erinnerungen', () {
    expect(soll([med()]), isNotEmpty);
  });

  test('Je Dosis zwei Vorwarnungen und drei Wiederholungen', () {
    final einzeln = heutigeVorwarnungen(soll([med()]));
    expect(einzeln.where((r) => r.kind == ReminderKind.before30), hasLength(1));
    expect(einzeln.where((r) => r.kind == ReminderKind.before10), hasLength(1));
    expect(einzeln.where((r) => r.kind == ReminderKind.repeat), hasLength(3));
  });

  test('Die Vorwarnungen liegen 30 und 10 Minuten davor', () {
    final einzeln = heutigeVorwarnungen(soll([med()]));
    expect(
      einzeln.firstWhere((r) => r.kind == ReminderKind.before30).fireAt,
      DateTime(2026, 8, 7, 12, 20),
    );
    expect(
      einzeln.firstWhere((r) => r.kind == ReminderKind.before10).fireAt,
      DateTime(2026, 8, 7, 12, 40),
    );
  });

  test('Die Wiederholungen liegen 10, 20 und 30 Minuten danach', () {
    final zeiten = heutigeVorwarnungen(soll([med()]))
        .where((r) => r.kind == ReminderKind.repeat)
        .map((r) => r.fireAt)
        .toList()
      ..sort();
    expect(zeiten, [
      DateTime(2026, 8, 7, 13),
      DateTime(2026, 8, 7, 13, 10),
      DateTime(2026, 8, 7, 13, 20),
    ]);
  });

  test('Vergangene Zeitpunkte entstehen nicht', () {
    final einzeln = heutigeVorwarnungen(
      soll([med()], now: DateTime(2026, 8, 7, 12, 30)),
    );
    expect(einzeln.where((r) => r.kind == ReminderKind.before30), isEmpty);
    expect(einzeln.where((r) => r.kind == ReminderKind.before10), hasLength(1));
  });

  test('Zur Dosiszeit entsteht genau eine Meldung je Dosis', () {
    final heutigeDue = soll([med()]).where(
      (r) => r.kind == ReminderKind.due && r.dose!.date == heute,
    );
    expect(heutigeDue, hasLength(1));
    expect(heutigeDue.single.fireAt, DateTime(2026, 8, 7, 12, 50));
  });

  test('Die Meldung zur Einnahmezeit reicht sieben Tage', () {
    final tage = soll([med()])
        .where((r) => r.kind == ReminderKind.due)
        .map((r) => r.dose!.date)
        .toSet();
    expect(tage.length, greaterThanOrEqualTo(7));
  });

  test('Vorwarnungen entstehen nur im kurzen Horizont', () {
    final vorwarnTage = soll([med()])
        .where((r) => r.kind == ReminderKind.before30)
        .map((r) => r.dose!.date)
        .toSet();
    expect(vorwarnTage.length, lessThanOrEqualTo(2));
  });

  test('Inaktives Medikament erzeugt nichts', () {
    expect(soll([med(aktiv: false)]), isEmpty);
  });

  test('Abgeschaltete Erinnerungen erzeugen nichts', () {
    expect(soll([med(erinnerungen: false)]), isEmpty);
  });

  test('Bedarfsmedizin ohne Einnahme erzeugt hier nichts', () {
    expect(soll([med(typ: MedicationType.asNeeded)]), isEmpty);
  });

  test('Vor dem Startdatum entsteht nichts', () {
    final ergebnis = soll([med(start: DateTime(2026, 8, 10))]);
    expect(
      ergebnis.where((r) => r.dose!.date.isBefore(DateTime(2026, 8, 10))),
      isEmpty,
    );
    expect(
      ergebnis,
      isNotEmpty,
      reason: 'ab dem Startdatum liegt es im Sieben-Tage-Fenster',
    );
  });

  test('Nach dem Enddatum entsteht nichts', () {
    expect(soll([med(ende: DateTime(2026, 8, 5))]), isEmpty);
  });

  test('Zwei Medikamente zur selben Zeit stoeren einander nicht', () {
    final alle = soll([med(), med(id: 'm2')]);
    expect(alle.map((r) => r.dose!.medicationId).toSet(), {'m1', 'm2'});
  });
}
