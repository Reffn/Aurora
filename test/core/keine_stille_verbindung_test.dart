import 'dart:io';

import 'package:dis_app/constants/netz_kennung.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Schirm „Was Aurora sendet" sagt: „Hier siehst du jede Übertragung, die
/// dein Gerät verlassen hat — vollständig und wörtlich." Hier steht, was der
/// Code dafür halten muss.
///
/// Am 16.08.2026 hielt er es nicht. `main.dart` rief
/// `Firebase.initializeApp()` und `FirebaseAppCheck.activate()` bedingungslos
/// im Startpfad — bei jedem Kaltstart jeder Installation, auch bei einem
/// Menschen, der das Feedback-Formular nie öffnet und die Telemetrie
/// abgelehnt hat. Damit meldete Aurora eine dauerhafte Installations-ID bei
/// Google an und tauschte ein Play-Integrity-Token, während das
/// Übertragungsprotokoll „Es wurde noch nichts gesendet" anzeigte.
///
/// Gefunden wurde das nicht durch Lesen von `main.dart` — dort stand es
/// offen und war acht Monate lang keinem aufgefallen. Es fiel auf, als
/// jemand die Zusage gegen das Gebaute hielt.
///
/// Dieselbe Sorte wie die Cloud-Sicherung am 13.08.2026: Nicht das, was im
/// Code steht, sondern das, was die Plattform von allein tut.
///
/// Siehe docs/befund-stiller-firebase-start.md.
void main() {
  String lies(String pfad) {
    final datei = File(pfad);
    expect(
      datei.existsSync(),
      isTrue,
      reason: 'Datei nicht gefunden: $pfad — wurde sie verschoben?',
    );
    return datei.readAsStringSync();
  }

  /// Ohne Kommentare — sonst schlägt der Test an der Erklärung an, warum
  /// Firebase dort *nicht* mehr steht, und die Erklärung ist das, was den
  /// Rückfall beim nächsten Mal verhindert.
  String ohneDartKommentare(String quelle) => quelle
      .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
      .split('\n')
      .where((zeile) => !zeile.trimLeft().startsWith('//'))
      .join('\n');

  String ohneXmlKommentare(String quelle) =>
      quelle.replaceAll(RegExp('<!--.*?-->', dotAll: true), '');

  group('Firebase startet nicht im Startpfad', () {
    test('main.dart fasst Firebase nicht an', () {
      final quelle = ohneDartKommentare(lies('lib/main.dart'));

      expect(
        quelle.contains('Firebase.initializeApp'),
        isFalse,
        reason: 'Im Startpfad meldet das eine Installations-ID bei Google an '
            '— bevor jemand zugestimmt oder etwas gesendet hat. Der Start '
            'gehört in den Sendeweg (FirebaseStart), nicht hierher.',
      );
      expect(
        quelle.contains('FirebaseAppCheck'),
        isFalse,
        reason: 'App Check tauscht eine Gerätebescheinigung mit Google. '
            'Gehört an dieselbe Stelle wie der Firebase-Start: in den '
            'Sendeversuch.',
      );
      expect(
        quelle.contains("import 'package:firebase_core/firebase_core.dart'"),
        isFalse,
        reason: 'Kein Import heißt: Der nächste Rückfall braucht eine '
            'bewusste Zeile mehr.',
      );
    });

    test('der Sendeweg startet Firebase selbst', () {
      final start = lies('lib/services/transport/firebase_start.dart');

      expect(start.contains('Firebase.initializeApp'), isTrue);
      expect(start.contains('FirebaseAppCheck.instance.activate'), isTrue);

      // Beide Wege müssen den Starter tatsächlich rufen — sonst steht das
      // Modul da und niemand benutzt es, und Firestore ist still tot.
      expect(
        lies('lib/services/feedback_sender.dart').contains('starteFirebase()'),
        isTrue,
        reason: 'Ohne diesen Aufruf ist isConfigured immer false und jedes '
            'Feedback ginge still über die Mail-App.',
      );
      expect(
        lies(
          'lib/services/telemetry_dispatcher.dart',
        ).contains('_starteFirebase()'),
        isTrue,
      );
    });

    test('das Manifest schaltet die Firebase-Datensammlung ab', () {
      final manifest = ohneXmlKommentare(
        lies('android/app/src/main/AndroidManifest.xml'),
      );

      expect(
        manifest.contains('firebase_data_collection_default_enabled'),
        isTrue,
        reason: 'Ohne dieses Attribut legen die Firebase-Bibliotheken von '
            'sich aus eine Installations-ID an — AGENTS.md: „keine '
            'Installations-IDs".',
      );
      expect(
        RegExp(
          r'firebase_data_collection_default_enabled"\s*\n?\s*android:value="false"',
        ).hasMatch(manifest),
        isTrue,
        reason: 'Das Attribut muss auf false stehen, nicht bloß dastehen.',
      );
    });
  });

  group('Bildschirminhalt', () {
    test('MainActivity setzt FLAG_SECURE', () {
      final quelle = lies(
        'android/app/src/main/kotlin/com/disapp/dis_app/MainActivity.kt',
      );

      expect(
        quelle.contains('FLAG_SECURE'),
        isTrue,
        reason: 'Ohne FLAG_SECURE legt Android ein Vorschaubild des letzten '
            'Schirms im App-Wechsler ab — Anteilsnamen und offene Chats, '
            'sichtbar ohne die App zu öffnen.',
      );
      expect(
        quelle.contains('override fun onCreate'),
        isTrue,
        reason: 'Das Flag muss gesetzt sein, bevor der erste Inhalt steht.',
      );
    });
  });

  group('Kennung gegenüber fremden Servern', () {
    // Nominatim verlangt eine identifizierende Kennung. Sie darf den
    // Betreiber nennen und muss die Diagnose verschweigen: Eine Anfrage mit
    // „DIS" im User-Agent teilt einem fremden Protokoll mit, dass unter
    // dieser IP-Adresse ein Mensch mit dieser Verdachtsdiagnose sitzt — im
    // Notfallbereich zusammen mit seinen genauen Koordinaten.
    const verraeterisch = ['dis', 'aurora'];

    test('die Kennung nennt die Diagnose nicht', () {
      final kennung = NetzKennung.userAgent.toLowerCase();

      for (final wort in verraeterisch) {
        expect(
          kennung.contains(wort),
          isFalse,
          reason: '„$wort" in der Kennung macht jede Anfrage an einen '
              'fremden Server zu einer Auskunft über den Menschen davor.',
        );
      }
      expect(
        kennung.contains('@'),
        isTrue,
        reason: 'Nominatims Bedingungen verlangen einen erreichbaren '
            'Betreiber. Ohne Kontakt ist die Kennung nicht regelkonform.',
      );
    });

    test('der Kachelname nennt die Diagnose nicht', () {
      final name = NetzKennung.kachelPaketName.toLowerCase();

      for (final wort in verraeterisch) {
        expect(name.contains(wort), isFalse);
      }
      expect(
        name.contains('dis_app'),
        isFalse,
        reason: 'Die echte Paketkennung com.disapp.dis_app sagt dasselbe wie '
            'ein DIS im User-Agent.',
      );
    });

    test('kein Sendeweg baut sich eine eigene Kennung', () {
      for (final pfad in [
        'lib/services/geocoding_service.dart',
        'lib/services/emergency_message_service.dart',
        'lib/widgets/overview_map.dart',
      ]) {
        final quelle = ohneDartKommentare(lies(pfad));

        expect(
          quelle.contains('Aurora DIS App'),
          isFalse,
          reason: '$pfad: alte Kennung, siehe NetzKennung.',
        );
        expect(
          quelle.contains('com.aurora.dis_app'),
          isFalse,
          reason: '$pfad: alte Kennung, siehe NetzKennung.',
        );
      }
    });
  });
}
