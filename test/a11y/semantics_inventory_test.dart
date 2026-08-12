import 'package:dis_app/modules/anchor/anchor_menu_screen.dart';
import 'package:dis_app/modules/profile/profile_selection_screen.dart';
import 'package:dis_app/modules/emergency/emergency_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../modules/anchor/anchor_pinned_test.dart' show ankerFuerTest;
import '../modules/profile/profile_selection_test_setup.dart';
import '../modules/emergency/emergency_test_setup.dart';
import '../support/text_scale_harness.dart';

void main() {
  group('Semantik-Inventar', () {
    testWidgets('Anker: Kein klickbarer Knoten ohne Beschriftung', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScaled(tester, ankerFuerTest(), scale: 1);

      // Prove semantics tree exists: verify the critical labels are there
      expect(labelOfTapTarget(tester, 'Halt'), 'Halt');
      expect(labelOfTapTarget(tester, 'Notfall'), 'Notfall');
      expect(labelOfTapTarget(tester, 'Hilfe'), 'Hilfe');

      // Verify no unlabeled tap targets
      expectNoUnlabeledTapTargets(tester);
      handle.dispose();
    });

  });
}
