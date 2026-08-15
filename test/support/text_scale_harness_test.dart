import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'text_scale_harness.dart';

void main() {
  testWidgets('erkennt zwei uebereinanderliegende Texte', (tester) async {
    await pumpScaled(
      tester,
      const Stack(
        children: [
          Positioned(top: 0, left: 0, child: Text('oben', key: Key('a'))),
          Positioned(top: 0, left: 0, child: Text('auch oben', key: Key('b'))),
        ],
      ),
      scale: 1,
    );

    expect(
      () => expectNoOverlap(tester, find.byKey(const Key('a')), find.byKey(const Key('b'))),
      throwsA(isA<TestFailure>()),
    );
  });

  testWidgets('erkennt einen klickbaren Knoten ohne Beschriftung', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScaled(
      tester,
      InkWell(onTap: () {}, child: const SizedBox(width: 40, height: 40)),
      scale: 1,
    );

    expect(() => expectNoUnlabeledTapTargets(tester), throwsA(isA<TestFailure>()));
    handle.dispose();
  });

  testWidgets('erkennt einen abgeschnittenen Text', (tester) async {
    await pumpScaled(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(top: 4000),
          child: Text('weit unten', key: Key('c')),
        ),
      ),
      scale: 1,
    );

    expect(
      () => expectFullyVisible(tester, find.byKey(const Key('c'))),
      throwsA(isA<TestFailure>()),
    );
  });
}
