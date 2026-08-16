import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/feedback_sender.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubTransport implements FeedbackTransport {
  _StubTransport(this.result, {this.isConfigured = true});

  final TransportResult result;

  @override
  final bool isConfigured;

  @override
  String get displayName => 'Stub';

  int calls = 0;

  @override
  Future<TransportResult> send(FeedbackPayload payload) async {
    calls++;
    return result;
  }
}

class _RecordedEntry {
  const _RecordedEntry(this.payloadText, this.status, this.errorMessage);

  final String payloadText;
  final TransmissionStatus status;
  final String? errorMessage;
}

void main() {
  final entries = <_RecordedEntry>[];

  Future<void> recorder({
    required TransmissionChannel channel,
    required String payloadText,
    required TransmissionStatus status,
    String? errorMessage,
  }) async {
    expect(channel, TransmissionChannel.feedback);
    entries.add(_RecordedEntry(payloadText, status, errorMessage));
  }

  setUp(entries.clear);

  final payload = FeedbackPayload(
    category: 'Fehler',
    message: 'Eine ausreichend lange Testnachricht für den Versand.',
  );

  group('FeedbackSender', () {
    test('nimmt den bestätigten Weg und protokolliert ihn', () async {
      final primary = _StubTransport(const TransportResult.success());
      final fallback = _StubTransport(const TransportResult.success());

      final result = await FeedbackSender(
        primary: primary,
        fallback: fallback,
        record: recorder,
        starteFirebase: () async => true,
      ).send(payload);

      expect(result.outcome, TransportOutcome.sent);
      expect(primary.calls, 1);
      expect(fallback.calls, 0, reason: 'Kein zweiter Versand nach Erfolg');
      expect(entries.length, 1);
      expect(entries.single.status, TransmissionStatus.sent);
    });

    // pending heißt angenommen. Ein Ausweichen auf den zweiten Weg würde
    // dieselbe Meldung ein zweites Mal verschicken.
    test('weicht bei pending nicht aus', () async {
      final primary = _StubTransport(const TransportResult.pending());
      final fallback = _StubTransport(const TransportResult.success());

      final result = await FeedbackSender(
        primary: primary,
        fallback: fallback,
        record: recorder,
        starteFirebase: () async => true,
      ).send(payload);

      expect(result.outcome, TransportOutcome.pending);
      expect(fallback.calls, 0);
      expect(entries.single.status, TransmissionStatus.pending);
    });

    test('weicht bei endgültigem Fehlschlag aus und protokolliert beides',
        () async {
      final primary = _StubTransport(const TransportResult.failure('kaputt'));
      final fallback = _StubTransport(const TransportResult.success());

      final result = await FeedbackSender(
        primary: primary,
        fallback: fallback,
        record: recorder,
        starteFirebase: () async => true,
      ).send(payload);

      expect(result.outcome, TransportOutcome.sent);
      expect(primary.calls, 1);
      expect(fallback.calls, 1);
      expect(entries.length, 2,
          reason: 'Auch der gescheiterte Versuch gehört ins Protokoll');
      expect(entries.first.status, TransmissionStatus.failed);
      expect(entries.first.errorMessage, 'kaputt');
      expect(entries.last.status, TransmissionStatus.sent);
    });

    test('überspringt einen unkonfigurierten ersten Weg', () async {
      final primary = _StubTransport(
        const TransportResult.success(),
        isConfigured: false,
      );
      final fallback = _StubTransport(const TransportResult.success());

      await FeedbackSender(
        primary: primary,
        fallback: fallback,
        record: recorder,
        starteFirebase: () async => true,
      ).send(payload);

      expect(primary.calls, 0);
      expect(fallback.calls, 1);
      expect(entries.length, 1);
    });

    test('scheitert sichtbar, wenn beide Wege scheitern', () async {
      final primary = _StubTransport(const TransportResult.failure('kein Netz'));
      final fallback =
          _StubTransport(const TransportResult.failure('keine Mail-App'));

      final result = await FeedbackSender(
        primary: primary,
        fallback: fallback,
        record: recorder,
        starteFirebase: () async => true,
      ).send(payload);

      expect(result.outcome, TransportOutcome.failed);
      expect(result.reason, 'keine Mail-App');
      expect(entries.length, 2);
      expect(entries.every((e) => e.status == TransmissionStatus.failed), isTrue);
    });

    // Das Protokoll ist der Beleg der Nutzerin. Steht dort etwas anderes als
    // das Gesendete, ist es wertlos.
    test('protokolliert den Inhalt wörtlich', () async {
      final primary = _StubTransport(const TransportResult.success());

      await FeedbackSender(
        primary: primary,
        fallback: _StubTransport(const TransportResult.success()),
        record: recorder,
        starteFirebase: () async => true,
      ).send(payload);

      expect(entries.single.payloadText, payload.toPlainText());
    });
  });
}
