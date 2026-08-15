import 'dart:convert';
import 'dart:io';

import 'package:dis_app/models/feedback_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedbackPayload', () {
    test('enthält ohne Diagnose-Schalter nur Text und Kategorie', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: 'Die Karte lädt nicht.',
      );

      final map = payload.toMap();

      expect(map['category'], 'Fehler');
      expect(map['message'], 'Die Karte lädt nicht.');
      expect(map.containsKey('diagnostics'), isFalse);
      expect(map.containsKey('replyEmail'), isFalse);
    });

    test('erlaubt kein Standortfeld im Schema', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: 'Test',
        diagnostics: 'Android 14',
      );

      final keys = payload.toMap().keys.map((k) => k.toLowerCase());

      for (final forbidden in ['location', 'latitude', 'longitude', 'lat', 'lon', 'position', 'gps', 'coordinates']) {
        expect(keys.contains(forbidden), isFalse,
            reason: 'Standortfeld "$forbidden" darf nie Teil eines Payloads sein (Spec 4, Kanal 3)');
      }
    });

    // Die Firestore-Regeln führen eine Feld-Whitelist. Kommt hier ein Feld
    // hinzu, das dort fehlt, lehnt der Server jeden Schreibvorgang ab — und
    // die Nutzerin sieht nur "Senden fehlgeschlagen", ohne dass jemand die
    // Ursache erfährt. Ein stiller Kanal also, wieder.
    test('sendet nur Felder, die firestore.rules erlaubt', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: 'Eine ausreichend lange Testnachricht.',
        replyEmail: 'jemand@example.org',
        diagnostics: 'Android 14',
      );

      // createdAt setzt FirestoreTransport selbst, es steht nicht im Payload.
      const allowedByRules = {
        'category',
        'message',
        'replyEmail',
        'diagnostics',
      };

      expect(
        payload.toMap().keys.toSet().difference(allowedByRules),
        isEmpty,
        reason: 'Neues Payload-Feld ohne Eintrag in firestore.rules. Beide '
            'Stellen müssen zusammen gepflegt werden, sonst antwortet der '
            'Server mit permission-denied.',
      );
    });

    test('toPlainText gibt den Inhalt wörtlich wieder', () {
      final payload = FeedbackPayload(
        category: 'Wunsch',
        message: 'Mehr Tier-Avatare 🦎',
        replyEmail: 'jemand@example.org',
      );

      final text = payload.toPlainText();

      expect(text, contains('Wunsch'));
      expect(text, contains('Mehr Tier-Avatare 🦎'));
      expect(text, contains('jemand@example.org'));
    });

    test('leere Mail-Adresse wird nicht mitgesendet', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: 'Test',
        replyEmail: '',
      );

      expect(payload.toMap().containsKey('replyEmail'), isFalse);
    });
  });

  group('Längenbegrenzung', () {
    test('kürzt eine zu lange Nachricht auf die Grenze der Serverregel', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: 'a' * (FeedbackPayload.maxMessageLength + 500),
      );

      expect(
        utf8.encode(payload.message).length,
        lessThanOrEqualTo(FeedbackPayload.maxMessageLength),
      );
      expect(payload.message, endsWith('[gekürzt]'),
          reason: 'Gekürzt wird sichtbar, nicht heimlich — der Text steht so '
              'auch im Übertragungsprotokoll.');
    });

    test('kürzt eine zu lange Diagnose', () {
      final payload = FeedbackPayload(
        category: 'Crash Report',
        message: 'Automatisch erzeugter Bericht.',
        diagnostics: 'x' * (FeedbackPayload.maxDiagnosticsLength + 1),
      );

      expect(
        utf8.encode(payload.diagnostics!).length,
        lessThanOrEqualTo(FeedbackPayload.maxDiagnosticsLength),
      );
    });

    test('lässt Text unterhalb der Grenze unangetastet', () {
      final payload = FeedbackPayload(
        category: 'Wunsch',
        message: 'Kurz und vollständig.',
      );

      expect(payload.message, 'Kurz und vollständig.');
    });

    // substring() an einer beliebigen Stelle zerlegt ein Emoji in zwei halbe
    // Codeeinheiten. Das Ergebnis ist kein gültiges UTF-8 mehr und der Server
    // weist es ab — an genau der Stelle, an der niemand mehr hinsieht.
    test('schneidet niemals mitten durch ein Emoji', () {
      final payload = FeedbackPayload(
        category: 'Fehler',
        message: '🦎' * FeedbackPayload.maxMessageLength,
      );

      expect(
        () => utf8.decode(utf8.encode(payload.message)),
        returnsNormally,
      );
      expect(payload.message.runes.length, greaterThan(1));
    });

    // Die Zahlen stehen an zwei Stellen: hier und in firestore.rules. Läuft
    // eine davon weg, weist der Server ab, was der Client für zulässig hält.
    test('Grenzwerte stimmen mit firestore.rules überein', () {
      final rules = File('firestore.rules').readAsStringSync();

      int limitFor(String field) {
        final match = RegExp(r'data\.' + field + r'\.size\(\) <= (\d+)')
            .firstMatch(rules);
        expect(match, isNotNull,
            reason: 'Keine Obergrenze für "$field" in firestore.rules gefunden');
        return int.parse(match!.group(1)!);
      }

      expect(limitFor('category'), FeedbackPayload.maxCategoryLength);
      expect(limitFor('message'), FeedbackPayload.maxMessageLength);
      expect(limitFor('replyEmail'), FeedbackPayload.maxReplyEmailLength);
      expect(limitFor('diagnostics'), FeedbackPayload.maxDiagnosticsLength);

      final minMatch =
          RegExp(r'data\.message\.size\(\) >= (\d+)').firstMatch(rules);
      expect(minMatch, isNotNull);
      expect(int.parse(minMatch!.group(1)!), FeedbackPayload.minMessageLength);
    });
  });
}
