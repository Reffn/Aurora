import 'package:dis_app/widgets/icon_container.dart';
import 'package:dis_app/widgets/state_symbol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('StateSymbol', () {
    testWidgets('nutzt IconContainer als Grundform', (tester) async {
      await tester.pumpWidget(
        _wrap(const StateSymbol(
          icon: Icons.star,
          color: Colors.teal,
          active: true,
        )),
      );

      expect(find.byType(IconContainer), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('zeigt kein Abzeichen, wenn keines gesetzt ist', (tester) async {
      await tester.pumpWidget(
        _wrap(const StateSymbol(
          icon: Icons.star,
          color: Colors.teal,
          active: true,
        )),
      );

      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('zeigt das Abzeichen, wenn eines gesetzt ist', (tester) async {
      await tester.pumpWidget(
        _wrap(const StateSymbol(
          icon: Icons.star,
          color: Colors.teal,
          active: true,
          badge: Icons.lock,
        )),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('kodiert den Zustand doppelt: Fuellung und Farbe', (tester) async {
      await tester.pumpWidget(
        _wrap(const StateSymbol(
          icon: Icons.star,
          color: Colors.teal,
          active: false,
        )),
      );

      final container = tester.widget<IconContainer>(find.byType(IconContainer));
      // Inaktiv: transparenter Hintergrund UND gedaempfte Icon-Farbe.
      expect(container.backgroundColor, Colors.transparent);
      expect(container.iconColor, isNot(Colors.teal));
    });
  });
}
