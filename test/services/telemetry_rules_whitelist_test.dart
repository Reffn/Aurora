import 'dart:io';

import 'package:dis_app/models/telemetry_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Whitelist in firestore.rules deckt sich mit TelemetryEventName', () {
    final rules = File('firestore.rules').readAsStringSync();

    final block = RegExp(
      r'let ERLAUBTE_EREIGNISSE = \[(.*?)\];',
      dotAll: true,
    ).firstMatch(rules);

    expect(
      block,
      isNotNull,
      reason: 'ERLAUBTE_EREIGNISSE fehlt in firestore.rules',
    );

    final inRules = RegExp("'([a-z0-9_]+)'")
        .allMatches(block!.group(1)!)
        .map((m) => m.group(1)!)
        .toSet();

    final inDart = TelemetryEventName.values.map((e) => e.wireName).toSet();

    expect(
      inRules,
      inDart,
      reason: 'Client und Regeln kennen unterschiedliche Ereignisse. '
          'Was nur im Client steht, wird vom Server abgewiesen.',
    );
  });
}
