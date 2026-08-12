import 'package:dis_app/models/telemetry_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final vorhanden = TelemetryEventName.values.map((e) => e.wireName).toSet();

  test('jeder Anker-Bereich hat ein Ereignis', () {
    // Die Schluessel stammen aus TabDefinition.telemetryKey in main.dart.
    // Aendert sich dort einer, faellt es hier auf, statt still zu verschwinden.
    const bereiche = [
      'halt',
      'notfall',
      'hilfe',
      'chat',
      'kalender',
      'medikamente',
      'tagebuch',
      'kontakte',
      'finder',
      'spiele',
      'zeitachse',
      'feedback',
    ];

    for (final bereich in bereiche) {
      expect(
        vorhanden.contains('bereich_geoeffnet_$bereich'),
        isTrue,
        reason: 'Kein Ereignis fuer Bereich $bereich',
      );
    }
  });

  test('jede Uebung hat ein Abschluss- und ein Abbruchereignis', () {
    // Ids aus lib/modules/grounding/data/grounding_exercises.dart
    const uebungen = ['orientation', 'senses', 'body', 'container', 'breath'];

    for (final uebung in uebungen) {
      expect(vorhanden.contains('uebung_beendet_$uebung'), isTrue);
      expect(vorhanden.contains('uebung_abgebrochen_$uebung'), isTrue);
    }
  });

  test('jeder Onboarding-Schritt hat ein Abbruchereignis', () {
    // Die fuenf Seiten aus pre_onboarding_screen.dart
    const schritte = [
      'willkommen',
      'privacy',
      'features',
      'profile',
      'los_gehts',
    ];

    for (final schritt in schritte) {
      expect(vorhanden.contains('onboarding_abgebrochen_$schritt'), isTrue);
    }
  });
}
