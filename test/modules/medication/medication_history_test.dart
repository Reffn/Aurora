import 'package:dis_app/models/medication.dart';
import 'package:dis_app/modules/medication/medication_history.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rückmeldungen vom 02. und 04.10.2026: „Es gibt nur die Anzeige Heute,
/// aber keinen Verlauf, um zum Beispiel zu sehen, ob gestern Abend
/// eingenommen wurde." Die Einträge lagen alle in der Box — es fehlte nur,
/// sie zu zeigen.
void main() {
  final jetzt = DateTime(2026, 10, 6, 12);
  final gesternAbend = DateTime(2026, 10, 5, 20, 4);

  Medication med({
    String id = 'm1',
    List<String> zeiten = const ['08:00', '20:00'],
    bool aktiv = true,
    MedicationType typ = MedicationType.daily,
    DateTime? angelegt,
  }) => Medication(
    id: id,
    name: id,
    dosage: '1',
    timesOfDay: zeiten,
    profileIds: const ['lina'],
    createdAt: angelegt ?? DateTime(2026, 9),
    type: typ,
    isActive: aktiv,
  );

  MedicationLog eintrag(
    DateTime um,
    MedicationStatus status, {
    String slot = '20:00',
    String medId = 'm1',
    String wer = 'lina',
  }) => MedicationLog(
    id: '$medId-$um-$status',
    medicationId: medId,
    takenAt: um,
    profileId: wer,
    status: status,
    confirmedAt: um,
    scheduledTime: slot,
  );

  test('gestern Abend: wer und wann stehen da, die Lücke am Morgen auch', () {
    final verlauf = verlaufBerechnen(
      medikamente: [med()],
      eintraege: [eintrag(gesternAbend, MedicationStatus.taken)],
      jetzt: jetzt,
      tage: 2,
    );

    final gestern = verlauf.firstWhere((t) => t.tag == DateTime(2026, 10, 5));
    expect(gestern.eintraege.map((e) => e.slot), ['08:00', '20:00']);
    expect(gestern.eintraege.first.log, isNull);
    expect(gestern.eintraege.last.log?.profileId, 'lina');
    expect(gestern.eintraege.last.log?.status, MedicationStatus.taken);
  });

  test('heute erscheint kein Zeitpunkt, der noch nicht dran war', () {
    final verlauf = verlaufBerechnen(
      medikamente: [med()],
      eintraege: const [],
      jetzt: jetzt,
      tage: 1,
    );

    expect(verlauf.single.eintraege.map((e) => e.slot), ['08:00']);
  });

  test('korrigiert: der zuletzt gesetzte Stand zählt', () {
    final verlauf = verlaufBerechnen(
      medikamente: [
        med(zeiten: const ['20:00']),
      ],
      eintraege: [
        eintrag(gesternAbend, MedicationStatus.snoozed),
        eintrag(
          gesternAbend.add(const Duration(minutes: 30)),
          MedicationStatus.taken,
          wer: 'mina',
        ),
      ],
      jetzt: jetzt,
      tage: 2,
    );

    final zeile = verlauf.last.eintraege.single;
    expect(zeile.log?.status, MedicationStatus.taken);
    expect(zeile.log?.profileId, 'mina');
  });

  test('vor dem Anlegen wird keine Lücke erfunden', () {
    final verlauf = verlaufBerechnen(
      medikamente: [med(angelegt: DateTime(2026, 10, 6, 9))],
      eintraege: const [],
      jetzt: jetzt,
      tage: 3,
    );

    expect(verlauf.map((t) => t.tag), [DateTime(2026, 10, 6)]);
  });

  test('pausiert: nur was eingetragen ist, keine Lücken', () {
    final verlauf = verlaufBerechnen(
      medikamente: [med(aktiv: false)],
      eintraege: [eintrag(gesternAbend, MedicationStatus.taken)],
      jetzt: jetzt,
      tage: 3,
    );

    expect(verlauf, hasLength(1));
    expect(verlauf.single.eintraege.single.slot, '20:00');
  });

  test('Bedarfsmedizin: jede Einnahme mit Uhrzeit', () {
    final verlauf = verlaufBerechnen(
      medikamente: [
        med(id: 'b', zeiten: const [], typ: MedicationType.asNeeded),
      ],
      eintraege: [
        eintrag(
          DateTime(2026, 10, 5, 9, 15),
          MedicationStatus.taken,
          medId: 'b',
          slot: '',
        ),
        eintrag(
          DateTime(2026, 10, 5, 15, 40),
          MedicationStatus.taken,
          medId: 'b',
          slot: '',
        ),
      ],
      jetzt: jetzt,
      tage: 2,
    );

    expect(
      verlauf.single.eintraege.map((e) => e.sortierschluessel),
      ['09:15', '15:40'],
    );
  });
}
