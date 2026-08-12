import 'dart:io';

import 'package:dis_app/services/transport/mailto_transport.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transport-Konfiguration (Release-Gate)', () {
    test('MailtoTransport ist konfiguriert', () {
      expect(MailtoTransport().isConfigured, isTrue,
          reason: 'Ohne funktionierenden Transport darf kein Release entstehen');
    });

    test('google-services.json ist vorhanden', () {
      final file = File('android/app/google-services.json');
      expect(file.existsSync(), isTrue,
          reason: 'Ohne google-services.json initialisiert Firebase nicht — '
              'der Firestore-Transport wäre im Release still funktionslos');
    });

    test('google-services.json nennt das richtige Paket', () {
      final content = File('android/app/google-services.json').readAsStringSync();
      expect(content, contains('com.disapp.dis_app'),
          reason: 'Falsches Paket bedeutet, Firebase initialisiert zur Laufzeit nicht');
    });

    test('kein GitHub-Sendeweg mehr im Quelltext', () {
      final configSource = File('lib/utils/contact_config.dart').readAsStringSync();
      expect(configSource.contains('githubApiToken'), isFalse,
          reason: 'Ein Token als Compile-Zeit-Konstante war die Ursache des '
              'ursprünglichen Ausfalls (siehe Spec 1.1)');
      expect(File('lib/services/github_error_report_service.dart').existsSync(), isFalse);
    });

    // Das CI-Tor sucht im gebauten AAB nach genau diesen beiden Zeichenketten,
    // um zu belegen, dass die Sendewege den Compiler überlebt haben. Verschiebt
    // jemand die Texte — etwa in die Übersetzungsdateien — findet das Tor sie
    // nicht mehr und meldet einen Ausfall, den es nicht gibt. Dieser Test
    // schlägt dann vorher an, mit einer Begründung statt eines Rätsels.
    //
    // Die Marker stehen in .github/workflows/test.yml im Schritt
    // "Verify transport configuration in compiled binary".
    test('die Marker des CI-Tores stehen noch in den Transporten', () {
      final firestoreSource =
          File('lib/services/transport/firestore_transport.dart').readAsStringSync();
      expect(
        firestoreSource.contains('Feedback wartet auf Verbindung'),
        isTrue,
        reason: 'Das CI-Tor sucht diese Zeichenkette im gebauten Artefakt, um zu '
            'belegen, dass FirestoreTransport den Compiler überlebt hat. Wer sie '
            'verschiebt, muss den Marker in .github/workflows/test.yml mitziehen.',
      );

      final mailtoSource =
          File('lib/services/transport/mailto_transport.dart').readAsStringSync();
      expect(
        mailtoSource.contains('Du kannst den Text kopieren und manuell senden.'),
        isTrue,
        reason: 'Dasselbe für MailtoTransport. Der Marker ist bewusst reines '
            'ASCII: Dart legt Zeichenketten unter 256 als Latin-1 ab, ein Umlaut '
            'würde im Binary anders kodiert als im Suchmuster.',
      );
    });
  });
}
