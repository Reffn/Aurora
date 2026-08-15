import 'package:dis_app/models/telemetry_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TelemetryEvent', () {
    test('sendet genau drei Felder', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.bereichGeoeffnetChat,
        at: DateTime(2026, 8, 5, 14, 37, 12),
        appVersion: '3.2.0',
      );

      expect(event.toMap().keys.toSet(), {'event', 'day', 'appVersion'});
    });

    test('day traegt kein Uhrzeitanteil', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.bereichGeoeffnetChat,
        at: DateTime(2026, 8, 5, 14, 37, 12),
        appVersion: '3.2.0',
      );

      expect(event.toMap()['day'], '2026-08-05');
    });

    test('day fuellt Monat und Tag auf zwei Stellen auf', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.bereichGeoeffnetChat,
        at: DateTime(2026, 1, 9),
        appVersion: '3.2.0',
      );

      expect(event.toMap()['day'], '2026-01-09');
    });

    test('event traegt den stabilen Schluessel, nicht den Enum-Namen', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.onboardingAbgebrochenPrivacy,
        at: DateTime(2026, 8, 5),
        appVersion: '3.2.0',
      );

      expect(event.toMap()['event'], 'onboarding_abgebrochen_privacy');
    });

    test('kein Ereignisname enthaelt Grossbuchstaben oder Leerzeichen', () {
      for (final name in TelemetryEventName.values) {
        expect(
          RegExp(r'^[a-z0-9_]+$').hasMatch(name.wireName),
          isTrue,
          reason: 'Ereignisname ${name.wireName} verletzt das Namensschema',
        );
      }
    });

    test('Ereignisnamen sind eindeutig', () {
      final wireNames =
          TelemetryEventName.values.map((e) => e.wireName).toList();
      expect(wireNames.toSet().length, wireNames.length);
    });

    test('toPlainText zeigt genau das, was gesendet wird', () {
      final event = TelemetryEvent(
        name: TelemetryEventName.uebungBeendetBreath,
        at: DateTime(2026, 8, 5),
        appVersion: '3.2.0',
      );

      expect(
        event.toPlainText(),
        'Ereignis: uebung_beendet_breath\nTag: 2026-08-05\nApp-Version: 3.2.0',
      );
    });
  });
}
