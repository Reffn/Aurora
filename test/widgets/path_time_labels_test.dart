import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

/// Der Weg aus dem Test: von zuhause zum Edeka und zurück, Coswig.
/// Zwischen zwei Punkten liegen rund fünfundsiebzig Meter.
const _home = [51.1288, 13.5842];
const _edeka = [51.1315, 13.5801];

final _now = DateTime(2026, 8, 6, 12);

LocationHistoryEntry _at(List<double> place, {required int minutesAgo}) {
  return LocationHistoryEntry(
    id: 'p$minutesAgo',
    profileId: 'anteil-1',
    latitude: place[0],
    longitude: place[1],
    timestamp: _now.subtract(Duration(minutes: minutesAgo)),
    accuracy: 8,
  );
}

/// Der Gang zum Einkaufen: vierzehn Punkte, zehn Minuten auseinander,
/// hin und auf demselben Weg zurück. Neueste zuerst, so wie die Karte ihn
/// bekommt.
List<LocationHistoryEntry> _shoppingTrip() {
  const route = <List<double>>[
    _home,
    [51.1293, 13.5835],
    [51.1297, 13.5828],
    [51.1302, 13.5821],
    [51.1306, 13.5814],
    [51.1311, 13.5807],
    _edeka,
    _edeka,
    [51.1311, 13.5807],
    [51.1306, 13.5814],
    [51.1302, 13.5821],
    [51.1297, 13.5828],
    [51.1293, 13.5835],
    _home,
  ];
  return [
    for (var i = route.length - 1; i >= 0; i--)
      _at(route[i], minutesAgo: (route.length - 1 - i) * 10),
  ];
}

void main() {
  const distance = Distance();

  group('pathTimeLabelPoints', () {
    test('ohne Punkte keine Zeiten', () {
      expect(pathTimeLabelPoints(const []), isEmpty);
    });

    test('der jüngste Punkt bekommt eine Zeit', () {
      final points = pathTimeLabelPoints([_at(_home, minutesAgo: 10)]);
      expect(points, hasLength(1));
      expect(points.first.id, 'p10');
    });

    test('was dicht beieinander liegt, wird nur einmal beschriftet', () {
      final points = pathTimeLabelPoints([
        _at(_home, minutesAgo: 10),
        _at(const [51.1290, 13.5844], minutesAgo: 20), // rund 30 Meter
      ]);
      expect(points, hasLength(1));
      expect(points.first.id, 'p10', reason: 'die jüngere Zeit gewinnt');
    });

    test('was weit genug auseinander liegt, bekommt beide Zeiten', () {
      final points = pathTimeLabelPoints([
        _at(_home, minutesAgo: 10),
        _at(_edeka, minutesAgo: 60),
      ]);
      expect(points.map((e) => e.id), ['p10', 'p60']);
    });

    test('um die aktuelle Position bleibt es frei', () {
      final points = pathTimeLabelPoints(
        [_at(_home, minutesAgo: 10)],
        keepClear: LatLng(_home[0], _home[1]),
      );
      expect(
        points,
        isEmpty,
        reason: 'dort steht schon der Standort-Marker',
      );
    });

    test('Hin- und Rückweg beschriften denselben Ort nicht doppelt', () {
      final points = pathTimeLabelPoints(
        _shoppingTrip(),
        keepClear: LatLng(_home[0], _home[1]),
      );

      // Keine zwei Zeiten näher als der Mindestabstand — sonst lägen die
      // Beschriftungen des Rückwegs auf denen des Hinwegs.
      for (var i = 0; i < points.length; i++) {
        for (var j = i + 1; j < points.length; j++) {
          final apart = distance(
            LatLng(points[i].latitude, points[i].longitude),
            LatLng(points[j].latitude, points[j].longitude),
          );
          expect(
            apart,
            greaterThanOrEqualTo(120),
            reason: '${points[i].id} und ${points[j].id} liegen übereinander',
          );
        }
      }
    });

    test('der Weg behält mehr als eine Zeit, aber nicht jede', () {
      final trip = _shoppingTrip();
      final points = pathTimeLabelPoints(
        trip,
        keepClear: LatLng(_home[0], _home[1]),
      );
      expect(points.length, greaterThan(1));
      expect(points.length, lessThan(trip.length ~/ 2));
    });

    test('der Wendepunkt am Edeka behält seine Zeit', () {
      final points = pathTimeLabelPoints(
        _shoppingTrip(),
        keepClear: LatLng(_home[0], _home[1]),
      );
      expect(
        points.any(
          (e) => e.latitude == _edeka[0] && e.longitude == _edeka[1],
        ),
        isTrue,
        reason: 'wo man umgekehrt ist, ist die Zeit am meisten wert',
      );
    });

    test('eine niedrigere Obergrenze lässt weniger Zeiten übrig', () {
      final trip = _shoppingTrip();
      final viele = pathTimeLabelPoints(trip, keepClear: LatLng(_home[0], _home[1]));
      final wenige = pathTimeLabelPoints(
        trip,
        keepClear: LatLng(_home[0], _home[1]),
        maxLabels: 2,
      );
      expect(
        wenige.length,
        lessThanOrEqualTo(viele.length),
        reason: 'die kleine Karte trägt weniger als die große',
      );
    });

    test('die Zeiten stehen in der Reihenfolge jung nach alt', () {
      final points = pathTimeLabelPoints(_shoppingTrip());
      for (var i = 0; i < points.length - 1; i++) {
        expect(
          points[i].timestamp.isAfter(points[i + 1].timestamp),
          isTrue,
        );
      }
    });
  });
}
