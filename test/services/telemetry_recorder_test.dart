import 'dart:math';

import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/temp_hive.dart';

void main() {
  late Box<dynamic> settingsBox;
  late Box<PendingTelemetryEvent> queue;
  late TelemetryConsent consent;

  setUp(() async {
    settingsBox = await openTempBox<dynamic>('settings_recorder_test');
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(PendingTelemetryEventAdapter());
    }
    queue = await openTempBox<PendingTelemetryEvent>('telemetry_queue_test');
    consent = TelemetryConsent.fromBox(settingsBox);
  });

  tearDown(() async {
    await settingsBox.deleteFromDisk();
    await queue.deleteFromDisk();
  });

  TelemetryRecorder buildRecorder({DateTime? now, Random? random}) {
    return TelemetryRecorder(
      consent: consent,
      queue: queue,
      appVersion: '3.2.0',
      now: () => now ?? DateTime(2026, 8, 5, 10),
      random: random ?? Random(1),
    );
  }

  group('TelemetryRecorder ohne Einwilligung', () {
    test('legt bei ungefragt nichts an', () async {
      await buildRecorder().record(TelemetryEventName.bereichGeoeffnetChat);

      expect(queue.length, 0);
    });

    test('legt bei abgelehnt nichts an', () async {
      await consent.deny();

      await buildRecorder().record(TelemetryEventName.bereichGeoeffnetChat);

      expect(queue.length, 0);
    });
  });

  group('TelemetryRecorder mit Einwilligung', () {
    setUp(() async {
      await consent.grant();
    });

    test('legt genau einen Eintrag an', () async {
      await buildRecorder().record(TelemetryEventName.bereichGeoeffnetChat);

      expect(queue.length, 1);
      expect(queue.values.first.eventName, 'bereich_geoeffnet_chat');
    });

    test('speichert den Tag ohne Uhrzeit', () async {
      await buildRecorder(now: DateTime(2026, 8, 5, 23, 59, 59))
          .record(TelemetryEventName.bereichGeoeffnetChat);

      expect(queue.values.first.day, '2026-08-05');
    });

    test('ein Ereignis ist sofort faellig', () async {
      final now = DateTime(2026, 8, 5, 10);

      // Der Zufall darf daran nichts mehr aendern: Hier lag bis zum
      // 11. August 2026 eine Verzoegerung von bis zu sechs Stunden, und
      // gesendet wurde nur beim Start — jedes Ereignis kam damit fruehestens
      // einen Start spaeter an, von Einmal-Oeffnern nie.
      for (var seed = 0; seed < 20; seed++) {
        await queue.clear();
        await buildRecorder(now: now, random: Random(seed))
            .record(TelemetryEventName.bereichGeoeffnetChat);

        expect(queue.values.first.dueAt, now);
      }
    });

    test('nach dem Vormerken wird der Versand angestossen', () async {
      var angestossen = 0;
      final recorder = buildRecorder()..onRecorded = () => angestossen++;

      await recorder.record(TelemetryEventName.bereichGeoeffnetChat);

      expect(
        angestossen,
        1,
        reason: 'Ohne diesen Anstoss bleibt das Ereignis bis zum naechsten '
            'Start liegen — genau der Fehler, an dem vier Monate Telemetrie '
            'gescheitert sind.',
      );
    });

    test('ohne Einwilligung wird auch nichts angestossen', () async {
      await consent.deny();

      var angestossen = 0;
      final recorder = buildRecorder()..onRecorded = () => angestossen++;

      await recorder.record(TelemetryEventName.bereichGeoeffnetChat);

      expect(queue.isEmpty, isTrue);
      expect(
        angestossen,
        0,
        reason: 'Ein Versand ohne Einwilligung waere der Fehler, den die '
            'ganze Warteschlange verhindern soll.',
      );
    });

    test('zwei Ereignisse bekommen verschiedene Ids', () async {
      final recorder = buildRecorder();
      await recorder.record(TelemetryEventName.bereichGeoeffnetChat);
      await recorder.record(TelemetryEventName.bereichGeoeffnetHalt);

      final ids = queue.values.map((e) => e.id).toSet();
      expect(ids.length, 2);
    });

    test('clearQueue leert die Warteschlange', () async {
      final recorder = buildRecorder();
      await recorder.record(TelemetryEventName.bereichGeoeffnetChat);

      await recorder.clearQueue();

      expect(queue.length, 0);
    });
  });
}
