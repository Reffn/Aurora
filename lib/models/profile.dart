import 'dart:convert';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/permission.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

part 'profile.g.dart';

/// Profil Model für Anteile
/// Mit Role-Based Access Control (RBAC)
@HiveType(typeId: 0)
class Profile {
  Profile({
    required this.id,
    required this.nameRaw,
    required this.preferredColorValue,
    required this.createdAt,
    this.avatarPath,
    this.age,
    this.description,
    this.isAdmin = false,
    this.permissions = const [],
    this.preferredLanguage,
    this.isActive = true,
    this.passwordHash,
    this.resetCode,
    this.pendingPasswordHash,
    this.securityQuestions,
    this.securityAnswersHashed,
    this.hasSeenPostLoginWelcome = false,
    this.colorPickerPositionX,
    this.colorPickerPositionY,
    this.resetStartedAt,
    this.resetEndsAt,
    this.resetDurationHours,
  });

  /// Constructor mit Color als Parameter (für UI-Code)
  factory Profile.withColor({
    required String id,
    required String name,
    required Color preferredColor,
    required DateTime createdAt,
    String? avatarPath,
    int? age,
    String? description,
    bool isAdmin = false,
    List<String> permissions = const [],
    String? preferredLanguage,
    bool isActive = true,
    String? passwordHash,
    String? resetCode,
    String? pendingPasswordHash,
    List<String>? securityQuestions,
    List<String>? securityAnswersHashed,
    bool hasSeenPostLoginWelcome = false,
    double? colorPickerPositionX,
    double? colorPickerPositionY,
    DateTime? resetStartedAt,
    DateTime? resetEndsAt,
    int? resetDurationHours,
  }) {
    return Profile(
      id: id,
      nameRaw: name,
      avatarPath: avatarPath,
      preferredColorValue: preferredColor.toARGB32(),
      age: age,
      description: description,
      createdAt: createdAt,
      isAdmin: isAdmin,
      permissions: permissions,
      preferredLanguage: preferredLanguage,
      isActive: isActive,
      passwordHash: passwordHash,
      resetCode: resetCode,
      pendingPasswordHash: pendingPasswordHash,
      securityQuestions: securityQuestions,
      securityAnswersHashed: securityAnswersHashed,
      hasSeenPostLoginWelcome: hasSeenPostLoginWelcome,
      colorPickerPositionX: colorPickerPositionX,
      colorPickerPositionY: colorPickerPositionY,
      resetStartedAt: resetStartedAt,
      resetEndsAt: resetEndsAt,
      resetDurationHours: resetDurationHours,
    );
  }

