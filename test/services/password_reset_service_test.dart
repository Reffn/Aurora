// Migrations-Tests befüllen die deprecated Wissensfaktoren-Felder absichtlich.
// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/password_reset_service.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDir;
  late Box<Profile> profilesBox;
  late Box<dynamic> settingsBox;
  late ProfileService profileService;
  late PasswordResetService resetService;
  late EventBus eventBus;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Register adapters once
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }
  });

  setUp(() async {
    // Initialize temp directory and Hive
    tempDir = await Directory.systemTemp.createTemp('password_reset_test_');
    Hive.init(tempDir.path);

    // Initialize real services
    eventBus = EventBus();
    profileService = ProfileService(eventBus);

    // Call openBoxes() which will open the boxes with HiveBoxNames
    await profileService.openBoxes();

    // Get references to the boxes
    profilesBox = profileService.profilesBox;
    settingsBox = profileService.settingsBox;

    // Initialize PasswordResetService
    resetService = PasswordResetService(profileService, eventBus);

    // Run migration (ensures old reset state is cleaned)
    await resetService.performMigration();
  });

  tearDown(() async {
    await profilesBox.clear();
    await profilesBox.close();
    await settingsBox.clear();
    await settingsBox.close();
    await tempDir.delete(recursive: true);
  });

  group('PasswordResetService', () {
    // Helper: create a test profile with password
    Profile createProfileWithPassword({
      required String id,
      required String name,
      String password = 'testpass123',
      int? resetDurationHours,
    }) {
      final profile = Profile(
        id: id,
        nameRaw: name,
        preferredColorValue: 0xFF0000,
        createdAt: DateTime.now(),
        passwordHash: Profile.hashPassword(password),
        resetDurationHours: resetDurationHours,
      );
      profilesBox.put(id, profile);
      return profile;
    }

    // Helper: create a test profile without password
    Profile createProfileWithoutPassword({required String id, required String name}) {
      final profile = Profile(
        id: id,
        nameRaw: name,
        preferredColorValue: 0xFF0000,
        createdAt: DateTime.now(),
      );
      profilesBox.put(id, profile);
      return profile;
    }

    test('startReset rejects profile without password', () async {
      createProfileWithoutPassword(id: 'p1', name: 'NoPass');

      final result = await resetService.startReset('p1', 'newpass123');

      expect(result, false);
      final p1 = profilesBox.get('p1')!;
      expect(p1.hasPendingPassword, false);
      expect(p1.hasActiveReset, false);
    });

    test('startReset sets pending hash + timestamps with default 24h', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1');
      final before = DateTime.now();

      final result = await resetService.startReset('p1', 'newpass456');

      expect(result, true);
      final p1 = profilesBox.get('p1')!;
      expect(p1.hasPendingPassword, true);
      expect(p1.hasActiveReset, true);
      expect(p1.resetStartedAt!.isAfter(before) || p1.resetStartedAt! == before, true);

      // Default 24h duration
      final expectedEnd = p1.resetStartedAt!.add(const Duration(hours: 24));
      expect(p1.resetEndsAt, expectedEnd);
    });

    test('startReset respects profile resetDurationHours setting', () async {
      createProfileWithPassword(
        id: 'p1',
        name: 'Profile1',
        resetDurationHours: 72,
      );

      await resetService.startReset('p1', 'newpass456');

      final p1 = profilesBox.get('p1')!;
      final expectedEnd = p1.resetStartedAt!.add(const Duration(hours: 72));
      expect(p1.resetEndsAt, expectedEnd);
    });

    test('startReset uses 20s debug duration under kDebugMode', () async {
      if (!kDebugMode) {
        return; // Skip in release mode
      }

      // Enable debug mode via settings flag
      await settingsBox.put('debug_mode_enabled', true);

      createProfileWithPassword(id: 'p1', name: 'Profile1');
      await resetService.startReset('p1', 'newpass456');

      final p1 = profilesBox.get('p1')!;
      final expectedEnd = p1.resetStartedAt!.add(const Duration(seconds: 20));
      expect(p1.resetEndsAt, expectedEnd);
    });

    test('multiple profiles can reset independently (R7)', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1');
      createProfileWithPassword(id: 'p2', name: 'Profile2');

      await resetService.startReset('p1', 'newpass111');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await resetService.startReset('p2', 'newpass222');

      final p1 = profilesBox.get('p1')!;
      final p2 = profilesBox.get('p2')!;

      expect(p1.hasActiveReset, true);
      expect(p2.hasActiveReset, true);
      expect(p1.resetStartedAt! != p2.resetStartedAt, true);
      expect(p1.pendingPasswordHash != p2.pendingPasswordHash, true);
    });

    test('erneuter startReset während Frist ersetzt Pending + friert neues Ende ein (R6)', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1', resetDurationHours: 24);

      await resetService.startReset('p1', 'newpass111');
      final p1_first = profilesBox.get('p1')!;
      final firstPending = p1_first.pendingPasswordHash;
      final firstEnd = p1_first.resetEndsAt;

      await Future<void>.delayed(const Duration(milliseconds: 200));

      await resetService.startReset('p1', 'newpass222');
      final p1_second = profilesBox.get('p1')!;

      expect(p1_second.pendingPasswordHash != firstPending, true, reason: 'Pending should be replaced');
      expect(p1_second.resetStartedAt! != p1_first.resetStartedAt, true, reason: 'Start time should be fresh');
      // New end should be later than first end (new start + duration)
      expect(p1_second.resetEndsAt!.isAfter(firstEnd!), true);
    });

    test('startReset on expired reset activates old pending first, then starts new reset', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1');

      // Start first reset
      await resetService.startReset('p1', 'newpass111');
      var p1 = profilesBox.get('p1')!;
      final oldPending = p1.pendingPasswordHash!;

      // Manually expire the reset by setting resetEndsAt to past
      p1 = p1.copyWith(
        resetEndsAt: DateTime.now().subtract(const Duration(seconds: 10)),
      );
      profilesBox.put('p1', p1);

      // Start new reset while old one is expired
      await resetService.startReset('p1', 'newpass222');

      p1 = profilesBox.get('p1')!;

      // Old pending should now be in passwordHash
      expect(p1.passwordHash, oldPending);
      // New pending should be different
      expect(p1.pendingPasswordHash != oldPending, true);
      // Should have fresh reset timestamps
      expect(p1.hasActiveReset, true);
    });

    test('checkAndHandleLogin with correct old password cancels reset', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1', password: 'oldpass123');
      await resetService.startReset('p1', 'newpass456');

      var p1 = profilesBox.get('p1')!;
      expect(p1.hasActiveReset, true);

      final outcome = await resetService.checkAndHandleLogin(p1, 'oldpass123');

      expect(outcome, ResetLoginOutcome.cancelled);
      p1 = profilesBox.get('p1')!;
      expect(p1.hasActiveReset, false);
      expect(p1.hasPendingPassword, false);
    });

    test('checkAndHandleLogin after expiry with new password activates it', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1', password: 'oldpass123');
      await resetService.startReset('p1', 'newpass456');

      var p1 = profilesBox.get('p1')!;
      final newPendingHash = p1.pendingPasswordHash!;

      // Expire the reset
      p1 = p1.copyWith(
        resetEndsAt: DateTime.now().subtract(const Duration(seconds: 10)),
      );
      profilesBox.put('p1', p1);

      final outcome = await resetService.checkAndHandleLogin(p1, 'newpass456');

      expect(outcome, ResetLoginOutcome.activated);
      p1 = profilesBox.get('p1')!;
      expect(p1.passwordHash, newPendingHash);
      expect(p1.hasPendingPassword, false);
      expect(p1.hasActiveReset, false);
    });

    test('checkAndHandleLogin with wrong password during reset returns wrongPassword', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1', password: 'oldpass123');
      await resetService.startReset('p1', 'newpass456');

      var p1 = profilesBox.get('p1')!;
      final originalPending = p1.pendingPasswordHash;
      final originalStart = p1.resetStartedAt;

      final outcome = await resetService.checkAndHandleLogin(p1, 'wrongpass');

      expect(outcome, ResetLoginOutcome.wrongPassword);
      p1 = profilesBox.get('p1')!;
      // Reset state should be untouched
      expect(p1.pendingPasswordHash, originalPending);
      expect(p1.resetStartedAt, originalStart);
    });

    test('checkAndHandleLogin without active reset returns none', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1', password: 'oldpass123');

      var p1 = profilesBox.get('p1')!;
      final outcome = await resetService.checkAndHandleLogin(p1, 'oldpass123');

      expect(outcome, ResetLoginOutcome.none);
    });

    test('checkAndHandleLogin with correct password but no reset returns none', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1', password: 'oldpass123');

      var p1 = profilesBox.get('p1')!;
      final outcome = await resetService.checkAndHandleLogin(p1, 'oldpass123');

      expect(outcome, ResetLoginOutcome.none);
    });

    test('expiry + old password entry activates first, then fails on old password', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1', password: 'oldpass123');
      await resetService.startReset('p1', 'newpass456');

      var p1 = profilesBox.get('p1')!;

      // Expire the reset
      p1 = p1.copyWith(
        resetEndsAt: DateTime.now().subtract(const Duration(seconds: 10)),
      );
      profilesBox.put('p1', p1);
      p1 = profilesBox.get('p1')!;

      final outcome = await resetService.checkAndHandleLogin(p1, 'oldpass123');

      // Activation greift zuerst, then old password verification fails
      expect(outcome, ResetLoginOutcome.wrongPassword);
    });

    test('skipToLastTwentySeconds in debug mode shortens resetEndsAt', () async {
      if (!kDebugMode) {
        return; // Skip in release mode
      }

      createProfileWithPassword(id: 'p1', name: 'Profile1');
      await resetService.startReset('p1', 'newpass456');

      var p1 = profilesBox.get('p1')!;

      await resetService.skipToLastTwentySeconds('p1');

      p1 = profilesBox.get('p1')!;
      final diff = p1.resetEndsAt!.difference(p1.resetStartedAt!);
      expect(diff.inSeconds, 20);
    });

    test('skipToLastTwentySeconds blocked in release mode', () async {
      if (kDebugMode) {
        return; // Skip in debug mode
      }

      createProfileWithPassword(id: 'p1', name: 'Profile1');
      await resetService.startReset('p1', 'newpass456');

      final result = await resetService.skipToLastTwentySeconds('p1');
      expect(result, false);
    });

    test('clock backward shift freezes remaining time', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1');

      var fakeNow = DateTime.now();
      final guardedService = PasswordResetService(
        profileService,
        eventBus,
        nowProvider: () => fakeNow,
      );

      await guardedService.startReset('p1', 'newpass456');
      final endBefore = profilesBox.get('p1')!.resetEndsAt!;

      // Systemuhr eine Stunde zurückgestellt
      fakeNow = fakeNow.subtract(const Duration(hours: 1));
      await guardedService.checkAndHandleLogin(profilesBox.get('p1')!, 'falsch');

      final endAfter = profilesBox.get('p1')!.resetEndsAt!;
      // lastSeen wird in Millisekunden gespeichert — Sub-Millisekunden gehen verloren
      final shift = endAfter.difference(endBefore) - const Duration(hours: 1);
      expect(shift.abs(), lessThanOrEqualTo(const Duration(seconds: 2)),
          reason: 'Rückwärtssprung muss das Ende um die Differenz verschieben');

      final lastSeen = settingsBox.get('last_seen_timestamp') as int;
      expect(lastSeen, greaterThanOrEqualTo(fakeNow.millisecondsSinceEpoch));
    });

    test('migration: old reset state is handled', () async {
      // Simulate old global-state reset
      await settingsBox.put('password_reset_timer', DateTime.now().millisecondsSinceEpoch);
      await settingsBox.put('password_reset_profile_id', 'p1');

      createProfileWithPassword(id: 'p1', name: 'Profile1');

      // Run migration
      await resetService.performMigration();

      // Old keys should be deleted
      expect(settingsBox.get('password_reset_timer'), null);
      expect(settingsBox.get('password_reset_profile_id'), null);

      // Migration notice flag should be set
      expect(settingsBox.get('reset_migration_notice'), true);
    });

    test('migration: orphaned pending passwords are nulled', () async {
      // Create profile with orphaned pending password but no active reset
      var p1 = Profile(
        id: 'p1',
        nameRaw: 'Orphaned',
        preferredColorValue: 0xFF0000,
        createdAt: DateTime.now(),
        passwordHash: Profile.hashPassword('oldpass'),
        pendingPasswordHash: Profile.hashPassword('newpass'), // Orphaned!
      );
      profilesBox.put('p1', p1);

      await resetService.performMigration();

      p1 = profilesBox.get('p1')!;
      expect(p1.hasPendingPassword, false);
    });

    test('migration: active resets are preserved', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1');
      await resetService.startReset('p1', 'newpass456');

      var p1 = profilesBox.get('p1')!;
      final pendingBefore = p1.pendingPasswordHash;

      await resetService.performMigration();

      p1 = profilesBox.get('p1')!;
      expect(p1.pendingPasswordHash, pendingBefore);
    });

    test('migration: legacy knowledge factors are scrubbed', () async {
      var p1 = Profile(
        id: 'p1',
        nameRaw: 'Legacy',
        preferredColorValue: 0xFF0000,
        createdAt: DateTime.now(),
        passwordHash: Profile.hashPassword('oldpass'),
        resetCode: 'ABC-123',
        securityQuestions: const ['F1', 'F2', 'F3'],
        securityAnswersHashed: const ['h1', 'h2', 'h3'],
      );
      await profilesBox.put('p1', p1);

      await resetService.performMigration();

      p1 = profilesBox.get('p1')!;
      expect(p1.resetCode, null);
      expect(p1.securityQuestions, null);
      expect(p1.securityAnswersHashed, null);
      expect(p1.hasPassword, true, reason: 'Passwort bleibt erhalten');
    });

    test('migration: scrub preserves a running reset', () async {
      createProfileWithPassword(id: 'p2', name: 'Laufend');
      await resetService.startReset('p2', 'newpass456');
      var p2 = profilesBox.get('p2')!;
      final endBefore = p2.resetEndsAt;
      p2 = p2.copyWith(resetCode: 'XYZ-999');
      await profilesBox.put('p2', p2);

      await resetService.performMigration();

      p2 = profilesBox.get('p2')!;
      expect(p2.resetCode, null);
      expect(p2.resetEndsAt, endBefore);
      expect(p2.hasPendingPassword, true, reason: 'Laufender Reset bleibt unangetastet');
    });

    test('frist-Einstellung während laufendem Reset ändert resetEndsAt nicht', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1', resetDurationHours: 24);
      await resetService.startReset('p1', 'newpass456');

      var p1 = profilesBox.get('p1')!;
      final originalEnd = p1.resetEndsAt;

      // Change the duration setting
      p1 = p1.copyWith(resetDurationHours: 72);
      profilesBox.put('p1', p1);

      p1 = profilesBox.get('p1')!;
      expect(p1.resetEndsAt, originalEnd, reason: 'resetEndsAt should not change when duration setting is updated');
    });

    test('setResetDuration updates the setting for future resets', () async {
      createProfileWithPassword(id: 'p1', name: 'Profile1');

      await resetService.setResetDuration('p1', 48);

      var p1 = profilesBox.get('p1')!;
      expect(p1.resetDurationHours, 48);
    });
  });
}
