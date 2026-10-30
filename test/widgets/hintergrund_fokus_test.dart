import 'dart:async';

import 'package:dis_app/widgets/hintergrund_ohne_fokus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Eine Fläche, die ihr Kind auf Zuruf neu einhängt.
///
/// So verhält sich jeder Schirm, der beim Öffnen der Tastatur in einen anderen
/// Layoutzweig wechselt — die Profilauswahl tat das mit der Zeitkarte.
class _Unten extends StatefulWidget {
  const _Unten({required this.inhalt, super.key});

  final Widget inhalt;

  @override
  State<_Unten> createState() => _UntenState();
}

class _UntenState extends State<_Unten> {
  int _generation = 0;

  void neuEinhaengen() => setState(() => _generation++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(key: ValueKey(_generation), child: widget.inhalt),
    );
  }
}

Future<void> _ueberganAbwarten(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

void main() {
  // Flutter schützt Routen im Hintergrund nicht: `autofocus` greift, sobald
  // der Fokusbereich einer Route nichts fokussiert hat — und eine Route unter
  // dem aktuellen Schirm hat nie etwas fokussiert. Wird dort etwas mit
  // `autofocus` neu eingehängt, zieht es den Fokus aus dem Schirm davor.
  //
  // So schloss sich am 29.09. und 05.10.2026 die Tastatur, sobald sie aufging.
  testWidgets(
    'was in der Route darunter neu eingehängt wird, zieht den Fokus nicht ab',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final untenKey = GlobalKey<_UntenState>();
      final feldFokus = FocusNode();
      addTearDown(feldFokus.dispose);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          // Wie in der App: jede Seitenroute läuft durch die Sperre.
          theme: ThemeData(pageTransitionsTheme: HintergrundOhneFokus.theme),
          home: _Unten(
            key: untenKey,
            inhalt: const Focus(
              autofocus: true,
              debugLabel: 'Greifer unten',
              child: SizedBox(),
            ),
          ),
        ),
      );
      await tester.pump();

      unawaited(
        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              body: Center(child: TextField(focusNode: feldFokus)),
            ),
          ),
        ),
      );
      await _ueberganAbwarten(tester);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(feldFokus.hasPrimaryFocus, isTrue);

      untenKey.currentState!.neuEinhaengen();
      await tester.pump();
      await tester.pump();

      expect(
        feldFokus.hasPrimaryFocus,
        isTrue,
        reason:
            'Fokus liegt bei '
            '${FocusManager.instance.primaryFocus?.debugLabel}',
      );
    },
  );

  // Die Gegenseite: Wer aus einem Dialog oder einem Schirm zurückkommt, findet
  // das Feld so vor, wie er es verlassen hat. Das leistet Flutter heute; eine
  // Sperre für den Hintergrund darf es nicht kosten.
  group('nach dem Zurückkommen hat das Feld den Fokus wieder', () {
    Future<FocusNode> feldUntenFokussieren(
      WidgetTester tester,
      GlobalKey<NavigatorState> navigatorKey,
    ) async {
      final feldFokus = FocusNode(debugLabel: 'Feld unten');
      addTearDown(feldFokus.dispose);
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          // Wie in der App: jede Seitenroute läuft durch die Sperre.
          theme: ThemeData(pageTransitionsTheme: HintergrundOhneFokus.theme),
          home: Scaffold(
            body: Center(child: TextField(focusNode: feldFokus)),
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(feldFokus.hasPrimaryFocus, isTrue);
      return feldFokus;
    }

    testWidgets('nach einem Schirm', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final feldFokus = await feldUntenFokussieren(tester, navigatorKey);

      unawaited(
        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const Scaffold()),
        ),
      );
      await _ueberganAbwarten(tester);
      navigatorKey.currentState!.pop();
      await _ueberganAbwarten(tester);

      expect(
        feldFokus.hasPrimaryFocus,
        isTrue,
        reason:
            'Fokus liegt bei '
            '${FocusManager.instance.primaryFocus?.debugLabel}',
      );
    });

    testWidgets('nach einem Dialog', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final feldFokus = await feldUntenFokussieren(tester, navigatorKey);

      unawaited(
        showDialog<void>(
          context: navigatorKey.currentContext!,
          builder: (_) => const AlertDialog(content: Text('Hinweis')),
        ),
      );
      await _ueberganAbwarten(tester);
      navigatorKey.currentState!.pop();
      await _ueberganAbwarten(tester);

      expect(
        feldFokus.hasPrimaryFocus,
        isTrue,
        reason:
            'Fokus liegt bei '
            '${FocusManager.instance.primaryFocus?.debugLabel}',
      );
    });
  });
}
