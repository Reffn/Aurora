import 'package:dis_app/services/telemetry_consent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/temp_hive.dart';

void main() {
  late Box<dynamic> settingsBox;

  setUp(() async {
    settingsBox = await openTempBox<dynamic>('settings_consent_test');
  });

  tearDown(() async {
    await settingsBox.deleteFromDisk();
  });

  group('TelemetryConsent', () {
    test('startet auf ungefragt', () {
      final consent = TelemetryConsent.fromBox(settingsBox);

      expect(consent.state, TelemetryConsentState.ungefragt);
      expect(consent.allowsRecording, isFalse);
    });

    test('grant erlaubt das Aufzeichnen', () async {
      final consent = TelemetryConsent.fromBox(settingsBox);

      await consent.grant();

      expect(consent.state, TelemetryConsentState.zugestimmt);
      expect(consent.allowsRecording, isTrue);
    });

    test('deny gilt als beantwortet, erlaubt aber nichts', () async {
      final consent = TelemetryConsent.fromBox(settingsBox);

      await consent.deny();

      expect(consent.state, TelemetryConsentState.abgelehnt);
      expect(consent.allowsRecording, isFalse);
      expect(consent.needsAsking, isFalse);
    });

    test('ungefragt bedeutet: noch fragen', () {
      final consent = TelemetryConsent.fromBox(settingsBox);

      expect(consent.needsAsking, isTrue);
    });

    test('revoke schaltet von zugestimmt auf abgelehnt', () async {
      final consent = TelemetryConsent.fromBox(settingsBox);
      await consent.grant();

      await consent.revoke();

      expect(consent.state, TelemetryConsentState.abgelehnt);
      expect(consent.allowsRecording, isFalse);
    });

    test('ueberdauert einen Neustart', () async {
      await TelemetryConsent.fromBox(settingsBox).grant();

      final wiederGelesen = TelemetryConsent.fromBox(settingsBox);

      expect(wiederGelesen.state, TelemetryConsentState.zugestimmt);
    });

    test('unbekannter gespeicherter Wert faellt auf ungefragt zurueck',
        () async {
      await settingsBox.put('telemetry_consent', 'kaputt');

      final consent = TelemetryConsent.fromBox(settingsBox);

      expect(consent.state, TelemetryConsentState.ungefragt);
    });
  });
}
