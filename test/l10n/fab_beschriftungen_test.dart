import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Jede Fläche beschriftet ihren Anlege-Knopf selbst.
///
/// Der Knopf im Finder trug den Text des Tagebuchs (`main.dart`, Zeile 1092:
/// `label: (l) => l.fabDiaryEntry`). Auf Deutsch stand dort „Eintrag", auf
/// Italienisch „Voce" — ein Wort, das dort auch „Stimme" heißt und in einer
/// App mit Sprachnachrichten genau falsch klingt. Aufgefallen ist es am
/// 14.08.2026 im Emulator; der Knopf legt in Wahrheit einen Ort oder einen
/// Gegenstand an.
///
/// Geteilte Schlüssel zwischen zwei Flächen sind die Ursache, nicht die
/// Übersetzung: Wer den Tagebuchtext ändert, ändert unbemerkt auch den
/// Finder.
void main() {
  const sprachen = ['de', 'en', 'es', 'fr', 'it'];

  Map<String, dynamic> lies(String sprache) {
    final datei = File('lib/l10n/app_$sprache.arb');
    if (!datei.existsSync()) {
      throw StateError('lib/l10n/app_$sprache.arb fehlt');
    }
    return jsonDecode(datei.readAsStringSync()) as Map<String, dynamic>;
  }

  test('der Finder hat einen eigenen Knopftext, in jeder Sprache', () {
    for (final sprache in sprachen) {
      final texte = lies(sprache);

      expect(
        texte['fabFinderEntry'],
        isNotNull,
        reason: 'in $sprache fehlt der eigene Text für den Finder-Knopf',
      );
      expect(
        (texte['fabFinderEntry'] as String).trim(),
        isNotEmpty,
        reason: 'ein leerer Knopf sagt nichts ($sprache)',
      );
      expect(
        texte['fabFinderEntry'],
        isNot(equals(texte['fabDiaryEntry'])),
        reason: 'Finder und Tagebuch legen Verschiedenes an ($sprache)',
      );
    }
  });

  test('der Finder greift nicht mehr auf den Tagebuchtext zu', () {
    final quelle = File('lib/main.dart').readAsStringSync();

    expect(
      quelle,
      contains('l.fabFinderEntry'),
      reason: 'sonst steht am Finder weiter der Text des Tagebuchs',
    );
    expect(
      'l.fabDiaryEntry'.allMatches(quelle).length,
      1,
      reason: 'der Tagebuchtext gehört an genau eine Fläche',
    );
  });
}
