// Die Migration räumt die deprecated Wissensfaktoren-Felder aus — dieser
// Service ist der einzige legitime Zugriffspunkt auf sie.
// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:math' show max;

import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:flutter/foundation.dart';

/// Enum für Login-Verifikation bei aktivem Reset
enum ResetLoginOutcome {
  /// Kein Reset aktiv oder abgelaufen, Passwort korrekt → normaler Login
  none,

  /// Reset aktiv, falsches Passwort eingegeben
  wrongPassword,

  /// Reset aktiv, richtiges altes Passwort → Reset abgebrochen
  cancelled,

  /// Reset abgelaufen, neues Passwort eingegeben → Reset aktiviert
  activated,
}

/// Service für Passwort-Reset mit Zeit-basiertem Zustandsübergang
///
/// Workflow:
/// 1. startReset(profileId, newPassword) → setzt resetStartedAt + resetEndsAt + pendingPasswordHash
/// 2. Frist läuft (24h Standard, pro Profil konfigurierbar)
/// 3. checkAndHandleLogin() beim Login:
///    - Frist abgelaufen? → altes Pending aktivieren (pending → passwordHash)
///    - Richtiges Passwort? → Reset abbrechen (Felder nullen)
///    - Falsches Passwort? → unangetastet
///
/// Reset-Zustand sitzt am Profil (resetStartedAt, resetEndsAt, resetDurationHours)
/// nicht mehr im globalen Settings-Slot.
class PasswordResetService extends BaseService {
  PasswordResetService(
    this._profileService,
    super.eventBus, {
    DateTime Function()? nowProvider,
  }) : _now = nowProvider ?? DateTime.now;

  final ProfileService _profileService;

  /// Injizierbare Zeitquelle — Tests können die Uhr stellen (Clock-Guard)
  final DateTime Function() _now;

  /// Key für letzten gesehenen Zeitstempel (Clock-Guard)
  static const String _lastSeenTimestampKey = 'last_seen_timestamp';

  /// Key für Migrations-Hinweis-Flag
  static const String _resetMigrationNoticeKey = 'reset_migration_notice';

  /// Alte globale Keys (für Migration)
  static const String _oldResetTimerKey = 'password_reset_timer';
  static const String _oldResetProfileIdKey = 'password_reset_profile_id';

  /// Standard-Reset-Frist: 24 Stunden
  static const Duration defaultResetDuration = Duration(hours: 24);

  /// Debug-Modus-Verkürzung: 20 Sekunden
  static const Duration debugResetDuration = Duration(seconds: 20);

  @override
  Future<void> openBoxes() async {
    logger.info(LogCategory.service, 'PasswordResetService initialized');

    // Migration: Alt-Reset-Zustand aufräumen
    await performMigration();
  }

  @override
  void subscribeToEvents() {
    // Keine Events zum Abonnieren
  }

  @override
  Future<void> closeBoxes() async {
    logger.info(LogCategory.service, 'PasswordResetService disposed');
  }

  /// Migration: Globale Alt-Resets löschen, Hinweis-Flag setzen, verwaiste Pendings nullen
  Future<void> performMigration() async {
    try {
      final hasOldReset =
          _profileService.settingsBox.containsKey(_oldResetTimerKey) ||
          _profileService.settingsBox.containsKey(_oldResetProfileIdKey);

      if (hasOldReset) {
        // Alte globale Keys löschen
        await _profileService.settingsBox.delete(_oldResetTimerKey);
        await _profileService.settingsBox.delete(_oldResetProfileIdKey);

        // Hinweis-Flag setzen
        await _profileService.settingsBox.put(_resetMigrationNoticeKey, true);

        logger.info(
          LogCategory.service,
          'Migration: Old global reset state cleaned up',
          data: {'flag_set': 'reset_migration_notice'},
        );
      }

      // Verwaiste Pending-Passwörter nullen (Profile ohne aktiven Reset) und
      // Wissensfaktoren-Altdaten (Reset-Code, Sicherheitsfragen) austragen —
      // die Felder bleiben nur für Hive-Kompatibilität im Modell
      var profilesUpdated = 0;
      for (final profile in _profileService.profilesBox.values) {
        final orphanedPending =
            profile.hasPendingPassword && !profile.hasActiveReset;
        final hasLegacyFactors =
            profile.resetCode != null ||
            profile.securityQuestions != null ||
            profile.securityAnswersHashed != null;
        if (!orphanedPending && !hasLegacyFactors) continue;

        final cleaned = orphanedPending
            ? _clearResetState(profile)
            : _buildProfileWithReset(
                profile,
                resetStartedAt: profile.resetStartedAt,
                resetEndsAt: profile.resetEndsAt,
                pendingPasswordHash: profile.pendingPasswordHash,
              );
        await _profileService.profilesBox.put(profile.id, cleaned);
        profilesUpdated++;
      }

      if (profilesUpdated > 0) {
        logger.info(
          LogCategory.service,
          'Migration: Profiles cleaned (orphaned pendings, legacy knowledge factors)',
          data: {'profiles_updated': profilesUpdated},
        );
      }
    } catch (e) {
      logger.error(
        LogCategory.service,
        'Error during password reset migration',
        data: {'error': e.toString()},
      );
    }
  }

