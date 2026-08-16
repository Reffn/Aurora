import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/services/feedback_sender.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/firestore_transport.dart';
import 'package:dis_app/services/transport/mailto_transport.dart';
import 'package:flutter_test/flutter_test.dart';

/// Beide echten Transporte am echten Sender.
///
/// Vorher baute diese Datei den Ablauf in jedem Test selbst nach ("Simulate
/// the send flow logic") und prüfte damit ihre eigene Kopie statt den
/// ausgelieferten Code — ein Fehler im Formular wäre hier grün geblieben.
void main() {
  final payload = FeedbackPayload(
    category: 'Test',
    message: 'Test message that is definitely long enough for validation',
  );

  final recorded = <TransmissionStatus>[];

  Future<void> recorder({
    required TransmissionChannel channel,
    required String payloadText,
    required TransmissionStatus status,
    String? errorMessage,
  }) async {
    recorded.add(status);
  }

  setUp(recorded.clear);

  FeedbackSender senderWith({
    required FirestoreTransport firestore,
    required MailtoTransport mailto,
  }) {
    return FeedbackSender(
      primary: firestore,
      fallback: mailto,
      record: recorder,
      // Geprüft wird der Ablauf danach, nicht der Firebase-Start selbst.
      // `true` heißt: Firebase läuft — die Wegwahl trifft wie bisher
      // `isConfigured`.
      starteFirebase: () async => true,
    );
  }

  MailtoTransport failingMailto(void Function() onCall) {
    return MailtoTransport(
      launcher: (_) async {
        onCall();
        throw Exception('Mailto should not be called');
      },
    );
  }

  group('Feedback Send Flow (echte Transporte)', () {
    test('Firestore-Erfolg: kein Ausweichen auf Mailto', () async {
      var mailtoAttempted = false;

      final result = await senderWith(
        firestore: FirestoreTransport(
          configChecker: () => true,
          writer: (_) async {},
        ),
        mailto: failingMailto(() => mailtoAttempted = true),
      ).send(payload);

      expect(result.outcome, TransportOutcome.sent);
      expect(mailtoAttempted, isFalse);
      expect(recorded, [TransmissionStatus.sent]);
    });

    // Zeitüberschreitung heißt bei Firestore nicht "verloren": Der Schreib-
    // vorgang liegt in der lokalen Warteschlange und geht raus, sobald wieder
    // Netz da ist. Ein Ausweichen auf Mailto würde dieselbe Meldung doppelt
    // verschicken.
    test('Firestore-Zeitüberschreitung: wartet, weicht nicht aus', () async {
      var mailtoAttempted = false;

      final result = await senderWith(
        firestore: FirestoreTransport(
          configChecker: () => true,
          writer: (_) async {
            throw TimeoutException('Timeout', Duration.zero);
          },
        ),
        mailto: failingMailto(() => mailtoAttempted = true),
      ).send(payload);

      expect(result.outcome, TransportOutcome.pending);
      expect(mailtoAttempted, isFalse);
      expect(recorded, [TransmissionStatus.pending]);
    });

    test('Firestore-Fehler: weicht auf Mailto aus', () async {
      var mailtoAttempted = false;

      final result = await senderWith(
        firestore: FirestoreTransport(
          configChecker: () => true,
          writer: (_) async {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
              message: 'Service unavailable',
            );
          },
        ),
        mailto: MailtoTransport(
          launcher: (_) async {
            mailtoAttempted = true;
            return true;
          },
        ),
      ).send(payload);

      expect(mailtoAttempted, isTrue);
      expect(result.outcome, TransportOutcome.sent);
      expect(recorded, [TransmissionStatus.failed, TransmissionStatus.sent]);
    });

    test('Firestore nicht konfiguriert: direkt Mailto', () async {
      var mailtoAttempted = false;

      final result = await senderWith(
        firestore: FirestoreTransport(configChecker: () => false),
        mailto: MailtoTransport(
          launcher: (_) async {
            mailtoAttempted = true;
            return true;
          },
        ),
      ).send(payload);

      expect(mailtoAttempted, isTrue);
      expect(result.outcome, TransportOutcome.sent);
      expect(recorded, [TransmissionStatus.sent]);
    });

    test('beide Wege scheitern: Ergebnis ist sichtbar gescheitert', () async {
      final result = await senderWith(
        firestore: FirestoreTransport(
          configChecker: () => true,
          writer: (_) async {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
              message: 'Service unavailable',
            );
          },
        ),
        mailto: MailtoTransport(launcher: (_) async => false),
      ).send(payload);

      expect(result.outcome, TransportOutcome.failed);
      expect(result.reason, isNotNull);
      expect(recorded, [TransmissionStatus.failed, TransmissionStatus.failed]);
    });
  });
}
