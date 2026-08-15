import 'package:dis_app/modules/grounding/data/grounding_images.dart';
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
  });
}
