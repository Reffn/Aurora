import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// R3 und R5 — Befund 2 des Gerätetests als Regel.
///
/// Vitamin D wurde um 12:22 als genommen markiert. Die Alarme 14:30,
/// 14:50 und 15:00 standen danach unverändert im System: `_onMedicationTaken`
/// rief nur `cancelRepeatReminders()`. Hier kann das nicht mehr passieren,
/// weil es keinen Aufruf gibt, den man vergessen könnte.
void main() {
  final heute = DateTime(2026, 8, 7);
  final jetzt = DateTime(2026, 8, 7, 12);

  Medication med() => Medication(
        id: 'm1',
        name: 'Vitamin D',
        dosage: '1 Tablette',
        timesOfDay: const ['15:00'],
        profileIds: const ['lina', 'mina'],
        createdAt: DateTime(2026, 8),
      );

  MedicationLog log({
    required MedicationStatus status,
    String zeit = '15:00',
    String profil = 'lina',
    DateTime? wann,
  }) =>
      MedicationLog(
        id: 'l-${status.name}-$zeit-$profil-${wann?.millisecondsSinceEpoch}',
        medicationId: 'm1',
        takenAt: wann ?? DateTime(2026, 8, 7, 12, 22),
        profileId: profil,
        status: status,
        confirmedAt: wann ?? DateTime(2026, 8, 7, 12, 22),
        scheduledTime: zeit,
      );

  Set<Reminder> soll(List<MedicationLog> logs) => desiredReminders(
        medications: [med()],
        logs: logs,
        notificationsAllowed: true,
        now: jetzt,
      );

  Iterable<Reminder> heutigeMeldungen(Set<Reminder> alle) =>
      alle.where((r) => r.dose!.date == heute);

  for (final status in [
    MedicationStatus.taken,
    MedicationStatus.refused,
    MedicationStatus.skipped,
  ]) {
    test('Status ${status.name}: keine Einzelmeldung mehr fuer diese Dosis',
        () {
      expect(heutigeMeldungen(soll([log(status: status)])), isEmpty);
    });

    test('Status ${status.name}: die naechste Meldung ist die von morgen', () {
      final naechste = soll([log(status: status)])
          .where((r) => r.kind == ReminderKind.due)
          .map((r) => r.fireAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      expect(naechste, DateTime(2026, 8, 8, 15));
    });
  }

  test('Ohne Log bleibt die naechste Meldung auf heute', () {
    final naechste = soll(const [])
        .where((r) => r.kind == ReminderKind.due)
        .map((r) => r.fireAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    expect(naechste, DateTime(2026, 8, 7, 15));
  });

  test('Ein Log von gestern raeumt die heutige Dosis nicht ab', () {
    final ergebnis = soll([
      log(status: MedicationStatus.taken, wann: DateTime(2026, 8, 6, 15, 1)),
    ]);
    expect(heutigeMeldungen(ergebnis), isNotEmpty);
  });

  test('Der juengste Log gewinnt: erst genommen, dann korrigiert', () {
    final ergebnis = soll([
      log(status: MedicationStatus.taken, wann: DateTime(2026, 8, 7, 12, 10)),
      log(status: MedicationStatus.snoozed, wann: DateTime(2026, 8, 7, 12, 20)),
    ]);
    expect(
      heutigeMeldungen(ergebnis),
      isNotEmpty,
      reason: 'Aufschub ist keine Erledigung',
    );
  });

  test('R5: Lina nimmt, fuer Mina ist dieselbe Dosis erledigt', () {
    final ergebnis = soll([
      log(status: MedicationStatus.taken),
    ]);
    expect(
      heutigeMeldungen(ergebnis),
      isEmpty,
      reason: 'ein Koerper, eine Dosis — das Profil steht nicht im Schluessel',
    );
  });
}
