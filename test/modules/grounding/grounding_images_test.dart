import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/data/grounding_images.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GroundingImages', () {
    test('gibt null zurueck fuer einen unbekannten Schluessel', () {
      expect(GroundingImages.resolve('gibt_es_nicht'), isNull);
    });

    test('knownKeys und resolve stimmen ueberein', () {
      for (final key in GroundingImages.knownKeys) {
        expect(
          GroundingImages.resolve(key),
          isNotNull,
          reason: 'Schluessel $key steht in knownKeys, loest aber nicht auf',
        );
      }
    });

    test('hasAssets meldet, ob ueberhaupt ein Bildersatz hinterlegt ist', () {
      expect(GroundingImages.hasAssets, GroundingImages.knownKeys.isNotEmpty);
    });

    // Bis 3.0.24 war `_paths` leer, und alle 28 Schritte zeigten dasselbe
    // Übungssymbol — das Bild sollte tragen und trug nichts. Bis gezeichnete
    // Bilder kommen, hat jeder Schritt ein eigenes, vertrautes Symbol.
    test('jeder Bildschlüssel aller Übungen hat ein Bild oder Symbol', () {
      for (final exercise in GroundingExercises.all) {
        for (final step in exercise.steps) {
          expect(
            GroundingImages.bildFuer(step.imageKey),
            isNotNull,
            reason: 'Kein Bild für ${step.imageKey} in ${exercise.id}',
          );
        }
      }
    });

    test('innerhalb einer Übung sind die Symbole verschieden', () {
      for (final exercise in GroundingExercises.all) {
        final symbole = <IconData>[
          for (final step in exercise.steps)
            if (GroundingImages.bildFuer(step.imageKey)
                case GroundingBildSymbol(:final icon))
              icon,
        ];
        expect(
          symbole.toSet(),
          hasLength(exercise.steps.length),
          reason: 'Doppeltes Symbol in ${exercise.id}: $symbole',
        );
      }
    });

    test('ein Asset geht dem Symbol vor', () {
      // Solange keins hinterlegt ist, ist jedes Bild ein Symbol. Kommt ein
      // Pfad dazu, gewinnt er — ohne dass Übung oder Widget sich ändern.
      for (final key in GroundingImages.knownKeys) {
        expect(GroundingImages.bildFuer(key), isA<GroundingBildAsset>());
      }
    });
  });
}
