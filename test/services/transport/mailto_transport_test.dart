import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/services/transport/mailto_transport.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MailtoTransport', () {
    test('ist immer konfiguriert', () {
      expect(MailtoTransport().isConfigured, isTrue);
    });

    test('baut eine mailto-URI mit dem vollen Text', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: 'Die Karte lÃ¤dt nicht.',
      );
      final transport = MailtoTransport();
      final uri = transport.buildUri(payload);

      expect(uri.scheme, 'mailto');
      expect(uri.queryParameters['body'], payload.toPlainText());
    });

    test('meldet Erfolg, wenn der Mail-Client geÃ¶ffnet wurde', () async {
      final transport = MailtoTransport(launcher: (_) async => true);
      final result = await transport.send(
        FeedbackPayload(category: 'Fehler', message: 'Test'),
      );

      expect(result.outcome, TransportOutcome.sent);
    });

    test('kodiert Umlaute, mehrzeilig und Emoji korrekt', () {
      final payload = FeedbackPayload(
        category: 'PrÃ¼fung',
        message: 'Erste Zeile mit Ãœ und Ã–.\nZweite Zeile mit Emoji: ðŸŽ­',
        replyEmail: 'test@example.com',
      );
      final transport = MailtoTransport();
      final uri = transport.buildUri(payload);

      expect(uri.queryParameters['body'], payload.toPlainText());
    });

    test('meldet Fehler mit Grund, wenn kein Mail-Client vorhanden ist', () async {
      final transport = MailtoTransport(launcher: (_) async => false);
      final result = await transport.send(
        FeedbackPayload(category: 'Fehler', message: 'Test'),
      );

      expect(result.outcome, TransportOutcome.failed);
      expect(result.reason, isNotNull);
      expect(result.reason, isNotEmpty);
    });
  });
}
