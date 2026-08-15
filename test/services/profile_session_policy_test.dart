import 'package:dis_app/services/profile_session_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileSessionPolicy', () {
    const timeout = Duration(minutes: 15);
    late ProfileSessionPolicy policy;
    late DateTime pausedAt;

    setUp(() {
      policy = ProfileSessionPolicy();
      pausedAt = DateTime(2026, 8, 9, 12);
    });

    test('keeps the current session after a short interruption', () {
      policy.paused(pausedAt);

      final needsProfileChoice = policy.resumed(
        pausedAt.add(const Duration(minutes: 14, seconds: 59)),
      );

      expect(needsProfileChoice, isFalse);
    });

    test('requires a profile choice at the timeout boundary', () {
      policy.paused(pausedAt);

      final needsProfileChoice = policy.resumed(pausedAt.add(timeout));

      expect(needsProfileChoice, isTrue);
    });

    test('does not shorten the absence after duplicate pause events', () {
      policy.paused(pausedAt);
      policy.paused(pausedAt.add(const Duration(minutes: 10)));

      final needsProfileChoice = policy.resumed(
        pausedAt.add(const Duration(minutes: 16)),
      );

      expect(needsProfileChoice, isTrue);
    });

    test('consumes the recorded absence when the app resumes', () {
      policy.paused(pausedAt);
      expect(policy.resumed(pausedAt.add(timeout)), isTrue);

      expect(
        policy.resumed(pausedAt.add(const Duration(minutes: 30))),
        isFalse,
      );
    });

    test('ignores resume without a matching pause', () {
      expect(policy.resumed(pausedAt), isFalse);
    });

    test('does not lock when the device clock moved backwards', () {
      policy.paused(pausedAt);

      expect(
        policy.resumed(pausedAt.subtract(const Duration(minutes: 1))),
        isFalse,
      );
    });
  });
}
