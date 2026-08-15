import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/telemetry_dispatcher.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/telemetry_transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/temp_hive.dart';

class _FakeTransport implements TelemetryTransport {
  _FakeTransport(this.result, {this.configured = true});

  final TransportResult result;
  final bool configured;
  final List<TelemetryEvent> gesendet = [];

  @override
  bool get isConfigured => configured;

  @override
  Future<TransportResult> send(TelemetryEvent event) async {
    gesendet.add(event);
    return result;
  }
}

void main() {
  late Box<PendingTelemetryEvent> queue;
  late List<Map<String, Object?>> protokoll;

  setUp(() async {
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(PendingTelemetryEventAdapter());
    }
    queue = await openTempBox<PendingTelemetryEvent>('telemetry_dispatch_test');
    protokoll = [];
  });

  tearDown(() async {
    await queue.deleteFromDisk();
  });

  Future<void> enqueue(String id, DateTime dueAt) async {
    await queue.put(
      id,
      PendingTelemetryEvent(
        id: id,
        eventName: 'bereich_geoeffnet_chat',
        day: '2026-08-05',
        appVersion: '3.2.0',
        dueAt: dueAt,
      ),
    );
  }

  TelemetryDispatcher buildDispatcher(
    TelemetryTransport transport, {
    DateTime? now,
  }) {
    return TelemetryDispatcher(
      queue: queue,
      transport: transport,
      now: () => now ?? DateTime(2026, 8, 5, 12),
      record: ({
        required TransmissionChannel channel,
        required String payloadText,
        required TransmissionStatus status,
        String? errorMessage,
      }) async {
        protokoll.add({
          'channel': channel,
          'payloadText': payloadText,
          'status': status,
          'errorMessage': errorMessage,
        });
      },
    );
  }

  group('TelemetryDispatcher', () {
    test('sendet nur faellige Ereignisse', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));
      await enqueue('spaeter', DateTime(2026, 8, 5, 15));
      final transport = _FakeTransport(const TransportResult.success());

      final zugestellt = await buildDispatcher(transport).flush();

      expect(zugestellt, 1);
      expect(
        transport.gesendet.single.name,
        TelemetryEventName.bereichGeoeffnetChat,
      );
      expect(queue.containsKey('spaeter'), isTrue);
    });

    test('entfernt zugestellte Ereignisse aus der Warteschlange', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));

      await buildDispatcher(_FakeTransport(const TransportResult.success()))
          .flush();

      expect(queue.containsKey('faellig'), isFalse);
    });

    test('protokolliert jeden Versand im Telemetrie-Kanal', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));

      await buildDispatcher(_FakeTransport(const TransportResult.success()))
          .flush();

      expect(protokoll.single['channel'], TransmissionChannel.telemetry);
      expect(protokoll.single['status'], TransmissionStatus.sent);
      expect(
        protokoll.single['payloadText'],
        'Ereignis: bereich_geoeffnet_chat\nTag: 2026-08-05\nApp-Version: 3.2.0',
      );
    });

    test('behaelt fehlgeschlagene Ereignisse fuer den naechsten Versuch',
        () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));

      await buildDispatcher(
        _FakeTransport(const TransportResult.failure('abgelehnt')),
      ).flush();

      expect(queue.containsKey('faellig'), isTrue);
      expect(protokoll.single['status'], TransmissionStatus.failed);
    });

    test('pending gilt als zugestellt und raeumt die Warteschlange', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));

      await buildDispatcher(_FakeTransport(const TransportResult.pending()))
          .flush();

      expect(queue.containsKey('faellig'), isFalse);
      expect(protokoll.single['status'], TransmissionStatus.pending);
    });

    test('sendet nichts, wenn kein Ziel konfiguriert ist', () async {
      await enqueue('faellig', DateTime(2026, 8, 5, 11));
      final transport = _FakeTransport(
        const TransportResult.success(),
        configured: false,
      );

      final zugestellt = await buildDispatcher(transport).flush();

      expect(zugestellt, 0);
      expect(transport.gesendet, isEmpty);
      expect(queue.containsKey('faellig'), isTrue);
      expect(protokoll, isEmpty);
    });

    test('unbekannter Ereignisname wird verworfen, nicht gesendet', () async {
      await queue.put(
        'kaputt',
        PendingTelemetryEvent(
          id: 'kaputt',
          eventName: 'ereignis_aus_einer_alten_version',
          day: '2026-08-05',
          appVersion: '3.1.0',
          dueAt: DateTime(2026, 8, 5, 11),
        ),
      );
      final transport = _FakeTransport(const TransportResult.success());

      await buildDispatcher(transport).flush();

      expect(transport.gesendet, isEmpty);
      expect(queue.containsKey('kaputt'), isFalse);
    });
  });
}
