import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:dis_app/services/reminders/reminder_reconciler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_reminder_scheduler.dart';

/// Der Abgleich ist idempotent und rührt nur an, was ihm gehört.
void main() {
  late FakeReminderScheduler scheduler;
  final jetzt = DateTime(2026, 8, 7, 12);

  final medikament = Medication(
    id: 'm1',
    name: 'Testmed',
    dosage: '1 Tablette',
    timesOfDay: const ['12:50'],
    profileIds: const ['lina'],
    createdAt: DateTime(2026, 8),
  );

  ReminderReconciler baue({
    List<Medication> meds = const [],
    List<MedicationLog> logs = const [],
    List<CalendarEvent> events = const [],
    bool erlaubt = true,
    bool Function()? diskret,
  }) =>
      ReminderReconciler(
        scheduler: scheduler,
        readMedications: () => meds,
        readLogs: () => logs,
        readEvents: () => events,
        readPermission: () async => erlaubt,
        readDiscreet: diskret ?? () => false,
        clock: () => jetzt,
      );

  setUp(() => scheduler = FakeReminderScheduler());

  test('Der erste Lauf meldet die Sollmenge an', () async {
    final ergebnis = await baue(meds: [medikament]).reconcile();
    expect(ergebnis.added, greaterThan(0));
    expect(ergebnis.removed, 0);
    expect(scheduler.scheduled, isNotEmpty);
  });

  test('Der zweite Lauf aendert nichts', () async {
    final abgleich = baue(meds: [medikament]);
    await abgleich.reconcile();
    final zweiter = await abgleich.reconcile();
    expect(zweiter.added, 0);
    expect(zweiter.removed, 0);
    expect(zweiter.kept, greaterThan(0));
  });

  test('Karteileichen werden abgemeldet', () async {
    scheduler.seed(namespacedId(kNamespaceMedication, 'alt|irgendwas'));
    final ergebnis = await baue(meds: [medikament]).reconcile();
    expect(ergebnis.removed, 1);
  });

  group('Meldung an die Telemetrie', () {
    test('ein Lauf mit neuen Erinnerungen meldet genau einmal', () async {
      // Einmal je Lauf, nicht je Erinnerung: Gemeldet wird, dass der Pfad
      // getragen hat — nicht, wie viele Medikamente jemand nimmt.
      var gemeldet = 0;
      final abgleich = baue(meds: [medikament])
        ..onRemindersScheduled = () => gemeldet++;

      final ergebnis = await abgleich.reconcile();

      expect(ergebnis.added, greaterThan(1), reason: 'mehrere Erinnerungen');
      expect(gemeldet, 1);
    });

    test('ein Lauf ohne Aenderung meldet nicht', () async {
      var gemeldet = 0;
      final abgleich = baue(meds: [medikament])
        ..onRemindersScheduled = () => gemeldet++;

      await abgleich.reconcile();
      await abgleich.reconcile();

      expect(gemeldet, 1, reason: 'der zweite Lauf meldet nichts an');
    });

    test('ohne Zuhoerer laeuft der Abgleich normal', () async {
      final ergebnis = await baue(meds: [medikament]).reconcile();

      expect(ergebnis.added, greaterThan(0));
    });
  });

  test('Fremde Namensraeume bleiben unangetastet', () async {
    // Namensraum 3 gehoert niemandem — der Abgleich darf ihn nicht anfassen.
    // Vorher stand hier der Termin-Namensraum; seit Stufe 3 gehoert der ihm.
    final fremdId = namespacedId(3, 'fremd-1');
    scheduler.seed(fremdId);
    await baue(meds: [medikament]).reconcile();
    expect(scheduler.cancelled, isNot(contains(fremdId)));
    expect(scheduler.scheduled.containsKey(fremdId), isTrue);
  });

  test('Termin-Karteileichen raeumt der Abgleich jetzt selbst ab', () async {
    final alterTermin = namespacedId(kNamespaceEvent, 'termin-1');
    scheduler.seed(alterTermin);
    final ergebnis = await baue(meds: [medikament]).reconcile();
    expect(scheduler.cancelled, contains(alterTermin));
    expect(ergebnis.removed, greaterThanOrEqualTo(1));
  });

  test('Ohne Erlaubnis wird alles abgemeldet', () async {
    await baue(meds: [medikament]).reconcile();
    final anzahl = scheduler.scheduled.length;
    expect(anzahl, greaterThan(0));

    final ergebnis = await baue(meds: [medikament], erlaubt: false).reconcile();
    expect(ergebnis.removed, anzahl);
    expect(await scheduler.pendingOwnIds(), isEmpty);
  });

  test('Genommen raeumt die Vorwarnungen ab — Befund 2', () async {
    await baue(meds: [medikament]).reconcile();
    final vorher = scheduler.scheduled.length;

    final ergebnis = await baue(
      meds: [medikament],
      logs: [
        MedicationLog(
          id: 'l1',
          medicationId: 'm1',
          takenAt: DateTime(2026, 8, 7, 12, 5),
          profileId: 'lina',
          status: MedicationStatus.taken,
          confirmedAt: DateTime(2026, 8, 7, 12, 5),
          scheduledTime: '12:50',
        ),
      ],
    ).reconcile();

    expect(ergebnis.removed, greaterThan(0));
    expect(scheduler.scheduled.length, lessThan(vorher));
  });

  test('Umschalten auf diskret schreibt die Texte neu', () async {
    var diskret = false;
    final abgleich = baue(meds: [medikament], diskret: () => diskret);

    await abgleich.reconcile();
    scheduler.bodies.clear();

    diskret = true;
    final ergebnis = await abgleich.reconcile();
    expect(ergebnis.added, greaterThan(0));
    expect(scheduler.bodies, isNotEmpty);
    expect(
      scheduler.bodies.every((b) => !b.contains('Testmed')),
      isTrue,
      reason: 'diskret nennt weder Name noch Dosis',
    );
  });

  test('Ohne Medikamente wird alles abgemeldet', () async {
    await baue(meds: [medikament]).reconcile();
    final ergebnis = await baue().reconcile();
    expect(await scheduler.pendingOwnIds(), isEmpty);
    expect(ergebnis.removed, greaterThan(0));
  });

  CalendarEvent termin({DateTime? start}) => CalendarEvent(
        id: 'e1',
        title: 'Arzt',
        startTime: start ?? DateTime(2026, 8, 7, 17),
        endTime: (start ?? DateTime(2026, 8, 7, 17))
            .add(const Duration(hours: 1)),
        profileIds: const ['lina'],
        notificationEnabled: true,
        reminderMinutesBefore: 30,
      );

  test('Termin und Medikament werden gemeinsam angemeldet', () async {
    await baue(meds: [medikament], events: [termin()]).reconcile();
    final ids = await scheduler.pendingOwnIds();
    expect(ids.where(isEventId), hasLength(1));
    expect(ids.where(isMedicationId), isNotEmpty);
  });

  test('Verschobener Termin: alte Kennung weg, neue da', () async {
    final abgleich = baue(events: [termin()]);
    await abgleich.reconcile();
    final alt = (await scheduler.pendingOwnIds()).single;

    final zweiter = baue(
      events: [termin(start: DateTime(2026, 8, 7, 19))],
    );
    await zweiter.reconcile();
    final neu = (await scheduler.pendingOwnIds()).single;

    expect(neu, isNot(alt));
    expect(
      scheduler.cancelled,
      contains(alt),
      reason: 'die alte Vormerkung ist eine Karteileiche und gehoert weg',
    );
  });

  test('Geloeschter Termin wird abgemeldet', () async {
    await baue(events: [termin()]).reconcile();
    expect(await scheduler.pendingOwnIds(), hasLength(1));

    final ergebnis = await baue().reconcile();
    expect(await scheduler.pendingOwnIds(), isEmpty);
    expect(ergebnis.removed, 1);
  });

  test('Der Termintext nennt den Titel', () async {
    await baue(events: [termin()]).reconcile();
    expect(scheduler.bodies.any((b) => b.contains('Arzt')), isTrue);
  });

  test('Nur die Vorlaufzeit geaendert: die Meldung rueckt mit', () async {
    // Der Zielpunkt bleibt derselbe Termin zur selben Startzeit, nur der
    // Vorlauf wechselt von 30 auf 15 Minuten. Traegt die Kennung die
    // Feuerzeit nicht, sieht der Abgleich keine Differenz und die alte
    // Meldung bleibt auf der alten Zeit stehen.
    CalendarEvent mitVorlauf(int minuten) => CalendarEvent(
          id: 'e1',
          title: 'Arzt',
          startTime: DateTime(2026, 8, 7, 17),
          endTime: DateTime(2026, 8, 7, 18),
          profileIds: const ['lina'],
          notificationEnabled: true,
          reminderMinutesBefore: minuten,
        );

    await baue(events: [mitVorlauf(30)]).reconcile();
    final alt = scheduler.scheduled.values.whereType<Reminder>().single;
    expect(alt.fireAt, DateTime(2026, 8, 7, 16, 30));

    await baue(events: [mitVorlauf(15)]).reconcile();
    final neu = scheduler.scheduled.values.whereType<Reminder>().single;
    expect(
      neu.fireAt,
      DateTime(2026, 8, 7, 16, 45),
      reason: 'die vorgemerkte Meldung muss auf die neue Zeit ruecken',
    );
  });

  test('Zweimal aufschieben rueckt die Meldung weiter', () async {
    MedicationLog aufschub(DateTime getippt) => MedicationLog(
          id: 'l-${getippt.millisecondsSinceEpoch}',
          medicationId: 'm1',
          takenAt: getippt,
          profileId: 'lina',
          status: MedicationStatus.snoozed,
          confirmedAt: getippt,
          scheduledTime: '12:50',
        );

    await baue(
      meds: [medikament],
      logs: [aufschub(DateTime(2026, 8, 7, 12, 55))],
    ).reconcile();
    final ersteZeit = scheduler.scheduled.values
        .whereType<Reminder>()
        .firstWhere((r) => r.kind == ReminderKind.snooze)
        .fireAt;

    await baue(
      meds: [medikament],
      logs: [aufschub(DateTime(2026, 8, 7, 13, 20))],
    ).reconcile();
    final zweiteZeit = scheduler.scheduled.values
        .whereType<Reminder>()
        .firstWhere((r) => r.kind == ReminderKind.snooze)
        .fireAt;

    expect(
      zweiteZeit,
      isNot(ersteZeit),
      reason: 'wer zweimal aufschiebt, meint das zweite Mal',
    );
  });
}
