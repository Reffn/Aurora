import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/events/profile_events.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/profile_selection_screen.dart';
import 'package:dis_app/services/permission_preset_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

/// Profile-Service - Verwaltet Profile mit Hive-Persistierung
/// Nutzt Hive ValueListenable für reaktive UI-Updates
/// Inkl. Permission-Management (RBAC)
class ProfileService extends BaseService {
  // Typisierte box für Settings (active_profile_id, etc.)

  ProfileService(super.eventBus);
  late Box<Profile> _profileBox;
  late Box<dynamic> _settingsBox;

  @override
  Future<void> openBoxes() async {
    // PARALLEL: Öffne beide Boxes gleichzeitig für bessere Performance
    final boxOpenStart = DateTime.now();
    final results = await Future.wait([
      Hive.openBox<Profile>(HiveBoxNames.profiles),
      Hive.openBox<dynamic>(HiveBoxNames.settings),
    ]);

    _profileBox = results[0] as Box<Profile>;
    _settingsBox = results[1];

    logger.info(
      LogCategory.service,
      '    ⏱️ ProfileService: boxes opened (parallel)',
      data: {
        'duration':
            '${DateTime.now().difference(boxOpenStart).inMilliseconds}ms',
        'boxes': 'profiles + settings',
      },
    );

    // Migration: Bestehende Profile mit Permissions ausstatten
    final stepStart = DateTime.now();
    await _migrateProfilesToPermissions();
    logger.info(
      LogCategory.service,
      '    ⏱️ ProfileService: migration completed',
      data: {
        'duration': '${DateTime.now().difference(stepStart).inMilliseconds}ms',
      },
    );

    // REMOVED: Auto-activation logic
    // Active profile will be set by user selection on ProfileSelectionScreen
    // This ensures ProfileSelectionScreen appears on every app startup
    logger.info(
      LogCategory.service,
      '    ⏱️ ProfileService: ready (no auto-activation)',
    );
  }

  /// Migration: Stellt sicher, dass erstes Profil Admin ist
  /// und alle Profile gültige Permissions haben
  /// + Color Picker Position Migration (alte Profile ohne Position)
  Future<void> _migrateProfilesToPermissions() async {
    if (_profileBox.isEmpty) return;

    // Erstes Profil wird Admin (falls noch nicht)
    final firstProfile = _profileBox.values.first;
    var needsUpdate = false;
    var updatedFirst = firstProfile;

    if (!firstProfile.isAdmin) {
      updatedFirst = firstProfile.copyWith(
        isAdmin: true,
        permissions: Permission.values.map((p) => p.persistedValue).toList(),
      );
      needsUpdate = true;
      logger.info(
        LogCategory.service,
        'Migration: First profile set as admin',
        data: {'profileId': firstProfile.id, 'profileName': firstProfile.name},
      );
    }

    // Color Picker Position Migration für erstes Profil
    if (updatedFirst.colorPickerPositionNormalized == null) {
      updatedFirst = updatedFirst.copyWith(
        preferredColor: Colors.white,
        colorPickerPositionX: 0.5, // Zentrum
        colorPickerPositionY: 0.5,
      );
      needsUpdate = true;
      logger.info(
        LogCategory.service,
        'Migration: First profile color position set to center (white)',
        data: {'profileId': firstProfile.id, 'profileName': firstProfile.name},
      );
    }

    if (needsUpdate) {
      await _profileBox.put(firstProfile.id, updatedFirst);
    }

    // Andere Profile: Default-Permissions wenn leer + Color Position Migration
    for (final profile in _profileBox.values.skip(1)) {
      needsUpdate = false;
      var updated = profile;

      if (profile.permissions.isEmpty && !profile.isAdmin) {
        final defaultPermissions = _getDefaultPermissions();
        updated = profile.copyWith(permissions: defaultPermissions);
        needsUpdate = true;
        logger.info(
          LogCategory.service,
          'Migration: Added default permissions to profile',
          data: {'profileId': profile.id, 'profileName': profile.name},
        );
      }

      // Color Picker Position Migration
      if (updated.colorPickerPositionNormalized == null) {
        updated = updated.copyWith(
          preferredColor: Colors.white,
          colorPickerPositionX: 0.5, // Zentrum
          colorPickerPositionY: 0.5,
        );
        needsUpdate = true;
        logger.info(
          LogCategory.service,
          'Migration: Profile color position set to center (white)',
          data: {'profileId': profile.id, 'profileName': profile.name},
        );
      }

      if (needsUpdate) {
        await _profileBox.put(profile.id, updated);
      }
    }
  }

