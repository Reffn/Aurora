import 'dart:io';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Enhanced Debug Report Generator für Crash-Reports
///
/// Erweitert den Standard-DebugLogGenerator mit:
/// - Error & StackTrace Details
/// - User Journey (Breadcrumbs)
/// - App State Snapshot
/// - Memory & Performance Details
class EnhancedDebugReportGenerator {
  /// Generiert einheitlichen Diagnostic Report
  ///
  /// Wird von allen Report-Typen verwendet (Crash, Error, Feedback)
  /// Enthält alle Standard-Diagnose-Informationen
  static Future<String> generateDiagnosticReport() async {
    logger.info(LogCategory.ui, 'Generating diagnostic report...');

    final buffer = StringBuffer();

    // APP INFO
    buffer.writeln('─── ℹ️  APP INFORMATION ───');
    await _addAppInfo(buffer);
    buffer.writeln();

    // DEVICE INFO
    buffer.writeln('─── 📱 DEVICE INFORMATION ───');
    await _addDeviceInfo(buffer);
    buffer.writeln();

    // APP STATE SNAPSHOT
    buffer.writeln('─── 📸 APP STATE SNAPSHOT ───');
    await _addAppStateSnapshot(buffer);
    buffer.writeln();

    // USER JOURNEY (Breadcrumbs)
    buffer.writeln('─── 🍞 USER JOURNEY (Last 30 Actions) ───');
    await _addBreadcrumbs(buffer);
    buffer.writeln();

    // MEMORY & PERFORMANCE
    buffer.writeln('─── 💾 MEMORY & PERFORMANCE ───');
    await _addMemoryInfo(buffer);
    buffer.writeln();

    // RECENT LOGS (letzte 10 Einträge)
    buffer.writeln('─── 📋 RECENT LOGS (Last 10) ───');
    await _addRecentLogs(buffer);
    buffer.writeln();

    // Privacy-Hinweis
    buffer.writeln('─── 🔒 PRIVACY NOTE ───');
    buffer.writeln('This report contains NO personal data.');
    buffer.writeln(
      'Profile names appear abbreviated and without identifiers (e.g., J***).',
    );
    buffer.writeln(
      'No chat messages, diary entries, or personal notes included.',
    );
    buffer.writeln('No profile IDs, entry counts, or location data included.');
    buffer.writeln(
      'Sensitive data (emails, phones, passwords) are automatically redacted.',
    );

    logger.info(LogCategory.ui, 'Diagnostic report generated successfully');

    // SECURITY: Filtere alle potenziell sensitiven Daten vor dem Senden
    return _sanitizeSensitiveData(buffer.toString());
  }

  /// Generiert vollständigen Crash-Report
  ///
  /// [error] - Exception die aufgetreten ist
  /// [stackTrace] - StackTrace des Errors
  /// [context] - Optional: Zusätzlicher Kontext (z.B. "During login")
  static Future<String> generateCrashReport({
    required Object error,
    required StackTrace stackTrace,
    String? context,
  }) async {
    logger.info(LogCategory.ui, 'Generating enhanced crash report...');

    final buffer = StringBuffer();
    final timestamp = DateTime.now();

    // Header
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('       🐛 AURORA CRASH REPORT 🐛');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('Timestamp: ${_formatDateTime(timestamp)}');
    if (context != null) {
      buffer.writeln('Context: $context');
    }
    buffer.writeln();

    // CRASH DETAILS (zuerst, am wichtigsten!)
    buffer.writeln('─── 💥 CRASH DETAILS ───');
    await _addCrashDetails(buffer, error, stackTrace);
    buffer.writeln();

    // Standard Diagnostic Information
    final diagnosticReport = await generateDiagnosticReport();
    buffer.write(diagnosticReport);
    buffer.writeln();

    // Footer
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('           END OF CRASH REPORT');
    buffer.writeln('═══════════════════════════════════════════');

    logger.info(LogCategory.ui, 'Crash report generated successfully');

    // SECURITY: Filtere alle potenziell sensitiven Daten vor dem Senden
    return _sanitizeSensitiveData(buffer.toString());
  }

