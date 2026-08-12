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

  /// Profil deaktiviert
  void _handleProfileDeactivated(ProfileDeactivatedEvent event) {
    // Die eigentliche Deaktivierung wird von deactivateProfile() durchgeführt
    // Dieser Handler wird nur für zusätzliche Logik verwendet

    // Falls aktives Profil deaktiviert, auf erstes aktives wechseln
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

  /// Profil reaktiviert
  void _handleProfileReactivated(ProfileReactivatedEvent event) {
    // Die eigentliche Reaktivierung wird von reactivateProfile() durchgeführt
    // Dieser Handler wird nur für zusätzliche Logik verwendet (aktuell leer)
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

  /// Berechtigung einem Profil gewähren
  /// Nur Admin darf Berechtigungen ändern!
  Future<bool> grantPermission(String profileId, Permission permission) async {
    // Validierung: Nur Admin darf ändern
    if (activeProfile?.isAdmin != true) {
      logger.warning(
        LogCategory.permission,
        'Permission denied: Only admins can grant permissions',
        data: {
          'profileId': profileId,
          'permission': permission.persistedValue,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    final profile = _profileBox.get(profileId);
    if (profile == null) return false;

    // Falls schon vorhanden, nichts tun
    if (profile.hasPermission(permission)) return true;

    final updatedPermissions = List<String>.from(profile.permissions)
      ..add(permission.persistedValue);

    final updated = profile.copyWith(permissions: updatedPermissions);
    await _profileBox.put(profileId, updated);
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }

  /// Berechtigung einem Profil entziehen
  /// Nur Admin darf Berechtigungen ändern!
  Future<bool> revokePermission(String profileId, Permission permission) async {
    // Validierung: Nur Admin darf ändern
    if (activeProfile?.isAdmin != true) {
      logger.warning(
        LogCategory.permission,
        'Permission denied: Only admins can revoke permissions',
        data: {
          'profileId': profileId,
          'permission': permission.persistedValue,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    final profile = _profileBox.get(profileId);
    if (profile == null) return false;

    // Admin darf sich nicht selbst "ent-adminnen"
    if (profile.isAdmin && permission == Permission.managePermissions) {
      logger.warning(
        LogCategory.permission,
        'Cannot remove admin permissions from admin profile',
        data: {'profileId': profileId},
      );
      return false;
    }

    final updatedPermissions = List<String>.from(profile.permissions)
      ..remove(permission.persistedValue);

    final updated = profile.copyWith(permissions: updatedPermissions);
    await _profileBox.put(profileId, updated);
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }

  /// Setzt alle Berechtigungen eines Profils auf einmal
  /// Nur Admin darf Berechtigungen ändern!
  Future<bool> updateProfilePermissions(
    String profileId,
    List<Permission> permissions,
  ) async {
    // Validierung: Nur Admin darf ändern
    if (activeProfile?.isAdmin != true) {
      logger.warning(
        LogCategory.permission,
        'Permission denied: Only admins can update permissions',
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

  /// Schaltet eine Berechtigung um. Gibt zurück, ob das **gelungen** ist.
  ///
  /// Nicht den neuen Zustand: Der wurde hier früher zurückgegeben, und der
  /// aufrufende Schirm las ihn als Erfolg — jedes erfolgreiche Abschalten
  /// zeigte damit „Berechtigung konnte nicht geändert werden". Wer den
  /// Zustand braucht, fragt das Profil.
  Future<bool> togglePermission(String profileId, Permission permission) async {
    final profile = _profileBox.get(profileId);
    if (profile == null) return false;

    if (profile.hasPermission(permission)) {
      await revokePermission(profileId, permission);
    } else {
      await grantPermission(profileId, permission);
    }
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

  /// Entfernt Admin-Status (Vorsicht!)
  /// NICHT für das letzte Admin-Profil erlaubt!
  Future<bool> revokeAdmin(String profileId) async {
    if (activeProfile?.isAdmin != true) {
      logger.warning(
        LogCategory.permission,
        'Permission denied: Only admins can revoke admin status',
        data: {
          'profileId': profileId,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    final profile = _profileBox.get(profileId);
    if (profile == null) return false;

    // Prüfe: Erstes Profil (ältestes createdAt) darf nicht entfernt werden
    final allProfiles = _profileBox.values.toList();
    if (allProfiles.isNotEmpty) {
      final firstProfile = allProfiles.reduce(
        (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
      );
      if (profile.id == firstProfile.id) {
        logger.warning(
          LogCategory.permission,
          'Cannot revoke admin: First profile must remain admin',
          data: {'profileId': profileId, 'createdAt': profile.createdAt},
        );
        return false;
      }
    }

    // Prüfe: Mindestens ein Admin muss bleiben
    final adminCount = _profileBox.values.where((p) => p.isAdmin).length;
    if (adminCount <= 1) {
      logger.warning(
        LogCategory.permission,
        'Cannot revoke admin: At least one admin must remain',
        data: {'profileId': profileId, 'adminCount': adminCount},
      );
      return false;
    }

    final updated = profile.copyWith(
      isAdmin: false,
      permissions: _getDefaultPermissions(),
    );
    await _profileBox.put(profileId, updated);
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }

  /// Deaktiviert ein Profil (soft delete)
  /// Das Profil wird ausgeblendet, aber alle Daten bleiben erhalten
  Future<bool> deactivateProfile(String profileId) async {
    if (activeProfile?.isAdmin != true) {
      logger.warning(
        LogCategory.permission,
        'Permission denied: Only admins can deactivate profiles',
        data: {
          'profileId': profileId,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    // Verhindere Deaktivierung des eigenen Profils
    if (profileId == activeProfile?.id) {
      logger.warning(
        LogCategory.permission,
        'Cannot deactivate your own profile',
        data: {'profileId': profileId},
      );
      return false;
    }

    // Verhindere Deaktivierung des letzten Admin-Profils
    final profile = _profileBox.get(profileId);
    if (profile == null) return false;

    if (profile.isAdmin) {
      final adminCount = _profileBox.values
          .where((p) => p.isAdmin && p.isActive)
          .length;
      if (adminCount <= 1) {
        logger.warning(
          LogCategory.permission,
          'Cannot deactivate: At least one active admin must remain',
          data: {'profileId': profileId, 'adminCount': adminCount},
        );
        return false;
      }
    }

    final updated = profile.copyWith(isActive: false);
    await _profileBox.put(profileId, updated);
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }

  /// Reaktiviert ein deaktiviertes Profil
  Future<bool> reactivateProfile(String profileId) async {
    if (activeProfile?.isAdmin != true) {
      logger.warning(
        LogCategory.permission,
        'Permission denied: Only admins can reactivate profiles',
        data: {
          'profileId': profileId,
          'requestingProfile': activeProfile?.id,
        },
      );
      return false;
    }

    final profile = _profileBox.get(profileId);
    if (profile == null) return false;

    final updated = profile.copyWith(isActive: true);
    await _profileBox.put(profileId, updated);
    // Hive notified automatisch alle ValueListenable Listener!

    return true;
  }
}
