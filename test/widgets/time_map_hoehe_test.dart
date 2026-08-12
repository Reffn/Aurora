import 'package:dis_app/widgets/time_map.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wie hoch die Zeitkarte wird, wenn ein Block ihr Platz übrig lässt.
///
/// Die Rechnung stand einmal beim Aufrufer (`main.dart`), und dort war als
/// Untergrenze [TimeMap.compactBelowHeight] eingesetzt — eine
/// *Darstellungsschwelle* als *Mindesthöhe*. Damit konnte die kompakte Form,
/// für die es die Schwelle überhaupt gibt, vom Anker aus nie eintreten: Bei
/// 164 dp Platz blieb die Karte auf 200 stehen und schnitt die erste
/// Kachelreihe darunter an. Am 11. August 2026 am S24 gesehen.
void main() {
  test('knapper Platz wird genommen, nicht auf die Schwelle angehoben', () {
    expect(TimeMap.hoeheFuerBlock(164), 164);
    expect(
      TimeMap.hoeheFuerBlock(164),
      lessThan(TimeMap.compactBelowHeight),
      reason: 'Bei diesem Platz gehört die Karte in ihre kompakte Form.',
    );
  });

  test('unter der Mindesthöhe trägt die Karte nichts mehr', () {
    expect(TimeMap.hoeheFuerBlock(40), TimeMap.minHeight);
    expect(TimeMap.hoeheFuerBlock(0), TimeMap.minHeight);
  });

  test('viel Platz macht sie nicht größer als nötig', () {
    expect(TimeMap.hoeheFuerBlock(900), TimeMap.maxHeight);
  });
}