  /// Standard-Berechtigungen für neue Profile
  List<String> _getDefaultPermissions() {
    // Verwende Standard-Preset aus JSON
    final presetService = getIt<PermissionPresetService>();
    return presetService.getPermissionsForPreset('standard');
  }

  @override
  void subscribeToEvents() {
    eventBus.on<ProfileCreatedEvent>().listen(_handleProfileCreated);
    eventBus.on<ProfileUpdatedEvent>().listen(_handleProfileUpdated);
    eventBus.on<ProfileDeactivatedEvent>().listen(_handleProfileDeactivated);
    eventBus.on<ProfileReactivatedEvent>().listen(_handleProfileReactivated);
    eventBus.on<ProfilesRequestedEvent>().listen(_handleProfilesRequested);
    eventBus.on<ActiveProfileChangedEvent>().listen(
      _handleActiveProfileChanged,
    );
  }

  @override
  Future<void> closeBoxes() async {
    await _profileBox.close();
    await _settingsBox.close();
  }

  /// Zugriff auf Profile-Box für ValueListenable
  Box<Profile> get profilesBox => _profileBox;

  /// Zugriff auf Settings-Box für ValueListenable
  Box<dynamic> get settingsBox => _settingsBox;

  /// Alle Profile abrufen (für nicht-reaktive Zugriffe)
  List<Profile> get profiles => List.unmodifiable(_profileBox.values.toList());

  /// Nur aktive Profile abrufen (für UI-Listen wie ProfileSwitcher)
  List<Profile> get activeProfiles =>
      List.unmodifiable(_profileBox.values.where((p) => p.isActive).toList());

  /// Alle Profile inkl. deaktivierte (für History, Admin-Views)
  List<Profile> get allProfiles => profiles;

  /// Aktives Profil abrufen (synchron)
  Profile? get activeProfile {
    final activeProfileId = _settingsBox.get('active_profile_id') as String?;
    if (activeProfileId == null) return null;

    try {
      return _profileBox.values.firstWhere((p) => p.id == activeProfileId);
    } catch (e) {
      return _profileBox.values.isNotEmpty ? _profileBox.values.first : null;
    }
  }

  /// Logout: Deaktiviert das aktive Profil
  /// Caller muss Navigation zum ProfileSelectionScreen durchführen
  @Deprecated('Use performLogout() instead for complete logout with navigation')
  Future<void> logout() async {
    final currentProfile = activeProfile;

    // Lösche aktives Profil
    await _settingsBox.delete('active_profile_id');

    logger.info(
      LogCategory.service,
      'Profil ausgeloggt',
      data: {
        'profileId': currentProfile?.id ?? 'none',
        'profileName': currentProfile?.name ?? 'none',
      },
    );
  }

