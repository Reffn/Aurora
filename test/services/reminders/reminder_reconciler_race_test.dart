import 'dart:async';

import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder_reconciler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_reminder_scheduler.dart';

/// Was passiert, wenn zwei Dinge gleichzeitig passieren — und wenn es
/// mittendrin schiefgeht.
///
/// Beides war vorher unsichtbar: Ein zweiter Aufruf verschwand kommentarlos,
/// und ein Teilausfall sah aus wie ein Lauf ohne Änderungen.
void main() {
  late FakeReminderScheduler scheduler;
  final jetzt = DateTime(2026, 8, 7, 12);

  Medication med(String id, String name) => Medication(
        id: id,
        name: name,
        dosage: '1 Tablette',
        timesOfDay: const ['12:50'],
        profileIds: const ['lina'],
        createdAt: DateTime(2026, 8),
      );

  ReminderReconciler baue({
    required List<Medication> Function() meds,
    bool Function()? diskret,
    String Function()? sprache,
  }) =>
      ReminderReconciler(
        scheduler: scheduler,
        readMedications: meds,
        readLogs: () => const <MedicationLog>[],
        readEvents: () => const <CalendarEvent>[],
        readPermission: () async => true,
        readDiscreet: diskret ?? () => false,
        readLocaleTag: sprache ?? () => 'de',
        clock: () => jetzt,
      );

  setUp(() => scheduler = FakeReminderScheduler());

  test('Eine Änderung während des Laufs geht nicht verloren', () async {
    var medikamente = [med('m1', 'Erstes')];
    final abgleich = baue(meds: () => medikamente);

    scheduler.gate = Completer<void>();
    final ersterLauf = abgleich.reconcile();

    // Warten, bis der Abgleich wirklich mitten in der Arbeit steht.
    await scheduler.gateReached.future;

    // Jetzt kommt eine Einnahmekorrektur herein — vorher wäre sie hier
    // mit einem Null-Ergebnis abgewiesen worden.
    medikamente = [med('m1', 'Erstes'), med('m2', 'Zweites')];
    final zweiterLauf = abgleich.reconcile();

    scheduler.gate!.complete();
    await ersterLauf;
    final ergebnis = await zweiterLauf;

    expect(ergebnis.succeeded, isTrue);
    expect(
      ergebnis.rounds,
      greaterThanOrEqualTo(2),
      reason: 'der Aufruf muss eine zweite Runde mit frischen Daten drehen',
    );
    expect(
      scheduler.scheduled.values.whereType<Object>(),
      isNotEmpty,
    );
    expect(
      scheduler.bodies.any((b) => b.contains('Zweites')),
      isTrue,
      reason: 'das zweite Medikament muss angemeldet sein',
    );
  });

  test('Ein Teilausfall meldet sich als Fehlschlag, nicht als Nulllauf',
      () async {
    final abgleich = baue(meds: () => [med('m1', 'Testmed')]);
    scheduler.failAfter = 1;

    final ergebnis = await abgleich.reconcile();

    expect(ergebnis.succeeded, isFalse);
    expect(ergebnis.failedAtId, isNotNull);
    expect(ergebnis.added, 0);
  });

  test('Nach einem Teilausfall schreibt der nächste Lauf alle Texte neu',
      () async {
    var diskret = false;
    final abgleich = baue(
      meds: () => [med('m1', 'Testmed')],
      diskret: () => diskret,
    );

    // Erster Lauf bricht nach der ersten Meldung ab. Die Fassung darf
    // dadurch nicht als angewendet gelten.
    scheduler.failAfter = 1;
    final ersterVersuch = await abgleich.reconcile();
    expect(ersterVersuch.succeeded, isFalse);

    // Jemand schaltet auf diskret und der Scheduler funktioniert wieder.
    diskret = true;
    scheduler.failAfter = null;
    scheduler.bodies.clear();

    final zweiterVersuch = await abgleich.reconcile();

    expect(zweiterVersuch.succeeded, isTrue);
    expect(scheduler.bodies, isNotEmpty);
    expect(
      scheduler.bodies.every((b) => !b.contains('Testmed')),
      isTrue,
      reason: 'kein Klartext darf stehenbleiben',
    );
  });

  test('Ein unbekannter Stand schreibt alles neu, nicht nichts', () async {
    // Ein frischer Reconciler trifft auf bereits vorgemerkte Meldungen —
    // genau die Lage nach einem Neustart. Vorher galt der Stand als
    // unverändert und die alten Texte blieben stehen.
    final ersterStart = baue(meds: () => [med('m1', 'Testmed')]);
    await ersterStart.reconcile();
    final vorgemerkt = await scheduler.pendingOwnIds();
    expect(vorgemerkt, isNotEmpty);
    scheduler.bodies.clear();

    final nachNeustart = baue(
      meds: () => [med('m1', 'Testmed')],
      diskret: () => true,
    );
    final ergebnis = await nachNeustart.reconcile();

    expect(ergebnis.added, vorgemerkt.length);
    expect(
      scheduler.bodies.every((b) => !b.contains('Testmed')),
      isTrue,
      reason: 'nach dem Neustart gilt der Diskret-Schalter auch für '
          'Meldungen, die schon vorgemerkt waren',
    );
  });

  test('Ein Sprachwechsel schreibt die Texte neu', () async {
    var sprache = 'de';
    final abgleich = baue(
      meds: () => [med('m1', 'Testmed')],
      sprache: () => sprache,
    );

    await abgleich.reconcile();
    scheduler.bodies.clear();

    sprache = 'en';
    final ergebnis = await abgleich.reconcile();

    expect(
      ergebnis.added,
      greaterThan(0),
      reason: 'die vorgemerkten Texte tragen noch die alte Sprache',
    );
  });
}
