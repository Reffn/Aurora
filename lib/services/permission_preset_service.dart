import 'dart:convert';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/permission.dart';
import 'package:flutter/services.dart';

/// Service zum Laden und Verwalten von Permission Presets aus JSON
/// Ermöglicht einfache Anpassung von Berechtigungssets ohne Code-Änderungen
class PermissionPresetService {
  Map<String, PermissionPreset>? _presets;

  /// Lädt Permission Presets aus JSON-Datei
  Future<void> initialize() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/config/permission_presets.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final presetsData = jsonData['presets'] as Map<String, dynamic>;

      _presets = {};
      for (final entry in presetsData.entries) {
        final presetData = entry.value as Map<String, dynamic>;
        _presets![entry.key] = PermissionPreset.fromJson(
          entry.key,
          presetData,
        );
      }

      logger.info(
        LogCategory.service,
        'PermissionPresetService initialized',
        data: {'presetCount': _presets!.length},
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Failed to load permission presets: $e',
        stackTrace: stackTrace,
      );
      // Fallback: Leere Map statt null
      _presets = {};
    }
  }

  /// Gibt ein Preset nach Name zurück
  PermissionPreset? getPreset(String name) {
    if (_presets == null) {
      logger.warning(
        LogCategory.service,
        'PermissionPresetService not initialized',
      );
      return null;
    }
    return _presets![name];
  }

  /// Gibt alle verfügbaren Preset-Namen zurück
  List<String> getPresetNames() {
    return _presets?.keys.toList() ?? [];
  }

  /// Gibt alle Presets zurück
  Map<String, PermissionPreset> getAllPresets() {
    return _presets ?? {};
  }

  /// Gibt Permission-Liste für ein Preset zurück
  List<String> getPermissionsForPreset(String presetName) {
    final preset = getPreset(presetName);
    if (preset == null) {
      logger.warning(
        LogCategory.service,
        'Preset not found: $presetName',
      );
      return [];
    }

    // Spezialfall: "ALL" bedeutet alle Permissions
    if (preset.permissions == 'ALL') {
      return Permission.values.map((p) => p.persistedValue).toList();
    }

    return preset.permissionsList;
  }
}

/// Repräsentiert ein Permission Preset
class PermissionPreset {
  PermissionPreset({
    required this.key,
    required this.name,
    required this.description,
    required this.permissions,
  });

  factory PermissionPreset.fromJson(String key, Map<String, dynamic> json) {
    final permissions = json['permissions'];

    return PermissionPreset(
      key: key,
      name: json['name'] as String,
      description: json['description'] as String,
      permissions: permissions is String
          ? permissions // "ALL" Case
          : (permissions as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  final String key;
  final String name;
  final String description;
  final dynamic permissions; // String "ALL" oder List<String>

  /// Gibt Permissions als Liste zurück
  List<String> get permissionsList {
    if (permissions is String && permissions == 'ALL') {
      return Permission.values.map((p) => p.persistedValue).toList();
    }
    return permissions as List<String>;
  }
}