  /// Startet einen Passwort-Reset für ein Profil
  /// - Nur bei hasPassword erfolgreich
  /// - Liegt ein ABGELAUFENER Reset vor → erst aktivieren, dann neuen Reset starten
  /// - Erneuter Aufruf während Frist → Pending + Ende ersetzen (R6)
  /// - Frist = resetDurationHours des Ziel-Profils (null ⇒ 24h)
  /// - Debug-Modus: 20 Sekunden
  Future<bool> startReset(String profileId, String newPassword) async {
    try {
      await _updateClockGuard();

      final profile = _profileService.profilesBox.get(profileId);
      if (profile == null) {
        logger.error(
          LogCategory.service,
          'Cannot start password reset: Profile not found',
          data: {'profile_id': profileId},
        );
        return false;
      }

      if (!profile.hasPassword) {
        logger.warning(
          LogCategory.service,
          'Cannot start password reset: Profile has no password',
          data: {'profile_id': profileId, 'profile_name': profile.name},
        );
        return false;
      }

      var workingProfile = profile;

      // Wenn ein abgelaufener Reset liegt → erst aktivieren
      if (_istAbgelaufen(workingProfile)) {
        workingProfile = _activateReset(workingProfile);
        logger.info(
          LogCategory.service,
          'Activated expired reset before starting new one',
          data: {'profile_id': profileId},
        );
      }

      // Neuen Reset starten
      final now = _now();
      final frist = _getResetDuration(workingProfile);
      final newPendingHash = Profile.hashPassword(newPassword);
      final endTime = now.add(frist);

      workingProfile = _buildProfileWithReset(
        workingProfile,
        resetStartedAt: now,
        resetEndsAt: endTime,
        pendingPasswordHash: newPendingHash,
      );

      await _profileService.profilesBox.put(profileId, workingProfile);

      logger.info(
        LogCategory.service,
        'Password reset started',
        data: {
          'profile_id': profileId,
          'profile_name': workingProfile.name,
          'duration_hours': workingProfile.resetDurationHours ?? 24,
          'end_time': endTime.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      logger.error(
        LogCategory.service,
        'Error starting password reset',
        data: {'profile_id': profileId, 'error': e.toString()},
      );
      return false;
    }
  }

  /// Prüft Login-Versuch bei potenziellem Reset
  /// Atomar in dieser Reihenfolge:
  /// 1. Ist Frist abgelaufen? → aktivieren (pending → passwordHash)
  /// 2. Passwort prüfen (gegen neuen Hash falls aktiviert)
  /// 3. Korrekt + Reset lief noch (nicht expired)? → abbrechen (Felder nullen) ⇒ cancelled
  /// 4. Korrekt + Reset war abgelaufen + wurde aktiviert? ⇒ activated
  /// 5. Korrekt ohne Reset ⇒ none
  /// 6. Falsch ⇒ wrongPassword (Reset unangetastet)
  Future<ResetLoginOutcome> checkAndHandleLogin(
    Profile profile,
    String enteredPassword,
  ) async {
    try {
      await _updateClockGuard();

      // WICHTIG: Immer frisch aus der Box laden - übergebenes Profil könnte veraltet sein
      var workingProfile =
          _profileService.profilesBox.get(profile.id) ?? profile;

      // Schritt 1: Frist abgelaufen → aktivieren.
      // Die Zeitfrage beantwortet der Service, nicht das Modell: nur hier
      // ist die Uhr injizierbar und der Rückwärtssprung-Schutz wirksam.
      var didActivate = false;
      if (_istAbgelaufen(workingProfile)) {
        didActivate = true;
        workingProfile = _activateReset(workingProfile);
        await _profileService.profilesBox.put(profile.id, workingProfile);
      }

      // Schritt 2: Passwort prüfen (gegen current passwordHash nach evtl. Aktivierung)
      final passwordCorrect = workingProfile.verifyPassword(enteredPassword);

      if (!passwordCorrect) {
        // Falsches Passwort → Reset unangetastet
        return ResetLoginOutcome.wrongPassword;
      }

      // Passwort korrekt. Jetzt kommt die Reset-Logik:

      // Schritt 3+4: War Reset aktiv und gerade aktiviert?
      if (didActivate) {
        // Wurde gerade durch Fristende aktiviert
        return ResetLoginOutcome.activated;
      }

      // Schritt 3b: War Reset aktiv BEVOR expiry-check? → abbrechen
      if (workingProfile.hasPendingPassword) {
        // Noch ein aktiver Reset (nicht abgelaufen)
        workingProfile = _clearResetState(workingProfile);
        await _profileService.profilesBox.put(profile.id, workingProfile);
        return ResetLoginOutcome.cancelled;
      }

      // Schritt 5: Kein Reset → normaler Login
      return ResetLoginOutcome.none;
    } catch (e) {
      logger.error(
        LogCategory.service,
        'Error checking login with reset state',
        data: {'profile_id': profile.id, 'error': e.toString()},
      );
      return ResetLoginOutcome.wrongPassword; // Sicher fehlschlagen
    }
  }

  /// Setzt die Reset-Frist für zukünftige Resets dieses Profils
  /// Ändert resetDurationHours, wirkt nicht auf laufende Resets
  Future<void> setResetDuration(String profileId, int hours) async {
    try {
      final profile = _profileService.profilesBox.get(profileId);
      if (profile == null) return;

      final updated = profile.copyWith(resetDurationHours: hours);
      await _profileService.profilesBox.put(profileId, updated);

      logger.info(
        LogCategory.service,
        'Reset duration updated',
        data: {
          'profile_id': profileId,
          'profile_name': profile.name,
          'hours': hours,
        },
      );
    } catch (e) {
      logger.error(
        LogCategory.service,
        'Error setting reset duration',
        data: {'profile_id': profileId, 'error': e.toString()},
      );
    }
  }

  /// Debug: Verkürzt resetEndsAt auf now + 20 Sekunden
  /// Wenn keine profileId angegeben: nutzt das aktive Reset-Profil (für Rückwärtskompatibilität)
  /// SECURITY: Nur im kDebugMode verfügbar
  Future<bool> skipToLastTwentySeconds(String profileId) async {
    if (!kDebugMode) {
      logger.warning(
        LogCategory.service,
        'skipToLastTwentySeconds blocked: Not in debug mode',
      );
      return false;
    }

    final targetProfileId = profileId;

    try {
      final profile = _profileService.profilesBox.get(targetProfileId);
      if (profile == null) {
        logger.warning(
          LogCategory.service,
          'Cannot skip time: Profile not found',
          data: {'profile_id': targetProfileId},
        );
        return false;
      }

      if (!profile.hasActiveReset) {
        logger.warning(
          LogCategory.service,
          'Cannot skip time: No active reset',
          data: {'profile_id': targetProfileId},
        );
        return false;
      }

      const twentySeconds = Duration(seconds: 20);
      final newEnd = _now().add(twentySeconds);

      final updated = profile.copyWith(resetEndsAt: newEnd);
      await _profileService.profilesBox.put(targetProfileId, updated);

      logger.info(
        LogCategory.service,
        'Reset time skipped to last 20 seconds',
        data: {
          'profile_id': targetProfileId,
          'new_end_time': newEnd.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      logger.error(
        LogCategory.service,
        'Error skipping reset time',
        data: {'profile_id': targetProfileId, 'error': e.toString()},
      );
      return false;
    }
  }

  // ========== Private Helpers ==========

  /// Ist die Frist dieses Profils durch? Gemessen an der Uhr des Service.
  bool _istAbgelaufen(Profile profile) {
    if (!profile.hasActiveReset) return false;
    return !_now().isBefore(profile.resetEndsAt!);
  }

  /// Clock-Guard: Bei Rückwärtssprung → resetEndsAt aller laufenden Resets verschieben
  Future<void> _updateClockGuard() async {
    final now = _now();
    final lastSeen =
        _profileService.settingsBox.get(_lastSeenTimestampKey) as int?;

    if (lastSeen != null) {
      final lastSeenTime = DateTime.fromMillisecondsSinceEpoch(lastSeen);

      if (now.isBefore(lastSeenTime)) {
        // Rückwärtssprung! Berechne Differenz
        final diff = lastSeenTime.difference(now);

        // Schiebe alle laufenden resetEndsAt nach hinten
        for (final profile in _profileService.profilesBox.values) {
          if (profile.hasActiveReset) {
            final newEnd = profile.resetEndsAt!.add(diff);
            final updated = profile.copyWith(resetEndsAt: newEnd);
            await _profileService.profilesBox.put(profile.id, updated);
          }
        }

        logger.warning(
          LogCategory.service,
          'Clock backward shift detected and compensated',
          data: {
            'shift_seconds': diff.inSeconds,
            'profiles_adjusted': _profileService.profilesBox.values
                .where((p) => p.hasActiveReset)
                .length,
          },
        );
      }
    }

    // Aktualisiere lastSeen auf max(lastSeen, now)
    final newLastSeen = lastSeen != null
        ? max(lastSeen, now.millisecondsSinceEpoch)
        : now.millisecondsSinceEpoch;

    await _profileService.settingsBox.put(_lastSeenTimestampKey, newLastSeen);
  }

  /// Gibt die Frist-Duration für ein Profil zurück
  Duration _getResetDuration(Profile profile) {
    // Debug-Modus nur wenn BEIDE true: kDebugMode UND debug_mode_enabled Setting
    final debugEnabled =
        kDebugMode &&
        (_profileService.settingsBox.get(
              'debug_mode_enabled',
              defaultValue: false,
            )
            as bool);

    if (!debugEnabled) {
      // Production: resetDurationHours oder 24h Standard
      final hours = profile.resetDurationHours ?? 24;
      return Duration(hours: hours);
    } else {
      // Debug: 20 Sekunden
      return debugResetDuration;
    }
  }

  /// Aktiviert einen ausstehenden Reset: pending → passwordHash, Reset-Felder nullen
  Profile _activateReset(Profile profile) {
    if (!profile.hasPendingPassword) return profile;

    // Die Reset-Felder werden hier nicht übergeben und damit geleert — das
    // ist der Zweck der Funktion, siehe ihren Doc-Kommentar und die
    // „Null ist gültig"-Vermerke in `_buildProfileWithReset`.
    return _buildProfileWithReset(
      profile,
      passwordHash: profile.pendingPasswordHash!,
    );
  }

  /// Löscht den Reset-Zustand: nullt resetStartedAt, resetEndsAt, pendingPasswordHash
  Profile _clearResetState(Profile profile) {
    // Kein Reset-Feld übergeben heißt: alle drei werden geleert.
    return _buildProfileWithReset(profile);
  }

  /// Baut ein neues Profile-Objekt mit explizit gesetzten Reset-Feldern
  /// (Workaround für copyWith mit null-Werten als Sentinel)
  Profile _buildProfileWithReset(
    Profile profile, {
    String? passwordHash,
    DateTime? resetStartedAt,
    DateTime? resetEndsAt,
    String? pendingPasswordHash,
  }) {
    return Profile(
      id: profile.id,
      nameRaw: profile.nameRaw,
      avatarPath: profile.avatarPath,
      preferredColorValue: profile.preferredColorValue,
      age: profile.age,
      description: profile.description,
      createdAt: profile.createdAt,
      isAdmin: profile.isAdmin,
      permissions: profile.permissions,
      preferredLanguage: profile.preferredLanguage,
      isActive: profile.isActive,
      passwordHash: passwordHash ?? profile.passwordHash,
      // resetCode/securityQuestions/securityAnswersHashed absichtlich nicht
      // kopiert: Wissensfaktoren sind entfernt, jeder Schreibpfad nullt sie
      pendingPasswordHash:
          pendingPasswordHash, // Null ist gültig - nullt das Feld
      hasSeenPostLoginWelcome: profile.hasSeenPostLoginWelcome,
      colorPickerPositionX: profile.colorPickerPositionX,
      colorPickerPositionY: profile.colorPickerPositionY,
      resetStartedAt: resetStartedAt, // Null ist gültig - nullt das Feld
      resetEndsAt: resetEndsAt, // Null ist gültig - nullt das Feld
      resetDurationHours: profile.resetDurationHours,
    );
  }
}
