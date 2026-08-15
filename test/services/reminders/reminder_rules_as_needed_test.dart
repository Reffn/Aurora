import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// R6 — Bedarfsmedizin läuft durch dieselbe Ableitung.
void main() {
  Medication bedarf({int? maxDosen = 4, int? abstand = 4}) => Medication(
        id: 'prn1',
        name: 'Bedarfsmittel',
        dosage: '1 Tablette',
        timesOfDay: const [],
        profileIds: const ['lina'],
        createdAt: DateTime(2026, 8),
        type: MedicationType.asNeeded,
        maxDailyDoses: maxDosen,
        minIntervalHours: abstand,
      );

  MedicationLog einnahme(DateTime wann) => MedicationLog(
        id: 'l-${wann.millisecondsSinceEpoch}',
        medicationId: 'prn1',
        takenAt: wann,
        profileId: 'lina',
        status: MedicationStatus.taken,
        confirmedAt: wann,
      );

  Set<Reminder> soll({
    required List<MedicationLog> logs,
    Medication? medikament,
    DateTime? jetzt,
  }) =>
      desiredReminders(
        medications: [medikament ?? bedarf()],
        logs: logs,
        notificationsAllowed: true,
        now: jetzt ?? DateTime(2026, 8, 7, 12),
      );

  test('Nach einer Einnahme entstehen vier Freigabe-Erinnerungen', () {
    final freigabe = soll(logs: [einnahme(DateTime(2026, 8, 7, 11))])
        .where((r) => r.kind == ReminderKind.available)
        .toList();
    expect(freigabe, hasLength(4));
    expect(
      freigabe.map((r) => r.fireAt).toList()..sort(),
      [
        DateTime(2026, 8, 7, 14, 30),
        DateTime(2026, 8, 7, 14, 50),
        DateTime(2026, 8, 7, 14, 55),
        DateTime(2026, 8, 7, 15),
      ],
    );
  });

  test('Ohne Mindestabstand entsteht keine Freigabe-Erinnerung', () {
    expect(
      soll(
        medikament: bedarf(abstand: null),
        logs: [einnahme(DateTime(2026, 8, 7, 11))],
      ),
      isEmpty,
    );
  });

  test('Bei erreichtem Tageslimit entsteht nichts', () {
    expect(
      soll(
        medikament: bedarf(maxDosen: 2),
        logs: [
          einnahme(DateTime(2026, 8, 7, 8)),
          einnahme(DateTime(2026, 8, 7, 11)),
        ],
      ),
      isEmpty,
    );
  });

  test('Ohne Einnahme entsteht nichts', () {
    expect(soll(logs: const []), isEmpty);
  });

  test('Vergangene Freigabe erzeugt nichts', () {
    expect(soll(logs: [einnahme(DateTime(2026, 8, 7, 6))]), isEmpty);
  });

  test('Nur die letzte Einnahme zaehlt', () {
    final freigabe = soll(
      logs: [
        einnahme(DateTime(2026, 8, 7, 8)),
        einnahme(DateTime(2026, 8, 7, 11)),
      ],
    ).where((r) => r.kind == ReminderKind.available);
    expect(
      freigabe.map((r) => r.fireAt).reduce((a, b) => a.isAfter(b) ? a : b),
      DateTime(2026, 8, 7, 15),
    );
  });

  test('Einnahme von gestern zaehlt nicht fuer heute', () {
    expect(soll(logs: [einnahme(DateTime(2026, 8, 6, 23))]), isEmpty);
  });
}
