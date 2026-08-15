/// Diese Prüfung arbeitet auf dem Quelltext statt auf der Laufzeitausgabe,
/// weil der Generator Hive-Boxen und GetIt benötigt. Sie verhindert
/// zuverlässig, dass die entfernten Felder unbemerkt zurückkehren.
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnhancedDebugReportGenerator', () {
    late String source;

    setUpAll(() {
      source = File('lib/utils/enhanced_debug_report_generator.dart')
          .readAsStringSync();
    });

    test('gibt keine Profil-ID aus', () {
      expect(source.contains('Profile ID:'), isFalse,
          reason: 'Die Profil-ID ist ein stabiler Identifikator und '
              'verkettet mehrere Meldungen derselben Person (Spec 5.1)');

      // Prüfe auch auf versteckte IDs in _anonymizeProfileName
      expect(source.contains('profile.id.substring'), isFalse,
          reason: 'Auch partial IDs in anonymisierten Namen müssen entfernt sein');
      expect(source.contains('(ID:'), isFalse,
          reason: 'ID-Klammerzusätze sind stabile Identifikatoren');
    });

    test('gibt keine Bestandszahlen aus', () {
      for (final forbidden in [
        'Total Profiles:',
        '• Messages:',
        '• Profiles:',
      ]) {
        expect(source.contains(forbidden), isFalse,
            reason: 'Bestandszahlen sind bei ~40 Nutzern quasi eindeutig (Spec 5.1)');
      }
    });

    test('enthält kein Standortfeld', () {
      for (final forbidden in ['latitude', 'longitude', 'Position(', 'getCurrentPosition']) {
        expect(source.contains(forbidden), isFalse,
            reason: 'Standort verlässt das Gerät nie Richtung Entwickler (Spec 4, Kanal 3)');
      }
    });
  });
}
