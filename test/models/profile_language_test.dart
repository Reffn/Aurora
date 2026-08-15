import 'package:dis_app/l10n/supported_languages.dart';
import 'package:dis_app/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// In einem System sprechen nicht alle dieselbe Sprache. Die Sprache hängt
/// deshalb am Anteil — und muss sich auch wieder abwählen lassen.
void main() {
  Profile anteil({String? sprache}) => Profile(
        id: 'p1',
        nameRaw: 'Ana',
        preferredColorValue: 0xFFAA66CC,
        createdAt: DateTime(2026),
        preferredLanguage: sprache,
      );

  group('Sprache am Anteil', () {
    test('ohne eigene Sprache folgt der Anteil der App', () {
      expect(anteil().preferredLanguage, isNull);
    });

    test('copyWith setzt eine Sprache', () {
      final mitSpanisch = anteil().copyWith(preferredLanguage: 'es');
      expect(mitSpanisch.preferredLanguage, 'es');
    });

    test('copyWith ohne Angabe lässt die Sprache stehen', () {
      final unveraendert = anteil(sprache: 'es').copyWith(age: 30);
      expect(unveraendert.preferredLanguage, 'es');
    });

    test('clearPreferredLanguage wählt sie wieder ab', () {
      // Ohne diesen Schalter bliebe eine einmal gesetzte Sprache für immer:
      // copyWith kann `null` nicht von „nicht angegeben" unterscheiden.
      final zurueck =
          anteil(sprache: 'es').copyWith(clearPreferredLanguage: true);
      expect(zurueck.preferredLanguage, isNull);
    });
  });

  group('Sprachliste', () {
    test('kennt jede Sprache, die die App anbietet', () {
      expect(
        supportedLanguages.map((l) => l.code),
        containsAll(['de', 'en', 'es', 'fr', 'it']),
      );
    });

    test('nennt jede Sprache in sich selbst', () {
      expect(languageNameFor('es'), 'Español');
      expect(languageNameFor('fr'), 'Français');
    });

    test('ein unbekannter Code hat keinen Namen', () {
      expect(languageNameFor('xx'), isNull);
      expect(languageNameFor(null), isNull);
    });
  });
}
