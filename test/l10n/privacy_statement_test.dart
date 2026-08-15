import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Wacht darüber, dass die Datenschutzerklärung im Gerät stimmt.
///
/// Sie behauptete in jeder ausgelieferten Fassung, Aurora übertrage „KEINE
/// Daten an Server, Cloud-Dienste oder Dritte" und funktioniere „vollständig
/// offline". Zu dem Zeitpunkt gingen bereits Feedback und — nach Zustimmung —
/// Telemetrie an Firestore, und jede Karte lud Kacheln von OpenStreetMap.
///
/// Der Text war einmal richtig und ist es durch spätere Funktionen geworden,
/// ohne dass jemand ihn angefasst hat. Genau das fängt dieser Test ab: Wer
/// einen Übertragungsweg baut, muss an der Erklärung vorbei, und hier steht
/// eine Wache.
void main() {
  const locales = ['de', 'en', 'es', 'fr', 'it'];

  /// Klein und ohne Akzente — „Télémétrie" und „Telemetrie" sind dasselbe
  /// Wort, und der Test soll über Sprachen hinweg dieselbe Frage stellen.
  String plain(String value) => value
      .toLowerCase()
      .replaceAll(RegExp('[àáâãä]'), 'a')
      .replaceAll(RegExp('[èéêë]'), 'e')
      .replaceAll(RegExp('[ìíîï]'), 'i')
      .replaceAll(RegExp('[òóôõö]'), 'o')
      .replaceAll(RegExp('[ùúûü]'), 'u');

  Map<String, dynamic> load(String locale) {
    final file = File('lib/l10n/app_$locale.arb');
    if (!file.existsSync()) throw StateError('${file.path} fehlt');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('Datenschutzerklärung', () {
    for (final locale in locales) {
      test('$locale nennt alle Wege, auf denen Daten das Gerät verlassen', () {
        final arb = load(locale);
        final wege = plain(arb['privacyTransmissionBody'] as String);

        // OpenStreetMap ist ein Eigenname und in jeder Sprache derselbe.
        expect(
          wege,
          contains('openstreetmap'),
          reason: 'Kartenkacheln und Adresssuche verlassen das Gerät',
        );
        // „Telemetrie / telemetry / telemetría / télémétrie / telemetria"
        expect(
          wege,
          contains('telemetr'),
          reason: 'Telemetrie ist ein Übertragungsweg, auch wenn sie Opt-in ist',
        );
      });

      test('$locale nennt OpenStreetMap schon in der Übersicht', () {
        final arb = load(locale);
        expect(
          plain(arb['privacyGlanceBody'] as String),
          contains('openstreetmap'),
          reason: 'Wer nur die Übersicht liest, darf nicht falsch informiert '
              'sein — die Karte ist der Weg, den man am wenigsten vermutet',
        );
      });
    }

    // Die Vorlagensprache ist die, in der geschrieben wird; hier entstünde ein
    // Rückfall zuerst. Die Sätze stehen wörtlich so in der alten Fassung.
    test('die Vorlagensprache behauptet nirgends Offline-Betrieb', () {
      final arb = load('de');
      const verboten = [
        'vollständig offline',
        'überträgt keine',
        'keine internetverbindung',
        'keine tracking',
        'keine daten an server',
      ];

      for (final entry in arb.entries) {
        if (!entry.key.startsWith('privacy')) continue;
        if (entry.value is! String) continue;
        final text = plain(entry.value as String);
        for (final satz in verboten) {
          expect(
            text.contains(satz),
            isFalse,
            reason: '${entry.key} behauptet „$satz" — das stimmt nicht mehr, '
                'seit Feedback, Telemetrie und Kartenkacheln das Gerät '
                'verlassen',
          );
        }
      }
    });

    test('jede Sprache hat jeden Abschnitt', () {
      const abschnitte = [
        'privacyGlanceBody',
        'privacyStoredBody',
        'privacyTransmissionBody',
        'privacyPermissionsBody',
        'privacySecurityBody',
        'privacyDeletionBody',
        'privacyRightsBody',
        'privacyMinorsBody',
        'privacyChangesBody',
      ];

      for (final locale in locales) {
        final arb = load(locale);
        for (final key in abschnitte) {
          expect(
            arb[key],
            isA<String>(),
            reason: '$key fehlt in $locale — eine halbe Erklärung ist keine',
          );
          expect(
            (arb[key] as String).trim(),
            isNotEmpty,
            reason: '$key ist in $locale leer',
          );
        }
      }
    });

    // Der Standortverlauf ist das heikelste Datum der App. Er stand in der
    // alten Aufzählung des lokal Gespeicherten überhaupt nicht — wer sie las,
    // erfuhr nicht, dass Aurora Wege aufzeichnet.
    test('die Aufzählung des Gespeicherten nennt den Standortverlauf', () {
      for (final locale in locales) {
        final gespeichert = plain(load(locale)['privacyStoredBody'] as String);
        final nennt =
            gespeichert.contains('standort') ||
            gespeichert.contains('location') ||
            gespeichert.contains('ubicacion') ||
            gespeichert.contains('position') ||
            gespeichert.contains('posizione');
        expect(
          nennt,
          isTrue,
          reason: '$locale verschweigt, dass der Standortverlauf gespeichert '
              'wird',
        );
      }
    });
  });
}
