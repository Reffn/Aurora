import 'dart:io';

import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Was Aurora verspricht, muss sie zeigen können.
///
/// Fehlt die Benachrichtigungserlaubnis, plant der Abgleich nichts — und
/// das blieb früher unsichtbar: der Schalter stand auf an, die Karte trug
/// ein Weckersymbol, und im Log stand eine einzige Zeile. Das Erlaubnisband
/// nennt seither die Zahl der Einnahmezeiten, die ein Versprechen tragen.
///
/// [NotificationService.countPromisedIntakeTimes] liefert genau diese Zahl.
/// Sie fragt bewusst nicht die Warteschlange — die gibt es nicht mehr, seit
/// der Abgleich das Betriebssystem selbst fragt.
void main() {
  late Directory tempDir;
  late NotificationService service;

  Medication medikament({
    required String id,
    List<String> zeiten = const ['08:00'],
    bool remindersEnabled = true,
    bool isActive = true,
    MedicationType typ = MedicationType.daily,
  }) =>
      Medication(
        id: id,
        name: 'Testmittel',
        dosage: '1 Tablette',
        timesOfDay: zeiten,
        profileIds: const ['p1'],
        createdAt: DateTime(2026),
        isActive: isActive,
        remindersEnabled: remindersEnabled,
        type: typ,
      );

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('aurora_promises');
    Hive.init(tempDir.path);
    // Einzeln und mit echtem Typ: eine Schleife über TypeAdapter<dynamic>
    // registriert alle für `dynamic`, und der erste Adapter beantwortet dann
    // jede Anfrage. Die Typnummern stehen an den Modellen; hier wird nur
    // abgefangen, dass ein Adapter aus einem früheren Testlauf schon liegt.
    void registriere(void Function() f) {
      try {
        f();
      } on HiveError {
        // schon registriert
      }
    }

    registriere(() => Hive.registerAdapter(MedicationAdapter()));
    registriere(() => Hive.registerAdapter(MedicationLogAdapter()));
    registriere(() => Hive.registerAdapter(MedicationStatusAdapter()));
    registriere(() => Hive.registerAdapter(MedicationTypeAdapter()));
    registriere(() => Hive.registerAdapter(CalendarEventAdapter()));

    service = NotificationService(EventBus());
    await service.openBoxes();
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<void> lege(List<Medication> meds) async {
    final box = Hive.box<Medication>(HiveBoxNames.medications);
    for (final m in meds) {
      await box.put(m.id, m);
    }
  }

  test('Ohne Medikamente ist nichts versprochen', () {
    expect(service.countPromisedIntakeTimes(), 0);
  });

  test('Jede Einnahmezeit zaehlt einzeln', () async {
    await lege([
      medikament(id: 'm1', zeiten: const ['08:00', '20:00']),
    ]);
    expect(service.countPromisedIntakeTimes(), 2);
  });

  test('Zwei Medikamente werden zusammengezaehlt', () async {
    await lege([
      medikament(id: 'm1'),
      medikament(id: 'm2', zeiten: const ['12:00', '18:00']),
    ]);
    expect(service.countPromisedIntakeTimes(), 3);
  });

  test('Abgeschaltete Erinnerungen versprechen nichts', () async {
    await lege([medikament(id: 'm1', remindersEnabled: false)]);
    expect(service.countPromisedIntakeTimes(), 0);
  });

  test('Inaktive Medikamente versprechen nichts', () async {
    await lege([medikament(id: 'm1', isActive: false)]);
    expect(service.countPromisedIntakeTimes(), 0);
  });

  test('Bedarfsmedizin hat keine Einnahmezeiten', () async {
    await lege([
      medikament(id: 'prn', zeiten: const [], typ: MedicationType.asNeeded),
    ]);
    expect(service.countPromisedIntakeTimes(), 0);
  });
}