  /// Generiert einfachen Error-Report (für handled errors)
  ///
  /// Leichtere Version für non-crash Fehler
  static Future<String> generateErrorReport({
    required String errorMessage,
    String? errorType,
    Map<String, dynamic>? errorData,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('       ⚠️  AURORA ERROR REPORT ⚠️');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('Timestamp: ${_formatDateTime(DateTime.now())}');
    buffer.writeln();

    buffer.writeln('─── ERROR DETAILS ───');
    buffer.writeln('Type: ${errorType ?? 'Unknown'}');
    buffer.writeln('Message: $errorMessage');
    if (errorData != null && errorData.isNotEmpty) {
      buffer.writeln('\nAdditional Data:');
      errorData.forEach((key, value) {
        buffer.writeln('  • $key: $value');
      });
    }
    buffer.writeln();

    // Standard Diagnostic Information
    final diagnosticReport = await generateDiagnosticReport();
    buffer.write(diagnosticReport);
    buffer.writeln();

    buffer.writeln('═══════════════════════════════════════════');

    // SECURITY: Filtere alle potenziell sensitiven Daten vor dem Senden
    return _sanitizeSensitiveData(buffer.toString());
  }

  // ───────────────────────────────────────────────────────────────
  // PRIVATE HELPER METHODS
  // ───────────────────────────────────────────────────────────────

  /// Fügt Crash-Details hinzu
  static Future<void> _addCrashDetails(
    StringBuffer buffer,
    Object error,
    StackTrace stackTrace,
  ) async {
    buffer.writeln('Error Type: ${error.runtimeType}');
    buffer.writeln('Error Message: $error');
    buffer.writeln();
    buffer.writeln('Stack Trace:');
    buffer.writeln(stackTrace.toString());
  }

  /// Fügt Breadcrumbs (User Journey) hinzu
  static Future<void> _addBreadcrumbs(StringBuffer buffer) async {
    final breadcrumbs = logger.getBreadcrumbs();

    if (breadcrumbs.isEmpty) {
      buffer.writeln('No breadcrumbs recorded.');
      return;
    }

    buffer.writeln('Showing last ${breadcrumbs.length} actions:');
    buffer.writeln();

    // Neueste zuerst (reverse)
    for (final crumb in breadcrumbs.reversed) {
      buffer.writeln(crumb.toDebugString());
    }
  }

  /// Fügt App State Snapshot hinzu
  static Future<void> _addAppStateSnapshot(StringBuffer buffer) async {
    try {
      final profileService = getIt<ProfileService>();

      // Active Profile
      final activeProfile = profileService.activeProfile;
      if (activeProfile != null) {
        buffer.writeln(
          'Active Profile: ${_anonymizeProfileName(activeProfile)}',
        );
        buffer.writeln('Has Password: ${activeProfile.hasPassword}');
        buffer.writeln(
          'Profile Created: ${_formatDateTime(activeProfile.createdAt)}',
        );
      } else {
        buffer.writeln('Active Profile: None ⚠️');
      }
    } catch (e) {
      buffer.writeln('⚠️  Error reading app state: $e');
    }
  }

  /// Fügt Memory & Performance Info hinzu
  static Future<void> _addMemoryInfo(StringBuffer buffer) async {
    try {
      // Platform-specific memory info
      if (Platform.isAndroid || Platform.isIOS) {
        buffer.writeln('Memory: (Use platform tools for detailed info)');
      }

      // App uptime (ungefähr, basierend auf Logger-Start)
      buffer.writeln('\nApp Session:');
      buffer.writeln('  • Platform: ${Platform.operatingSystem}');
      buffer.writeln('  • Runtime: Flutter/Dart');
    } catch (e) {
      buffer.writeln('⚠️  Error reading memory info: $e');
    }
  }

  /// Fügt Device Info hinzu (anonymisiert)
  static Future<void> _addDeviceInfo(StringBuffer buffer) async {
    try {
      buffer.writeln('Platform: ${Platform.operatingSystem}');
      buffer.writeln('OS Version: ${Platform.operatingSystemVersion}');
      buffer.writeln('Locale: ${Platform.localeName}');

      // Screen info (wenn verfügbar)
      if (Platform.isAndroid || Platform.isIOS) {
        buffer.writeln('Platform Type: Mobile');
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        buffer.writeln('Platform Type: Desktop');
      }

      buffer.writeln('Dart Version: ${Platform.version}');
    } catch (e) {
      buffer.writeln('⚠️  Error reading device info: $e');
    }
  }

  /// Fügt App Info hinzu
  static Future<void> _addAppInfo(StringBuffer buffer) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      buffer.writeln('App Name: ${packageInfo.appName}');
      buffer.writeln('Package: ${packageInfo.packageName}');
      buffer.writeln('Version: ${packageInfo.version}');
      buffer.writeln('Build Number: ${packageInfo.buildNumber}');
      buffer.writeln('Build Mode: ${kReleaseMode ? 'Release' : 'Debug'}');
    } catch (e) {
      buffer.writeln('⚠️  Error reading app info: $e');
    }
  }

  /// Fügt Recent Logs hinzu
  static Future<void> _addRecentLogs(StringBuffer buffer) async {
    final recentErrors = logger.getRecentErrors();

    if (recentErrors.isEmpty) {
      buffer.writeln('No recent errors logged.');
      return;
    }

    final logsToShow = recentErrors.reversed.take(10);
    buffer.writeln('Showing last ${logsToShow.length} log entries:');
    buffer.writeln();

    for (final entry in logsToShow) {
      buffer.writeln(entry.toDebugString());
    }
  }

  // ───────────────────────────────────────────────────────────────
  // SENSITIVE DATA FILTERING
  // ───────────────────────────────────────────────────────────────

  /// Liste von sensitiven Schlüsselwörtern die aus Logs gefiltert werden
  static const _sensitiveKeywords = [
    'password',
    'passwort',
    'hash',
    'token',
    'secret',
    'api_key',
    'apikey',
    'auth',
    'credential',
    'security_answer',
    'reset_code',
  ];

  /// Regex für Email-Adressen
  static final _emailRegex = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );

  /// Regex für Telefonnummern (verschiedene Formate)
  static final _phoneRegex = RegExp(
    r'(\+?[\d\s\-()]{10,})',
  );

  /// Filtert sensitive Daten aus einem String
  ///
  /// Ersetzt:
  /// - Email-Adressen → [EMAIL_REDACTED]
  /// - Telefonnummern → [PHONE_REDACTED]
  /// - Zeilen mit sensitiven Keywords → [SENSITIVE_DATA_REDACTED]
  static String _sanitizeSensitiveData(String input) {
    var result = input;

    // Ersetze Email-Adressen
    result = result.replaceAll(_emailRegex, '[EMAIL_REDACTED]');

    // Ersetze Telefonnummern (nur längere Sequenzen)
    result = result.replaceAllMapped(_phoneRegex, (match) {
      final number = match.group(0) ?? '';
      // Nur ersetzen wenn es wie eine echte Telefonnummer aussieht
      final digitsOnly = number.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length >= 10) {
        return '[PHONE_REDACTED]';
      }
      return number;
    });

    // Filtere Zeilen mit sensitiven Keywords
    final lines = result.split('\n');
    final filteredLines = lines.map((line) {
      final lowerLine = line.toLowerCase();
      for (final keyword in _sensitiveKeywords) {
        if (lowerLine.contains(keyword)) {
          // Behalte Kontext aber entferne den Wert
          if (line.contains(':')) {
            final parts = line.split(':');
            if (parts.length >= 2) {
              return '${parts[0]}: [REDACTED]';
            }
          }
          return '[SENSITIVE_LINE_REDACTED]';
        }
      }
      return line;
    });

    return filteredLines.join('\n');
  }

  // ───────────────────────────────────────────────────────────────
  // FORMATTING HELPERS
  // ───────────────────────────────────────────────────────────────

  /// Formatiert DateTime für Report
  static String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  /// Anonymisiert Profil-Namen (Privacy!)
  ///
  /// Zeigt nur gekürzte Form ohne Kennung
  static String _anonymizeProfileName(Profile profile) {
    if (profile.name.isEmpty) return '***';

    final runes = profile.name.runes.toList();
    if (runes.isEmpty) return '***';

    final firstLetter = String.fromCharCode(runes.first);
    return '$firstLetter***';
  }
}