  /// Kompletter Logout: Löscht aktives Profil + navigiert zur Profilauswahl
  ///
  /// Verwendet pushAndRemoveUntil um ALLE Screens zu disposen
  ///
  /// [context] - BuildContext für Navigation (muss mounted sein)
  /// [reason] - Optional: Grund für Logging (z.B. 'Auto-Logout', 'Manuelles Logout')
  ///
  /// Returns true wenn erfolgreich, false wenn context unmounted war
  Future<bool> performLogout(BuildContext context, {String? reason}) async {
    final currentProfile = activeProfile;

    // Aktives Profil löschen
    await _settingsBox.delete('active_profile_id');

    logger.info(
      LogCategory.service,
      reason ?? 'Profil ausgeloggt',
      data: {
        'profileId': currentProfile?.id ?? 'none',
        'profileName': currentProfile?.name ?? 'none',
      },
    );

    // Navigation mit kompletter Stack-Clearance
    if (context.mounted) {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (context) =>
              const ProfileSelectionScreen(), // ignore: prefer_const_constructors
        ),
        (route) => false, // Entfernt ALLE vorherigen Routes
      );
      return true;
    }

    return false;
  }

  /// Profil erstellt
  void _handleProfileCreated(ProfileCreatedEvent event) {
    try {
      _profileBox.put(event.profile.id, event.profile);
      // Hive notified automatisch alle ValueListenable Listener!

      // Bestätigung publishen
      eventBus.publish(ProfileSavedEvent(event.profile));

      // REMOVED: Auto-activation of first profile
      // User must explicitly select profile on ProfileSelectionScreen
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error creating profile',
        data: {'profileId': event.profile.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Profil aktualisiert
  void _handleProfileUpdated(ProfileUpdatedEvent event) {
    try {
      if (_profileBox.containsKey(event.profile.id)) {
        _profileBox.put(event.profile.id, event.profile);
        // Hive notified automatisch alle ValueListenable Listener!
      }
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error updating profile',
        data: {'profileId': event.profile.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Profil pausiert
  void _handleProfileDeactivated(ProfileDeactivatedEvent event) {
    // Den Zustand ändert deactivateProfile(); DataEntry meldet das Ereignis
    // erst danach und nur bei Erfolg. Hier nichts mehr am Profil ändern.

    // Falls das aktive Profil pausiert wurde, auf ein aktives wechseln.
    // `canPause` schließt das aus; die Absicherung bleibt.
    final currentActiveId = _settingsBox.get('active_profile_id') as String?;
    if (currentActiveId == event.profileId) {
      final activeProfiles = _profileBox.values
          .where((p) => p.isActive)
          .toList();
      if (activeProfiles.isNotEmpty) {
        _settingsBox.put('active_profile_id', activeProfiles.first.id);
      }
      // Hive notified automatisch alle ValueListenable Listener!
    }
  }

  /// Profil wieder aufgenommen
  void _handleProfileReactivated(ProfileReactivatedEvent event) {
    // Den Zustand ändert reactivateProfile(), bevor das Ereignis kommt.
    // Hier ist nichts weiter zu tun.
  }

  /// Profile angefordert
  void _handleProfilesRequested(ProfilesRequestedEvent event) {
    eventBus.publish(ProfilesLoadedEvent(profiles));
  }

  /// Aktives Profil gewechselt
  void _handleActiveProfileChanged(ActiveProfileChangedEvent event) {
    _settingsBox.put('active_profile_id', event.profile.id);
    // Hive notified automatisch alle ValueListenable Listener!
  }

  /// Alle Profile und Einstellungen löschen (Debug-Option)
  Future<void> clearAll() async {
    await _profileBox.clear();
    await _settingsBox.clear();
    // Hive notified automatisch alle ValueListenable Listener!
  }

  // ============ PERMISSION MANAGEMENT ============

  /// Rechte ändern darf, wer „Rechte vergeben“ hat, nicht nur ein Admin.
  /// Sonst bietet der Schirm einem Nicht-Admin mit diesem Recht das Ändern
  /// an, und es scheitert. Admins haben es über `hasPermission` immer.
  bool get _mayGrantRights =>
      activeProfile?.hasPermission(Permission.managePermissions) == true;

  /// Setzt alle Berechtigungen eines Profils auf einmal
  /// Nur wer Rechte vergeben darf, darf Berechtigungen ändern!
  Future<bool> updateProfilePermissions(
    String profileId,
    List<Permission> permissions,
  ) async {
    if (!_mayGrantRights) {
      logger.warning(
        LogCategory.permission,
        'Permission denied: managePermissions required to update permissions',
        data: {
          'profileId': profileId,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    final profile = _profileBox.get(profileId);
    if (profile == null) return false;

    final permissionStrings = permissions.map((p) => p.persistedValue).toList();
    final updated = profile.copyWith(permissions: permissionStrings);
    await _profileBox.put(profileId, updated);
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }

  /// Macht ein Profil zum Admin (alle Rechte)
  /// Nur bestehende Admins dürfen neue Admins ernennen!
  Future<bool> makeAdmin(String profileId) async {
    if (activeProfile?.isAdmin != true) {
      logger.warning(
        LogCategory.permission,
        'Permission denied: Only admins can make other admins',
        data: {
          'profileId': profileId,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    final profile = _profileBox.get(profileId);
    if (profile == null) return false;
    if (profile.isAdmin) return true; // Schon Admin

    final updated = profile.copyWith(
      isAdmin: true,
      permissions: Permission.values.map((p) => p.persistedValue).toList(),
    );
    await _profileBox.put(profileId, updated);
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }

  /// Ob der aktive Anteil [profileId] die Admin-Rolle nehmen darf. Wie bei
  /// [canPause] stehen die Regeln nur hier; die Oberfläche fragt dieselbe
  /// Stelle und bietet sonst nichts an. Bewusst ohne Log, sie wird beim
  /// Aufbau des Schirms gefragt.
  bool canRevokeAdmin(String profileId) {
    // Nur ein Admin nimmt die Rolle, auch wer „Rechte vergeben“ hat nicht.
    if (activeProfile?.isAdmin != true) return false;

    final target = _profileBox.get(profileId);
    if (target == null || !target.isAdmin) return false;

    // Der erste Anteil (ältestes createdAt, auch pausiert) bleibt Admin.
    final firstProfile = _profileBox.values.reduce(
      (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
    );
    if (target.id == firstProfile.id) return false;

    // Ein aktiver Admin muss bleiben; pausierte zählen nicht, wie bei
    // [canPause]. Sonst gibt B die Rolle ab, nachdem B den Admin A pausiert
    // hat, und niemand kann A mehr zurückholen.
    final remainingActiveAdmins = _profileBox.values
        .where((p) => p.isAdmin && p.isActive && p.id != profileId)
        .length;
    return remainingActiveAdmins > 0;
  }

  /// Entfernt Admin-Status (Vorsicht!)
  /// Die Regeln stehen in [canRevokeAdmin].
  Future<bool> revokeAdmin(String profileId) async {
    if (!canRevokeAdmin(profileId)) {
      logger.warning(
        LogCategory.permission,
        'Revoking admin refused',
        data: {
          'profileId': profileId,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    final profile = _profileBox.get(profileId)!;
    final updated = profile.copyWith(
      isAdmin: false,
      permissions: _getDefaultPermissions(),
    );
    await _profileBox.put(profileId, updated);
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }

  // ============ PAUSIEREN ============

  /// Pausieren und wieder aufnehmen brauchen dasselbe Recht. Ohne Recht
  /// zurückholen hieße, jeder Anteil holte zurück, was ein anderer mit Recht
  /// pausiert hat.
  bool get _mayPause =>
      activeProfile?.hasPermission(Permission.deactivateProfiles) == true;

  /// Ob der aktive Anteil pausierte Anteile wieder aufnehmen darf.
  bool get canResume => _mayPause;

  /// Ob der aktive Anteil diesen Anteil pausieren darf. Die Regeln stehen
  /// nur hier; die Oberfläche fragt dieselbe Stelle und bietet sonst nichts
  /// an. Bewusst ohne Log, sie wird beim Aufbau jeder Zeile gefragt.
  bool canPause(String profileId) {
    if (!_mayPause) return false;

    // Wer sich selbst pausiert, sperrt sich aus.
    if (profileId == activeProfile?.id) return false;

    final target = _profileBox.get(profileId);
    if (target == null || !target.isActive) return false;

    // Ein aktiver Admin muss bleiben; pausierte zählen nicht.
    if (target.isAdmin) {
      final activeAdmins = _profileBox.values
          .where((p) => p.isAdmin && p.isActive)
          .length;
      if (activeAdmins <= 1) return false;
    }

    return true;
  }

  /// Pausiert einen Anteil: Er verschwindet aus der Auswahl, alle seine
  /// Daten bleiben. Ändert nur `isActive`.
  Future<bool> deactivateProfile(String profileId) async {
    if (!canPause(profileId)) {
      logger.warning(
        LogCategory.permission,
        'Pausing refused',
        data: {
          'profileId': profileId,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    final profile = _profileBox.get(profileId)!;
    await _profileBox.put(profileId, profile.copyWith(isActive: false));
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }

  /// Nimmt einen pausierten Anteil wieder auf. Name, Passwort und Rechte
  /// sind unverändert geblieben und gelten weiter.
  Future<bool> reactivateProfile(String profileId) async {
    if (!_mayPause) {
      logger.warning(
        LogCategory.permission,
        'Permission denied: deactivateProfiles required to resume profiles',
        data: {
          'profileId': profileId,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    final profile = _profileBox.get(profileId);
    if (profile == null || profile.isActive) return false;

    await _profileBox.put(profileId, profile.copyWith(isActive: true));
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }
}
