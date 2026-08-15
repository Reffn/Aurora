import 'dart:convert';
import 'dart:io';

import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/data/grounding_images.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readArb(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('GroundingExercises', () {
    test('enthaelt genau fuenf Uebungen', () {
      expect(GroundingExercises.all.length, 5);
    });

    test('jede Uebung hat mindestens einen Schritt', () {
      for (final exercise in GroundingExercises.all) {
        expect(
          exercise.steps,
          isNotEmpty,
          reason: 'Uebung ${exercise.id} hat keine Schritte',
        );
      }
    });

    test('Uebungs-Ids sind eindeutig', () {
      final ids = GroundingExercises.all.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('der Anker ist die Orientierungsuebung', () {
      expect(GroundingExercises.anchor.id, 'orientation');
    });

    test('genau der erste Schritt des Ankers zeigt Datum und Uhrzeit', () {
      final steps = GroundingExercises.anchor.steps;
      expect(steps.first.showsCurrentDateTime, isTrue);
      expect(
        steps.skip(1).every((s) => !s.showsCurrentDateTime),
        isTrue,
        reason: 'Nur der erste Schritt darf dynamisch sein',
      );
    });

    test('jeder Textschluessel existiert in app_de.arb und app_en.arb', () {
      final de = _readArb('lib/l10n/app_de.arb');
      final en = _readArb('lib/l10n/app_en.arb');

      for (final exercise in GroundingExercises.all) {
        expect(de.containsKey(exercise.titleKey), isTrue,
            reason: 'app_de.arb fehlt ${exercise.titleKey}');
        expect(en.containsKey(exercise.titleKey), isTrue,
            reason: 'app_en.arb fehlt ${exercise.titleKey}');

        for (final step in exercise.steps) {
          expect(de.containsKey(step.textKey), isTrue,
              reason: 'app_de.arb fehlt ${step.textKey}');
          expect(en.containsKey(step.textKey), isTrue,
              reason: 'app_en.arb fehlt ${step.textKey}');
        }
      }
    });

    test('jeder Bildschluessel loest auf, sobald ein Bildersatz vorliegt', () {
      if (!GroundingImages.hasAssets) {
        // Bis Task 7 gibt es keinen Bildersatz. Das Modul laeuft dann mit dem
        // Uebungssymbol als Ersatz — dieser Test wird scharf, sobald Bilder da
        // sind, und faengt ab dann jede Luecke.
        return;
      }

      for (final exercise in GroundingExercises.all) {
        for (final step in exercise.steps) {
          expect(
            GroundingImages.resolve(step.imageKey),
            isNotNull,
            reason: 'Kein Bild fuer ${step.imageKey} '
                'in Uebung ${exercise.id}',
          );
        }
      }
    });
  });
}