  /// Von Map erstellen (Legacy - für Kompatibilität)
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      nameRaw: map['name'] as String,
      avatarPath: map['avatar_path'] as String?,
      preferredColorValue: map['preferred_color'] as int,
      age: map['age'] as int?,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      isAdmin: map['is_admin'] as bool? ?? false,
      permissions: (map['permissions'] as List?)?.cast<String>() ?? [],
      preferredLanguage: map['preferred_language'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      passwordHash: map['password_hash'] as String?,
      resetCode: map['reset_code'] as String?,
      pendingPasswordHash: map['pending_password_hash'] as String?,
      securityQuestions: (map['security_questions'] as List?)?.cast<String>(),
      securityAnswersHashed: (map['security_answers_hashed'] as List?)
          ?.cast<String>(),
      hasSeenPostLoginWelcome:
          map['has_seen_post_login_welcome'] as bool? ?? false,
      colorPickerPositionX: map['color_picker_position_x'] != null
          ? (map['color_picker_position_x'] as num).toDouble()
          : null,
      colorPickerPositionY: map['color_picker_position_y'] != null
          ? (map['color_picker_position_y'] as num).toDouble()
          : null,
      resetStartedAt: map['reset_started_at'] != null
          ? DateTime.parse(map['reset_started_at'] as String)
          : null,
      resetEndsAt: map['reset_ends_at'] != null
          ? DateTime.parse(map['reset_ends_at'] as String)
          : null,
      resetDurationHours: map['reset_duration_hours'] as int?,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nameRaw;

  @HiveField(2)
  final String? avatarPath;

  /// Public getter für Name mit UTF-16 Normalisierung
  /// Normalisiert den String mit Dart's runes API - erhält Emojis und gültige Unicode-Zeichen
  String get name {
    // Dart's runes API normalisiert automatisch und entfernt nur wirklich ungültige Zeichen
    // Emojis wie 😅 werden korrekt erhalten
    final sanitized = String.fromCharCodes(nameRaw.runes);

    // DEBUG: Log wenn Normalisierung notwendig war
    if (sanitized != nameRaw) {
      logger.warning(
        LogCategory.hive,
        'Profile.name getter: Normalized UTF-16 string',
        data: {
          'profile_id': id,
          'raw_name': nameRaw,
          'raw_name_length': nameRaw.length,
          'sanitized_name_length': sanitized.length,
          'raw_codeunits': nameRaw.codeUnits.toString(),
          'sanitized_codeunits': sanitized.codeUnits.toString(),
        },
      );
    }

    return sanitized;
  }

  @HiveField(3)
  final int preferredColorValue;

  @HiveField(4)
  final int? age;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final DateTime createdAt;

  /// Ob dieses Profil Administrator ist (hat alle Rechte)
  @HiveField(7, defaultValue: false)
  final bool isAdmin;

  /// Liste der Berechtigungen (als String-Namen gespeichert für Hive)
  @HiveField(8, defaultValue: <String>[])
  final List<String> permissions;

  /// Die Sprache dieses Anteils, z. B. `de` oder `es` (ISO 639-1).
  ///
  /// Nicht jeder im System spricht dieselbe Sprache — bei DIS ist das der
  /// Normalfall, nicht die Ausnahme. Deshalb hängt die Sprache am Anteil und
  /// nicht an der App: wer sich anmeldet, findet seine Sprache vor, ohne sie
  /// jedes Mal umzustellen.
  ///
  /// `null` heißt: der App-weiten Einstellung folgen. Profile, die es vor
  /// dieser Auswertung schon gab, verhalten sich damit unverändert.
  @HiveField(9)
  final String? preferredLanguage;

  /// Ob dieses Profil aktiv ist (deaktivierte Profile werden ausgeblendet)
  @HiveField(10, defaultValue: true)
  final bool isActive;

  /// Passwort-Hash (SHA-256) für Profil-Schutz
  /// Null = kein Passwort gesetzt
  @HiveField(11)
  final String? passwordHash;

  /// Reset-Code für Passwort-Wiederherstellung
  /// Format: "ABC-123" (6 Zeichen mit Bindestrich)
  @Deprecated(
    'Wissensfaktoren entfernt - Feld bleibt nur fuer Hive-Kompatibilitaet',
  )
  @HiveField(12)
  final String? resetCode;

  /// Pending Passwort-Hash während Passwort-Reset läuft
  /// Wird nach Ablauf des 24h-Timers zu passwordHash verschoben
  @HiveField(13)
  final String? pendingPasswordHash;

  /// Sicherheitsfragen für Passwort-Wiederherstellung (genau 3 Fragen)
  @Deprecated(
    'Wissensfaktoren entfernt - Feld bleibt nur fuer Hive-Kompatibilitaet',
  )
  @HiveField(14)
  final List<String>? securityQuestions;

  /// Gehashte Antworten auf die Sicherheitsfragen (genau 3 Antworten, SHA-256)
  @Deprecated(
    'Wissensfaktoren entfernt - Feld bleibt nur fuer Hive-Kompatibilitaet',
  )
  @HiveField(15)
  final List<String>? securityAnswersHashed;

  /// Hat dieses Profil die Post-Login Welcome Screens bereits gesehen?
  /// (Stage 3 des Onboarding Systems)
  @HiveField(16, defaultValue: false)
  final bool hasSeenPostLoginWelcome;

  /// Normalisierte X-Position im ColorWheelPicker (0.0-1.0)
  /// Null für alte Profile (werden zu 0.5 migriert)
  @HiveField(17)
  final double? colorPickerPositionX;

  /// Normalisierte Y-Position im ColorWheelPicker (0.0-1.0)
  /// Null für alte Profile (werden zu 0.5 migriert)
  @HiveField(18)
  final double? colorPickerPositionY;

  /// Zeitstempel wann Passwort-Reset gestartet wurde
  @HiveField(19)
  final DateTime? resetStartedAt;

  /// Zeitstempel wann Passwort-Reset abläuft (eingefrorener Endzeitpunkt beim Start)
  @HiveField(20)
  final DateTime? resetEndsAt;

  /// Dauer des Passwort-Reset in Stunden (Einstellung des Anteils, null ⇒ 24h)
  @HiveField(21)
  final int? resetDurationHours;

  /// Computed property für Flutter Color
  Color get preferredColor => Color(preferredColorValue);

  /// Computed property für normalisierte ColorPicker Position
  /// Gibt Offset zurück falls beide X und Y gesetzt sind
  Offset? get colorPickerPositionNormalized {
    if (colorPickerPositionX == null || colorPickerPositionY == null)
      return null;
    return Offset(colorPickerPositionX!, colorPickerPositionY!);
  }

  /// Ist dieses Profil deaktiviert?
  bool get isDeactivated => !isActive;

  /// Parsed Permissions (von String zu Permission Enum)
  List<Permission> get parsedPermissions {
    return permissions
        .map(Permission.fromString)
        .whereType<Permission>() // Filtert nulls
        .toList();
  }

  /// Prüft ob dieses Profil eine bestimmte Berechtigung hat
  /// Admin-Profile haben IMMER alle Rechte
  bool hasPermission(Permission permission) {
    if (isAdmin) return true; // Admin hat alles
    return permissions.contains(permission.persistedValue);
  }

  /// Prüft ob dieses Profil ALLE angegebenen Berechtigungen hat
  bool hasAllPermissions(List<Permission> requiredPermissions) {
    if (isAdmin) return true;
    return requiredPermissions.every(hasPermission);
  }

  /// Prüft ob dieses Profil mindestens EINE der angegebenen Berechtigungen hat
  bool hasAnyPermission(List<Permission> requiredPermissions) {
    if (isAdmin) return true;
    return requiredPermissions.any(hasPermission);
  }

  // ========== Passwort-Verwaltung ==========

  /// Hat dieses Profil ein Passwort gesetzt?
  bool get hasPassword => passwordHash != null;

  /// Hat dieses Profil ein pending Passwort (während Reset-Timer läuft)?
  /// Leerer String wird wie null behandelt (Altlast)
  bool get hasPendingPassword =>
      pendingPasswordHash != null && pendingPasswordHash!.isNotEmpty;

  /// Läuft gerade ein Passwort-Reset für dieses Profil?
  /// True wenn Start und Ende beide gesetzt sind
  bool get hasActiveReset => resetStartedAt != null && resetEndsAt != null;

  /// Ist der Passwort-Reset abgelaufen?
  /// True wenn Reset aktiv ist und now >= resetEndsAt
  bool get isResetExpired {
    if (!hasActiveReset) return false;
    return !DateTime.now().isBefore(resetEndsAt!);
  }

  // ============================================================================
  // PASSWORD HASHING (bcrypt mit Salt)
  // ============================================================================

  /// Prüft ob ein Hash im bcrypt-Format vorliegt (beginnt mit $2a$ oder $2b$)
  static bool _isBcryptHash(String hash) {
    return hash.startsWith(r'$2a$') || hash.startsWith(r'$2b$');
  }

  /// Hash-Funktion für Passwörter (bcrypt mit automatischem Salt)
  ///
  /// bcrypt ist sicherer als SHA-256 weil:
  /// - Automatisches Salt (verhindert Rainbow Tables)
  /// - Konfigurierbare Kosten (langsamer = sicherer gegen Brute-Force)
  /// - Salt ist im Hash enthalten (kein separates Speichern nötig)
  static String hashPassword(String plainPassword) {
    // Cost factor 12 = 2^12 = 4096 Iterationen (guter Kompromiss)
    final salt = BCrypt.gensalt(logRounds: 12);
    return BCrypt.hashpw(plainPassword, salt);
  }

  /// Legacy SHA-256 Hash (nur für Migration alter Passwörter)
  static String _legacyHashPassword(String plainPassword) {
    final bytes = utf8.encode(plainPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Prüft ob das eingegebene Passwort korrekt ist
  ///
  /// Unterstützt sowohl bcrypt (neu) als auch SHA-256 (legacy).
  /// Bei erfolgreicher Verifikation eines Legacy-Hashes wird `needsHashUpgrade`
  /// true zurückgegeben, damit der Caller den Hash upgraden kann.
  bool verifyPassword(String plainPassword) {
    if (!hasPassword) return true; // Kein Passwort gesetzt = immer korrekt

    final hash = passwordHash!;

    if (_isBcryptHash(hash)) {
      // Neuer bcrypt Hash
      return BCrypt.checkpw(plainPassword, hash);
    } else {
      // Legacy SHA-256 Hash - Verifikation mit altem Algorithmus
      return _legacyHashPassword(plainPassword) == hash;
    }
  }

  /// Prüft ob der gespeicherte Passwort-Hash ein Legacy-Format hat
  /// und auf bcrypt upgradet werden sollte
  bool get needsPasswordHashUpgrade {
    if (!hasPassword) return false;
    return !_isBcryptHash(passwordHash!);
  }

  /// Generiert einen 6-stelligen Reset-Code (Format: ABC-123)
  /// Verwendet Großbuchstaben und Zahlen für bessere Lesbarkeit
  static String generateResetCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // Ohne I,O (verwechselbar)
    const numbers = '23456789'; // Ohne 0,1 (verwechselbar)
    final random = Random.secure();

    final part1 = List.generate(
      3,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    final part2 = List.generate(
      3,
      (_) => numbers[random.nextInt(numbers.length)],
    ).join();

    return '$part1-$part2';
  }

  /// Zu Map konvertieren (Legacy - für Kompatibilität)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': nameRaw, // Raw name ohne Sanitization
      'avatar_path': avatarPath,
      'preferred_color': preferredColorValue,
      'age': age,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'is_admin': isAdmin,
      'permissions': permissions,
      'preferred_language': preferredLanguage,
      'is_active': isActive,
      'password_hash': passwordHash,
      'reset_code': resetCode,
      'pending_password_hash': pendingPasswordHash,
      'security_questions': securityQuestions,
      'security_answers_hashed': securityAnswersHashed,
      'has_seen_post_login_welcome': hasSeenPostLoginWelcome,
      'color_picker_position_x': colorPickerPositionX,
      'color_picker_position_y': colorPickerPositionY,
      'reset_started_at': resetStartedAt?.toIso8601String(),
      'reset_ends_at': resetEndsAt?.toIso8601String(),
      'reset_duration_hours': resetDurationHours,
    };
  }

  /// Kopie mit geänderten Werten erstellen
  Profile copyWith({
    String? id,
    String? name,
    String? avatarPath,
    Color? preferredColor,
    int? age,
    String? description,
    DateTime? createdAt,
    bool? isAdmin,
    List<String>? permissions,
    String? preferredLanguage,

    /// Setzt [preferredLanguage] auf `null` zurück — „der App folgen".
    ///
    /// Ohne diesen Schalter liesse sich eine einmal gewählte Sprache nie
    /// wieder abwählen: `copyWith` kann `null` nicht von „nicht angegeben"
    /// unterscheiden.
    bool clearPreferredLanguage = false,
    bool? isActive,
    String? passwordHash,
    String? resetCode,
    String? pendingPasswordHash,
    List<String>? securityQuestions,
    List<String>? securityAnswersHashed,
    bool? hasSeenPostLoginWelcome,
    double? colorPickerPositionX,
    double? colorPickerPositionY,
    DateTime? resetStartedAt,
    DateTime? resetEndsAt,
    int? resetDurationHours,
  }) {
    return Profile(
      id: id ?? this.id,
      nameRaw: name ?? nameRaw, // Verwende raw name
      avatarPath: avatarPath ?? this.avatarPath,
      preferredColorValue: preferredColor?.toARGB32() ?? preferredColorValue,
      age: age ?? this.age,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
      permissions: permissions ?? this.permissions,
      preferredLanguage: clearPreferredLanguage
          ? null
          : (preferredLanguage ?? this.preferredLanguage),
      isActive: isActive ?? this.isActive,
      passwordHash: passwordHash ?? this.passwordHash,
      resetCode: resetCode ?? this.resetCode,
      pendingPasswordHash: pendingPasswordHash ?? this.pendingPasswordHash,
      securityQuestions: securityQuestions ?? this.securityQuestions,
      securityAnswersHashed:
          securityAnswersHashed ?? this.securityAnswersHashed,
      hasSeenPostLoginWelcome:
          hasSeenPostLoginWelcome ?? this.hasSeenPostLoginWelcome,
      colorPickerPositionX: colorPickerPositionX ?? this.colorPickerPositionX,
      colorPickerPositionY: colorPickerPositionY ?? this.colorPickerPositionY,
      resetStartedAt: resetStartedAt ?? this.resetStartedAt,
      resetEndsAt: resetEndsAt ?? this.resetEndsAt,
      resetDurationHours: resetDurationHours ?? this.resetDurationHours,
    );
  }
}
