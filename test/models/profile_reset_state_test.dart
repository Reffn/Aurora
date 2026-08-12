import 'package:dis_app/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile Reset State', () {
    final now = DateTime.now();
    final futureTime = now.add(const Duration(hours: 24));
    final pastTime = now.subtract(const Duration(hours: 1));

    test('Profil ohne Reset hat hasActiveReset == false', () {
      final profile = Profile(
        id: 'test-1',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
      );

      expect(profile.hasActiveReset, false);
      expect(profile.isResetExpired, false);
    });

    test('mit gesetztem Start + Ende in Zukunft → hasActiveReset == true', () {
      final profile = Profile(
        id: 'test-2',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
        resetStartedAt: now,
        resetEndsAt: futureTime,
        resetDurationHours: 24,
      );

      expect(profile.hasActiveReset, true);
      expect(profile.isResetExpired, false);
    });

    test('exakt am Fristende (now == resetEndsAt) → isResetExpired == true', () {
      final endTime = now;
      final profile = Profile(
        id: 'test-3',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
        resetStartedAt: pastTime,
        resetEndsAt: endTime,
        resetDurationHours: 24,
      );

      // isBefore ist false wenn now == resetEndsAt, d.h. isResetExpired sollte true sein
      expect(now.isBefore(endTime), false);
      expect(profile.isResetExpired, true);
    });

    test('pendingPasswordHash == "" (Altlast) ⇒ hasPendingPassword == false', () {
      final profile = Profile(
        id: 'test-4',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
        pendingPasswordHash: '',
      );

      expect(profile.hasPendingPassword, false);
    });

    test('pendingPasswordHash null ⇒ hasPendingPassword == false', () {
      final profile = Profile(
        id: 'test-5',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
      );

      expect(profile.hasPendingPassword, false);
    });

    test('pendingPasswordHash mit Wert ⇒ hasPendingPassword == true', () {
      final profile = Profile(
        id: 'test-6',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
        pendingPasswordHash: 'some-hash-value',
      );

      expect(profile.hasPendingPassword, true);
    });

    test('Serialisierungs-Roundtrip erhält alle Reset-Felder', () {
      final original = Profile(
        id: 'test-7',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
        resetStartedAt: now,
        resetEndsAt: futureTime,
        resetDurationHours: 48,
      );

      final map = original.toMap();
      final restored = Profile.fromMap(map);

      expect(restored.resetStartedAt, original.resetStartedAt);
      expect(restored.resetEndsAt, original.resetEndsAt);
      expect(restored.resetDurationHours, original.resetDurationHours);
      expect(restored.hasActiveReset, original.hasActiveReset);
    });

    test('Altprofil-Map mit resetCode/securityQuestions lädt fehlerfrei', () {
      final legacyMap = {
        'id': 'test-8',
        'name': 'Legacy Profil',
        'avatar_path': null,
        'preferred_color': Colors.green.value,
        'created_at': now.toIso8601String(),
        'reset_code': 'ABC-123',
        'security_questions': ['Q1', 'Q2', 'Q3'],
        'security_answers_hashed': ['A1', 'A2', 'A3'],
      };

      final profile = Profile.fromMap(legacyMap);

      expect(profile.id, 'test-8');
      expect(profile.name, 'Legacy Profil');
      // Alte Felder sollten geladen werden ohne Fehler
      expect(profile.resetCode, 'ABC-123');
      expect(profile.securityQuestions, ['Q1', 'Q2', 'Q3']);
    });

    test('nur resetStartedAt gesetzt → hasActiveReset == false', () {
      final profile = Profile(
        id: 'test-9',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
        resetStartedAt: now,
      );

      expect(profile.hasActiveReset, false);
    });

    test('nur resetEndsAt gesetzt → hasActiveReset == false', () {
      final profile = Profile(
        id: 'test-10',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
        resetEndsAt: futureTime,
      );

      expect(profile.hasActiveReset, false);
    });

    test('copyWith mit resetStartedAt', () {
      final original = Profile(
        id: 'test-11',
        nameRaw: 'Test Profil',
        preferredColorValue: Colors.blue.toARGB32(),
        createdAt: now,
      );

      final copied = original.copyWith(
        resetStartedAt: now,
        resetEndsAt: futureTime,
        resetDurationHours: 24,
      );

      expect(copied.resetStartedAt, now);
      expect(copied.resetEndsAt, futureTime);
      expect(copied.resetDurationHours, 24);
      expect(copied.id, original.id);
      expect(copied.nameRaw, original.nameRaw);
    });
  });
}
