import 'package:dis_app/widgets/crash_boundary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Die CrashBoundary haengt in main.dart ueber der MaterialApp. Dort gibt es
/// keine Directionality und kein Theme — die Fallback-UI muss beides selbst
/// mitbringen, sonst faellt das Sicherheitsnetz mit und der Bildschirm bleibt
/// schwarz.
class _Boom extends StatelessWidget {
  const _Boom();

  @override
  Widget build(BuildContext context) => throw StateError('boom');
}

void main() {
  testWidgets('Fallback-UI rendert ohne MaterialApp-Vorfahr', (tester) async {
    // Die Boundary setzt ErrorWidget.builder global um — ein Seiteneffekt in
    // build(). Das Test-Framework besteht darauf, dass der Originalwert am
    // Ende wieder steht, und prueft das vor den tearDowns.
    final originalBuilder = ErrorWidget.builder;

    final thrown = <Object>[];

    await tester.pumpWidget(const CrashBoundary(child: _Boom()));
    // Die Boundary schaltet erst im Folgeframe um, das Child wirft solange
    // weiter. Alles einsammeln, was dabei anfaellt.
    for (var frame = 0; frame < 3; frame++) {
      final Object? error = tester.takeException();
      if (error != null) thrown.add(error);
      await tester.pump();
    }

    expect(
      thrown.map((e) => e.toString()),
      isNot(anyElement(contains('Directionality'))),
      reason: 'Die Fallback-UI darf nicht selbst am fehlenden Rahmen scheitern',
    );
    expect(
      find.byIcon(Icons.error_outline),
      findsOneWidget,
      reason: 'Statt schwarzem Bildschirm muss die Fehlerseite stehen',
    );

    // Aushaengen: den globalen ErrorWidget.builder muss die Boundary
    // zurueckgeben, sonst faengt ihr Closure noch nach ihrem Ende.
    await tester.pumpWidget(const SizedBox.shrink());
    expect(ErrorWidget.builder, same(originalBuilder));
  });
}
