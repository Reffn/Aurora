import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/telemetry_transport.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final event = TelemetryEvent(
    name: TelemetryEventName.bereichGeoeffnetChat,
    at: DateTime(2026, 8, 5, 14, 37),
    appVersion: '3.2.0',
  );

  group('FirestoreTelemetryTransport', () {
    test('schreibt genau drei Felder, ohne Server-Zeitstempel', () async {
      Map<String, dynamic>? geschrieben;
      final transport = FirestoreTelemetryTransport(
        writer: (data) async => geschrieben = data,
        configChecker: () => true,
      );

      await transport.send(event);

      expect(geschrieben!.keys.toSet(), {'event', 'day', 'appVersion'});
    });

    test('meldet Erfolg', () async {
      final transport = FirestoreTelemetryTransport(
        writer: (_) async {},
        configChecker: () => true,
      );

      final result = await transport.send(event);

      expect(result.outcome, TransportOutcome.sent);
    });

    test('Zeitueberschreitung gilt als pending, nicht als Fehler', () async {
      final transport = FirestoreTelemetryTransport(
        writer: (_) async => throw TimeoutException('zu langsam'),
        configChecker: () => true,
      );

      final result = await transport.send(event);

      expect(result.outcome, TransportOutcome.pending);
    });

    test('abgelehnter Schreibvorgang gilt als failed', () async {
      final transport = FirestoreTelemetryTransport(
        writer: (_) async =>
            throw FirebaseException(plugin: 'test', code: 'permission-denied'),
        configChecker: () => true,
      );

      final result = await transport.send(event);

      expect(result.outcome, TransportOutcome.failed);
      expect(result.reason, isNotNull);
    });

    test('isConfigured ist eine Laufzeitpruefung und wirft nie', () {
      final transport = FirestoreTelemetryTransport(
        writer: (_) async {},
        configChecker: () => throw StateError('Firebase fehlt'),
      );

      expect(transport.isConfigured, isFalse);
    });
  });
}
