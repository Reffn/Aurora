import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// Termine: genau eine Erinnerung, kein Sieben-Tage-Deckel, keine
/// Wiederholung. Es gibt nichts abzuhaken, nur etwas rechtzeitig zu wissen.
void main() {
  final jetzt = DateTime(2026, 8, 7, 15);

  CalendarEvent termin({
    String id = 'e1',
    DateTime? start,
    bool erinnerung = true,
    int? vorlauf = 30,
  }) => CalendarEvent(
    id: id,
    title: 'Arzt',
    startTime: start ?? DateTime(2026, 8, 7, 17),
    endTime: (start ?? DateTime(2026, 8, 7, 17)).add(
      const Duration(hours: 1),
    ),
    profileIds: const ['lina'],
    notificationEnabled: erinnerung,
    reminderMinutesBefore: vorlauf,
  );

  Set<Reminder> soll(List<CalendarEvent> events, {DateTime? now}) =>
      desiredReminders(
        medications: const [],
        logs: const [],
        events: events,
        notificationsAllowed: true,
        now: now ?? jetzt,
      );

  test('Ein Termin ergibt genau eine Erinnerung', () {
    final ergebnis = soll([termin()]);
    expect(ergebnis, hasLength(1));
    expect(ergebnis.single.kind, ReminderKind.event);
    expect(ergebnis.single.fireAt, DateTime(2026, 8, 7, 16, 30));
  });

  test('Ohne Erlaubnis entsteht auch fuer Termine nichts', () {
    expect(
      desiredReminders(
        medications: const [],
        logs: const [],
        events: [termin()],
        notificationsAllowed: false,
        now: jetzt,
      ),
      isEmpty,
    );
  });

  test('Auch ein alter abgeschalteter Termin wird erinnert', () {
    final ergebnis = soll([termin(erinnerung: false)]);

    expect(ergebnis, hasLength(1));
    expect(ergebnis.single.fireAt, DateTime(2026, 8, 7, 16, 30));
  });

  test('Ein alter Termin ohne Vorlauf nutzt dreissig Minuten', () {
    final ergebnis = soll([termin(vorlauf: null)]);

    expect(ergebnis, hasLength(1));
    expect(ergebnis.single.fireAt, DateTime(2026, 8, 7, 16, 30));
  });

  test('Ein vergangener Termin erzeugt nichts', () {
    expect(soll([termin(start: DateTime(2026, 8, 7, 14))]), isEmpty);
  });

  test('Vorwarnzeit vorbei, Termin aber noch nicht', () {
    // 15:50 angelegt fuer 16:00 mit einer Stunde Vorlauf: die Meldung
    // waere um 15:00 faellig gewesen. Der alte Dienst sagte dazu
    // „Event reminder time has passed".
    expect(
      soll([
        termin(start: DateTime(2026, 8, 7, 16), vorlauf: 60),
      ], now: DateTime(2026, 8, 7, 15, 50)),
      isEmpty,
    );
  });

  test('Ein Tag Vorlauf wird richtig gerechnet', () {
    final ergebnis = soll([
      termin(start: DateTime(2026, 8, 9, 10), vorlauf: 1440),
    ]);
    expect(ergebnis.single.fireAt, DateTime(2026, 8, 8, 10));
  });

  test('Termine kennen keinen Sieben-Tage-Deckel', () {
    final ergebnis = soll([termin(start: DateTime(2026, 8, 28, 10))]);
    expect(
      ergebnis,
      hasLength(1),
      reason: 'ein Termin in drei Wochen kostet genau eine Vormerkung',
    );
    expect(ergebnis.single.fireAt, DateTime(2026, 8, 28, 9, 30));
  });

  test('Verschieben ergibt eine andere Kennung', () {
    final frueh = soll([termin(start: DateTime(2026, 8, 7, 17))]).single;
    final spaet = soll([termin(start: DateTime(2026, 8, 7, 19))]).single;
    expect(frueh.target, isNot(spaet.target));
  });

  test('Termine und Medikamente stoeren einander nicht', () {
    final ergebnis = desiredReminders(
      medications: [
        Medication(
          id: 'm1',
          name: 'Testmed',
          dosage: '1 Tablette',
          timesOfDay: const ['18:00'],
          profileIds: const ['lina'],
          createdAt: DateTime(2026, 8),
        ),
      ],
      logs: const [],
      events: [termin()],
      notificationsAllowed: true,
      now: jetzt,
    );
    expect(ergebnis.where((r) => r.kind == ReminderKind.event), hasLength(1));
    expect(ergebnis.where((r) => r.target is DoseTarget), isNotEmpty);
  });

  test('Beim Budget kommen Termine vor den Vorwarnungen', () {
    final viele = [
      for (var i = 0; i < 30; i++)
        termin(
          id: 'e$i',
          start: DateTime(2026, 8, 7, 17).add(Duration(days: i)),
        ),
    ];
    final ergebnis = desiredReminders(
      medications: [
        for (var m = 0; m < 6; m++)
          Medication(
            id: 'm$m',
            name: 'Med $m',
            dosage: '1 Tablette',
            timesOfDay: const ['08:00', '12:00', '18:00', '22:00'],
            profileIds: const ['lina'],
            createdAt: DateTime(2026, 8),
          ),
      ],
      logs: const [],
      events: viele,
      notificationsAllowed: true,
      now: DateTime(2026, 8, 7, 0, 30),
      budget: 40,
    );
    expect(ergebnis, hasLength(40));
    expect(
      ergebnis.where((r) => r.kind == ReminderKind.before30),
      isEmpty,
      reason: 'Vorwarnungen fallen zuerst weg',
    );
  });
}
