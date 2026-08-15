import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der FloatingActionButton liegt global im Scaffold und weiß nichts von den
/// Tab-Inhalten darunter. Ohne Abstand verdeckt er den letzten Listeneintrag —
/// in der Medikamentenliste war dadurch die Antwort „Später" nicht antippbar.
///
/// Diese Tests halten fest, dass der Abstand groß genug bleibt und die
/// Systemleiste mitzählt.
void main() {
  /// Rendert einen Kontext mit den angegebenen MediaQuery-Werten.
  Future<double> paddingFor(
    WidgetTester tester, {
    double systemBar = 0,
    double keyboard = 0,
  }) async {
    late double result;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          viewPadding: EdgeInsets.only(bottom: systemBar),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: Builder(
          builder: (context) {
            result = context.safeBottomPaddingForFab;
            return const SizedBox();
          },
        ),
      ),
    );
    return result;
  }

  group('Abstand für den FloatingActionButton', () {
    testWidgets('lässt auch ohne Systemleiste Platz für den ganzen Knopf',
        (tester) async {
      final padding = await paddingFor(tester);

      // 56 dp Standardgröße des FAB plus 16 dp Abstand zum Scaffold-Rand.
      expect(padding, greaterThanOrEqualTo(72));
    });

    testWidgets('rechnet die Systemleiste dazu', (tester) async {
      final ohne = await paddingFor(tester);
      final mit = await paddingFor(tester, systemBar: 48);

      expect(mit, ohne + 48);
    });

    testWidgets('weicht bei offener Tastatur auf deren Höhe aus',
        (tester) async {
      final padding = await paddingFor(tester, systemBar: 48, keyboard: 320);

      // viewInsets enthält die Systemleiste bereits — sonst würde doppelt
      // gerechnet und die Liste bekäme einen unnötigen Leerraum.
      expect(padding, 320 + 88);
    });
  });
}
