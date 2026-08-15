import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_texts.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Schalter für diskrete Erinnerungen entscheidet an genau einer Stelle.
void main() {
  final medikament = Medication(
    id: 'm1',
    name: 'Ritalin',
    dosage: '10mg',
    timesOfDay: const ['08:00'],
    profileIds: const ['lina'],
    createdAt: DateTime(2026, 8),
  );

  Reminder erinnerung(ReminderKind kind) => Reminder(
        target: DoseTarget(
          medicationId: 'm1',
          date: DateTime(2026, 8, 7),
          scheduledTime: '08:00',
        ),
        kind: kind,
        fireAt: DateTime(2026, 8, 7, 7, 30),
      );

  test('Im Klartext stehen Name und Dosis in der Meldung', () {
    final texte = ReminderTexts(discreet: false);
    final text = texte.medicationBody(erinnerung(ReminderKind.before30), medikament);
    expect(text, contains('Ritalin'));
    expect(text, contains('10mg'));
  });

  test('Diskret nennt weder Name noch Dosis', () {
    final texte = ReminderTexts(discreet: true);
    for (final kind in ReminderKind.values) {
      final text = texte.medicationBody(erinnerung(kind), medikament);
      expect(text, isNot(contains('Ritalin')), reason: kind.name);
      expect(text, isNot(contains('10mg')), reason: kind.name);
      expect(texte.title(erinnerung(kind)), 'Aurora');
    }
  });

  test('Jede Art bekommt Titel und Text', () {
    final texte = ReminderTexts(discreet: false);
    for (final kind in ReminderKind.values) {
      expect(texte.title(erinnerung(kind)), isNotEmpty, reason: kind.name);
      expect(
        texte.medicationBody(erinnerung(kind), medikament),
        isNotEmpty,
        reason: kind.name,
      );
    }
  });

  test('Die Wiederholung sagt, dass noch nichts bestaetigt wurde', () {
    final texte = ReminderTexts(discreet: false);
    final wdh = texte.medicationBody(erinnerung(ReminderKind.repeat), medikament);
    final jetzt = texte.medicationBody(erinnerung(ReminderKind.due), medikament);
    expect(wdh.length, greaterThan(jetzt.length));
  });
}
