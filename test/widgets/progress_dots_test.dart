import 'package:dis_app/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ProgressDots', () {
    testWidgets('zeichnet einen Punkt je Einheit', (tester) async {
      await tester.pumpWidget(
        _wrap(const ProgressDots(active: 2, total: 5, color: Colors.blue)),
      );

      expect(find.byType(ProgressDotsDot), findsNWidgets(5));
    });

    testWidgets('markiert genau die aktiven Punkte als gefüllt', (tester) async {
      await tester.pumpWidget(
        _wrap(const ProgressDots(active: 2, total: 5, color: Colors.blue)),
      );

      final dots = tester
          .widgetList<ProgressDotsDot>(find.byType(ProgressDotsDot))
          .toList();

      expect(dots.map((d) => d.filled).toList(), [true, true, false, false, false]);
    });

    testWidgets('zeichnet nichts, wenn total ueber maxDots liegt', (tester) async {
      await tester.pumpWidget(
        _wrap(const ProgressDots(active: 1, total: 13, color: Colors.blue)),
      );

      expect(find.byType(ProgressDotsDot), findsNothing);
    });
  });
}
