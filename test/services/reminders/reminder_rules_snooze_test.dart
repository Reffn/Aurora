import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// R4 — Befund 3 und 4 des Gerätetests als eine Regel.
///
/// „Später" um 12:21 auf die 30-Minuten-Vorwarnung ergab `snoozedUntil`
/// 13:21, während die Dosis für 12:50 gedacht war; die Vorwarnungen um
/// 12:40 und 12:50 blieben zusätzlich stehen, und beim Betriebssystem war
/// der Aufschub überhaupt nicht angemeldet.
void main() {
  final heute = DateTime(2026, 8, 7);

  Medication med({List<String> zeiten = const ['12:50']}) => Medication(
        id: 'm1',
        name: 'Testmed',
        dosage: '1 Tablette',
        timesOfDay: zeiten,
        profileIds: const ['lina'],
        createdAt: DateTime(2026, 8),
      );

  MedicationLog aufgeschoben({
    required DateTime getippt,
    String zeit = '12:50',
  }) =>
      MedicationLog(
        id: 'l1',
        medicationId: 'm1',
        takenAt: getippt,
        profileId: 'lina',
        status: MedicationStatus.snoozed,
        confirmedAt: getippt,
        snoozedUntil: getippt.add(const Duration(hours: 1)),
        scheduledTime: zeit,
      );

  Set<Reminder> soll({
    required List<MedicationLog> logs,
    required DateTime jetzt,
    List<String> zeiten = const ['12:50'],
  }) =>
      desiredReminders(
        medications: [med(zeiten: zeiten)],
        logs: logs,
        notificationsAllowed: true,
        now: jetzt,
      );

  Iterable<Reminder> fuerHeute(Set<Reminder> alle) =>
      alle.where((r) => r.dose!.date == heute);

  test('Aufschub vor der Dosiszeit rueckt auf die Dosiszeit', () {
    final ergebnis = fuerHeute(
      soll(
        logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 21))],
        jetzt: DateTime(2026, 8, 7, 12, 22),
      ),
    ).toList();
    expect(ergebnis, hasLength(1));
    expect(ergebnis.single.kind, ReminderKind.snooze);
    expect(ergebnis.single.fireAt, DateTime(2026, 8, 7, 12, 50));
  });

  test('Aufschub loescht die uebrigen Erinnerungen dieser Dosis', () {
    final ergebnis = fuerHeute(
      soll(
        logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 21))],
        jetzt: DateTime(2026, 8, 7, 12, 22),
      ),
    );
    expect(ergebnis.where((r) => r.kind == ReminderKind.before10), isEmpty);
    expect(ergebnis.where((r) => r.kind == ReminderKind.repeat), isEmpty);
  });

  test('Aufschub nach der Dosiszeit gibt dreissig Minuten Ruhe', () {
    final auf = fuerHeute(
      soll(
        logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 55))],
        jetzt: DateTime(2026, 8, 7, 12, 56),
      ),
    ).firstWhere((r) => r.kind == ReminderKind.snooze);
    expect(auf.fireAt, DateTime(2026, 8, 7, 13, 25));
  });

  test('Aufschub reicht nie ueber die naechste Dosis hinaus', () {
    final auf = fuerHeute(
      soll(
        zeiten: const ['12:50', '13:10'],
        logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 55))],
        jetzt: DateTime(2026, 8, 7, 12, 56),
      ),
    ).firstWhere(
      (r) => r.kind == ReminderKind.snooze && r.dose!.scheduledTime == '12:50',
    );
    expect(
      auf.fireAt,
      DateTime(2026, 8, 7, 13, 5),
      reason: 'naechste Dosis 13:10 minus fuenf Minuten Abstand',
    );
  });

  test('Ein bereits verstrichener Aufschub erzeugt nichts mehr', () {
    expect(
      fuerHeute(
        soll(
          logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 55))],
          jetzt: DateTime(2026, 8, 7, 14),
        ),
      ),
      isEmpty,
    );
  });

  test('Aufschub ueber Mitternacht ueberlebt den Tageswechsel', () {
    // Um 23:50 auf die 22:00er-Dosis „spaeter" getippt: Ziel 00:20 am
    // Folgetag. Beim naechsten Abgleich nach Mitternacht darf die Meldung
    // nicht verschwinden, nur weil die Dosis von gestern stammt.
    final ergebnis = desiredReminders(
      medications: [
        Medication(
          id: 'm1',
          name: 'Nachtmittel',
          dosage: '1 Tablette',
          timesOfDay: const ['22:00'],
          profileIds: const ['lina'],
          createdAt: DateTime(2026, 8),
        ),
      ],
      logs: [
        MedicationLog(
          id: 'l1',
          medicationId: 'm1',
          takenAt: DateTime(2026, 8, 7, 23, 50),
          profileId: 'lina',
          status: MedicationStatus.snoozed,
          confirmedAt: DateTime(2026, 8, 7, 23, 50),
          scheduledTime: '22:00',
        ),
      ],
      notificationsAllowed: true,
      now: DateTime(2026, 8, 8, 0, 10),
    );

    final auf = ergebnis.where((r) => r.kind == ReminderKind.snooze);
    expect(auf, hasLength(1));
    expect(auf.single.fireAt, DateTime(2026, 8, 8, 0, 20));
  });

  test('Aufschub laesst die Meldung von morgen unberuehrt', () {
    final morgen = soll(
      logs: [aufgeschoben(getippt: DateTime(2026, 8, 7, 12, 21))],
      jetzt: DateTime(2026, 8, 7, 12, 22),
    ).where(
      (r) => r.kind == ReminderKind.due && r.dose!.date == DateTime(2026, 8, 8),
    );
    expect(morgen, hasLength(1));
    expect(morgen.single.fireAt, DateTime(2026, 8, 8, 12, 50));
  });
}
