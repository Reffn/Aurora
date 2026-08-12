import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/firestore_transport.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreTransport', () {
    test('isConfigured returns false when configChecker throws', () {
      final transport = FirestoreTransport(
        configChecker: () => throw Exception('Firebase not initialized'),
      );

      expect(transport.isConfigured, isFalse);
    });

    test('isConfigured returns false when projectId is empty', () {
      final transport = FirestoreTransport(
        configChecker: () => false,
      );

      expect(transport.isConfigured, isFalse);
    });

    test('send() returns pending on TimeoutException', () async {
      final transport = FirestoreTransport(
        configChecker: () => true,
        writer: (_) async {
          throw TimeoutException('Timeout', Duration.zero);
        },
      );

      final payload = FeedbackPayload(
        category: 'Test',
        message: 'Test message that is definitely long enough',
      );

      final result = await transport.send(payload);

      expect(result.outcome, TransportOutcome.pending);
      expect(result.reason, isNull);
    });

    test('send() returns failed on FirebaseException', () async {
      final transport = FirestoreTransport(
        configChecker: () => true,
        writer: (_) async {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Permission denied',
          );
        },
      );

      final payload = FeedbackPayload(
        category: 'Test',
        message: 'Test message that is definitely long enough',
      );

      final result = await transport.send(payload);

      expect(result.outcome, TransportOutcome.failed);
      expect(result.reason, isNotNull);
      expect(result.reason, isNotEmpty);
    });

    test('send() returns failed on unexpected error', () async {
      final transport = FirestoreTransport(
        configChecker: () => true,
        writer: (_) async {
          throw ArgumentError('Not a valid value');
        },
      );

      final payload = FeedbackPayload(
        category: 'Test',
        message: 'Test message that is definitely long enough',
      );

      final result = await transport.send(payload);

      expect(result.outcome, TransportOutcome.failed);
      expect(result.reason, isNotNull);
      expect(result.reason, contains('Senden fehlgeschlagen'));
    });

    test('send() returns success on successful write', () async {
      final transport = FirestoreTransport(
        configChecker: () => true,
        writer: (_) async {
          // Write completes successfully
        },
      );

      final payload = FeedbackPayload(
        category: 'Test',
        message: 'Test message that is definitely long enough',
      );

      final result = await transport.send(payload);

      expect(result.outcome, TransportOutcome.sent);
      expect(result.reason, isNull);
    });

    test('send() sets createdAt in data passed to writer', () async {
      Map<String, dynamic>? capturedData;

      final transport = FirestoreTransport(
        configChecker: () => true,
        writer: (data) async {
          capturedData = data;
        },
      );

      final payload = FeedbackPayload(
        category: 'Test',
        message: 'Test message that is definitely long enough',
      );

      await transport.send(payload);

      expect(capturedData, isNotNull);
      expect(capturedData!.containsKey('createdAt'), isTrue);
      expect(capturedData!['createdAt'], isA<FieldValue>());
    });
  });
}
