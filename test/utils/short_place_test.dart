import 'package:dis_app/utils/short_place.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gerettet aus `test/widgets/recent_presence_band_test.dart`, als das
/// Anwesenheitsband am 7. August 2026 von der Zeitkarte abgelöst wurde.
/// Die Funktion lebt weiter — vier Flächen zeigen mit ihr Adressen an.
void main() {
  group('shortPlace', () {
    test('kürzt auf den erkennbaren Teil', () {
      expect(
        shortPlace('Kirchstraße 3, 01640 Coswig, Deutschland'),
        'Kirchstraße 3',
      );
    });

    test('nimmt die Straße dazu, wenn die Hausnummer vorn steht', () {
      expect(
        shortPlace('37, Rue du Chemin Vert, Paris, France'),
        'Rue du Chemin Vert 37',
        reason:
            'Nominatim stellt die Hausnummer als eigene Komponente '
            'voran. Allein gezeigt ergibt sie „37" — eine Zahl ohne Ort.',
      );
    });

    test('erkennt auch Hausnummern mit Buchstaben', () {
      expect(
        shortPlace('244a, Auerstraße, Coswig, Meißen, Sachsen, Deutschland'),
        'Auerstraße 244a',
        reason:
            'Auf der Kontaktkarte stand nur „244a" — die Hausnummer galt '
            'wegen des Buchstabens nicht als Nummer und blieb allein stehen.',
      );
      expect(
        shortPlace('90D, Moritzburger Straße, Weinböhla'),
        'Moritzburger Straße 90D',
      );
      expect(
        shortPlace('12-14, Hauptstraße, Coswig'),
        'Hauptstraße 12-14',
      );
    });

    test('einteilige Adresse bleibt stehen', () {
      expect(shortPlace('Coswig'), 'Coswig');
    });

    test('ohne Adresse kommt nichts', () {
      expect(shortPlace(null), isNull);
      expect(shortPlace(' , , '), isNull);
    });
  });
}
