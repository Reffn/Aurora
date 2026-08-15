import 'dart:io';
import 'package:flutter/foundation.dart';

/// Log-Level für strukturiertes Logging
enum LogLevel {
  debug, // Entwicklung: Detaillierte Debug-Info
  info, // Normal: Wichtige Events
  warning, // Warnung: Potenzielle Probleme
  error, // Fehler: Recoverable Errors
  critical, // Kritisch: App-breaking Errors
}

/// Log-Kategorien für bessere Filterung
enum LogCategory {
  ui, // UI-Events (Screen-Lifecycle, User-Actions)
  service, // Service-Layer (Business Logic)
  dataEntry, // API-Layer (Commands & Queries)
  eventBus, // EventBus-Events
  hive, // Hive-Operationen (Persistierung)
  network, // Network-Requests (zukünftig)
  permission, // Permission-Checks
  navigation, // Navigation-Events
}

/// Log-Eintrag für Circular Buffer (Debug Report)
class LogEntry {
  LogEntry({
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.data,
  });

  final DateTime timestamp;
  final LogLevel level;
  final LogCategory category;
  final String message;
  final Map<String, dynamic>? data;

  /// Formatiert Log-Eintrag für Debug-Report (anonym)
  String toDebugString() {
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
    final levelIcon = AppLogger._icons[level] ?? '';
    final dataStr = data != null && data!.isNotEmpty ? ' | Data: $data' : '';
    return '[$time] $levelIcon ${level.name.toUpperCase()} [${category.name}] $message$dataStr';
  }
}

/// Breadcrumb für User-Journey-Tracking (Error-Diagnose)
///
/// Breadcrumbs tracken User-Actions wie Screen-Navigation, Button-Klicks, etc.
/// Sie helfen dabei, den Weg zum Fehler nachzuvollziehen.
class Breadcrumb {
  Breadcrumb({
    required this.timestamp,
    required this.type,
    required this.message,
    this.data,
  });

  final DateTime timestamp;
  final BreadcrumbType type;
  final String message;
  final Map<String, dynamic>? data;

  /// Formatiert Breadcrumb für Debug-Report
  String toDebugString() {
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
    final icon = _icons[type] ?? '•';
    final dataStr = data != null && data!.isNotEmpty ? ' | $data' : '';
    return '[$time] $icon ${type.name}: $message$dataStr';
  }

  static const _icons = {
    BreadcrumbType.navigation: '🧭',
    BreadcrumbType.user: '👆',
    BreadcrumbType.state: '🔄',
    BreadcrumbType.network: '🌐',
    BreadcrumbType.system: '⚙️',
  };
}

/// Breadcrumb-Typen für bessere Kategorisierung
enum BreadcrumbType {
  navigation, // Screen-Wechsel, Route-Changes
  user, // User-Actions (Button-Klicks, Input)
  state, // State-Änderungen (Profile wechseln, etc.)
  network, // Network-Requests
  system, // System-Events (App-Lifecycle, etc.)
}

/// Strukturiertes Logging-System mit Level und Category
///
/// Beispiel:
/// ```dart
/// logger.info(LogCategory.dataEntry, 'User logged in', data: {'userId': '123'});
/// logger.error(LogCategory.service, 'Failed to load data', data: {'error': e.toString()}, stackTrace: trace);
///
/// // Performance-Tracking:
/// await logger.track('loadProfile', LogCategory.service, () async {
///   return await profileService.load();
/// });
/// ```
class AppLogger {
  factory AppLogger() => _instance;
  AppLogger._internal();
  static final AppLogger _instance = AppLogger._internal();

  /// Production-Mode: Nur Warning+ loggen
  bool _isProduction = false;

  /// Optional: In Datei schreiben
  bool _writeToFile = false;
  String _logFilePath = '';

  /// Circular Buffer für Recent Errors (Debug Report)
  /// Speichert letzte 50 Warnings/Errors/Critical Logs
  final List<LogEntry> _recentErrors = [];
  static const int _maxRecentErrors = 50;

  /// Circular Buffer für Breadcrumbs (User Journey)
  /// Speichert letzte 30 User-Actions für Error-Diagnose
  final List<Breadcrumb> _breadcrumbs = [];
  static const int _maxBreadcrumbs = 30;

  /// Log-Level Icons für bessere Lesbarkeit
  static const _icons = {
    LogLevel.debug: '🔍',
    LogLevel.info: 'ℹ️',
    LogLevel.warning: '⚠️',
    LogLevel.error: '❌',
    LogLevel.critical: '🔥',
  };

  /// Category Colors (ANSI-Codes für Terminal)
  static const _categoryColors = {
    LogCategory.ui: '\x1B[36m', // Cyan
    LogCategory.service: '\x1B[35m', // Magenta
    LogCategory.dataEntry: '\x1B[32m', // Green
    LogCategory.eventBus: '\x1B[33m', // Yellow
    LogCategory.hive: '\x1B[34m', // Blue
    LogCategory.network: '\x1B[37m', // White
    LogCategory.permission: '\x1B[31m', // Red
    LogCategory.navigation: '\x1B[90m', // Gray
  };

  static const _reset = '\x1B[0m';

  /// Haupt-Log-Methode
  ///
  /// [level] - Log-Level (debug, info, warning, error, critical)
  /// [category] - Kategorie für Filterung
  /// [message] - Log-Nachricht
  /// [data] - Optional: Zusätzliche Daten als Map
  /// [stackTrace] - Optional: StackTrace bei Fehlern
  void log(
    LogLevel level,
    LogCategory category,
    String message, {
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) {
    // Production: Nur Warning+ loggen
    if (_isProduction &&
        level != LogLevel.warning &&
        level != LogLevel.error &&
        level != LogLevel.critical) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final icon = _icons[level] ?? '';
    final color = _categoryColors[category] ?? '';

    // Format: [Timestamp] Icon [Level] [Category] Message
    final logLine =
        '[$timestamp] $icon [${level.name.toUpperCase()}] '
        '$color[${category.name.toUpperCase()}]$_reset $message';

    // Console-Output
    debugPrint(logLine);

    // Data ausgeben (wenn vorhanden)
    if (data != null && data.isNotEmpty) {
      debugPrint('  └─ Data: $data');
    }

    // StackTrace bei Errors
    if (stackTrace != null &&
        (level == LogLevel.error || level == LogLevel.critical)) {
      debugPrint('  └─ StackTrace:\n$stackTrace');
    }

    // Optional: In Datei schreiben
    if (_writeToFile) {
      _writeToLogFile(logLine, data, stackTrace);
    }

    // Speichere Warning/Error/Critical im Circular Buffer für Debug Report
    if (level == LogLevel.warning ||
        level == LogLevel.error ||
        level == LogLevel.critical) {
      _addToRecentErrors(level, category, message, data);
    }
  }

  /// Fügt Eintrag zu Recent Errors Buffer hinzu (Circular Buffer)
  void _addToRecentErrors(
    LogLevel level,
    LogCategory category,
    String message,
    Map<String, dynamic>? data,
  ) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      category: category,
      message: message,
      data: data,
    );

    _recentErrors.add(entry);

    // Circular Buffer: Entferne älteste Einträge
    if (_recentErrors.length > _maxRecentErrors) {
      _recentErrors.removeAt(0);
    }
  }

  /// Gibt Recent Errors für Debug Report zurück
  List<LogEntry> getRecentErrors() {
    return List.unmodifiable(_recentErrors);
  }

  /// Fügt Breadcrumb hinzu (User-Journey-Tracking)
  ///
  /// Beispiel:
  /// ```dart
  /// logger.breadcrumb(
  ///   BreadcrumbType.navigation,
  ///   'Navigated to ChatScreen',
  /// );
  ///
  /// logger.breadcrumb(
  ///   BreadcrumbType.user,
  ///   'Tapped send button',
  ///   data: {'messageLength': 42},
  /// );
  ///
  /// logger.breadcrumb(
  ///   BreadcrumbType.state,
  ///   'Switched profile',
  ///   data: {'profileId': '123'},
  /// );
  /// ```
  void breadcrumb(
    BreadcrumbType type,
    String message, {
    Map<String, dynamic>? data,
  }) {
    final crumb = Breadcrumb(
      timestamp: DateTime.now(),
      type: type,
      message: message,
      data: data,
    );

    _breadcrumbs.add(crumb);

    // Circular Buffer: Entferne älteste Einträge
    if (_breadcrumbs.length > _maxBreadcrumbs) {
      _breadcrumbs.removeAt(0);
    }

    // Optional: Debug-Output in Development
    if (!_isProduction) {
      debugPrint('🍞 [BREADCRUMB] ${crumb.toDebugString()}');
    }
  }

  /// Gibt Breadcrumbs für Debug Report zurück
  List<Breadcrumb> getBreadcrumbs() {
    return List.unmodifiable(_breadcrumbs);
  }

  /// Debug-Level Log (nur in Development)
  ///
  /// Beispiel:
  /// ```dart
  /// logger.debug(LogCategory.ui, 'ChatScreen initialized');
  /// ```
  void debug(
    LogCategory category,
    String message, {
    Map<String, dynamic>? data,
  }) {
    log(LogLevel.debug, category, message, data: data);
  }

  /// Info-Level Log (wichtige Events)
  ///
  /// Beispiel:
  /// ```dart
  /// logger.info(LogCategory.dataEntry, 'User logged in', data: {'userId': '123'});
  /// ```
  void info(
    LogCategory category,
    String message, {
    Map<String, dynamic>? data,
  }) {
    log(LogLevel.info, category, message, data: data);
  }

  /// Warning-Level Log (potenzielle Probleme)
  ///
  /// Beispiel:
  /// ```dart
  /// logger.warning(LogCategory.dataEntry, 'Validation failed', data: {'field': 'email'});
  /// ```
  void warning(
    LogCategory category,
    String message, {
    Map<String, dynamic>? data,
  }) {
    log(LogLevel.warning, category, message, data: data);
  }

  /// Error-Level Log (recoverable Errors)
  ///
  /// Beispiel:
  /// ```dart
  /// try {
  ///   await service.load();
  /// } catch (e, stackTrace) {
  ///   logger.error(
  ///     LogCategory.service,
  ///     'Failed to load data',
  ///     data: {'error': e.toString()},
  ///     stackTrace: stackTrace,
  ///   );
  /// }
  /// ```
  void error(
    LogCategory category,
    String message, {
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) {
    log(LogLevel.error, category, message, data: data, stackTrace: stackTrace);
  }

  /// Critical-Level Log (app-breaking Errors)
  ///
  /// Beispiel:
  /// ```dart
  /// logger.critical(
  ///   LogCategory.hive,
  ///   'Database corruption detected',
  ///   data: {'boxName': 'profiles'},
  ///   stackTrace: stackTrace,
  /// );
  /// ```
  void critical(
    LogCategory category,
    String message, {
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.critical,
      category,
      message,
      data: data,
      stackTrace: stackTrace,
    );
  }

  /// Performance-Tracking für Operations
  ///
  /// Misst Execution-Time und loggt Ergebnis.
  ///
  /// Beispiel:
  /// ```dart
  /// final profile = await logger.track(
  ///   'loadUserProfile',
  ///   LogCategory.service,
  ///   () => profileService.load(userId),
  /// );
  /// ```
  ///
  /// Output:
  /// ```
  /// ℹ️ [INFO] [SERVICE] Starting: loadUserProfile
  /// ℹ️ [INFO] [SERVICE] Completed: loadUserProfile
  ///   └─ Data: {duration_ms: 45}
  /// ```
  Future<T> track<T>(
    String operation,
    LogCategory category,
    Future<T> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();

    info(category, 'Starting: $operation');

    try {
      final result = await action();
      stopwatch.stop();

      info(
        category,
        'Completed: $operation',
        data: {'duration_ms': stopwatch.elapsedMilliseconds},
      );

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();

      error(
        category,
        'Failed: $operation',
        data: {
          'duration_ms': stopwatch.elapsedMilliseconds,
          'error': e.toString(),
        },
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  /// Synchrones Performance-Tracking für nicht-async Operations
  ///
  /// Beispiel:
  /// ```dart
  /// final result = logger.trackSync(
  ///   'calculateResult',
  ///   LogCategory.service,
  ///   () => expensiveCalculation(),
  /// );
  /// ```
  T trackSync<T>(
    String operation,
    LogCategory category,
    T Function() action,
  ) {
    final stopwatch = Stopwatch()..start();

    debug(category, 'Starting: $operation');

    try {
      final result = action();
      stopwatch.stop();

      debug(
        category,
        'Completed: $operation',
        data: {'duration_ms': stopwatch.elapsedMilliseconds},
      );

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();

      error(
        category,
        'Failed: $operation',
        data: {
          'duration_ms': stopwatch.elapsedMilliseconds,
          'error': e.toString(),
        },
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  /// Production-Mode aktivieren (nur Warning+ loggen)
  ///
  /// Sollte in main.dart basierend auf dart.vm.product gesetzt werden:
  /// ```dart
  /// final isProduction = const bool.fromEnvironment('dart.vm.product');
  /// logger.setProduction(isProduction);
  /// ```
  void setProduction(bool isProduction) {
    _isProduction = isProduction;
    info(
      LogCategory.ui,
      'Logger mode: ${isProduction ? 'Production' : 'Development'}',
    );
  }

  /// File-Logging aktivieren (optional)
  ///
  /// Beispiel:
  /// ```dart
  /// final appDir = await getApplicationDocumentsDirectory();
  /// logger.enableFileLogging('${appDir.path}/logs/app.log');
  /// ```
  void enableFileLogging(String filePath) {
    _writeToFile = true;
    _logFilePath = filePath;
    info(LogCategory.ui, 'File logging enabled', data: {'path': filePath});
  }

  /// Schreibt Log-Eintrag in Datei
  Future<void> _writeToLogFile(
    String logLine,
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  ) async {
    if (_logFilePath.isEmpty) return;

    try {
      final file = File(_logFilePath);

      // Erstelle Datei + Verzeichnis falls nicht vorhanden
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      // Append log line
      final buffer = StringBuffer()..writeln(logLine);

      if (data != null && data.isNotEmpty) {
        buffer.writeln('  └─ Data: $data');
      }

      if (stackTrace != null) {
        buffer.writeln('  └─ StackTrace:');
        buffer.writeln(stackTrace);
      }

      await file.writeAsString(
        buffer.toString(),
        mode: FileMode.append,
      );
    } catch (e) {
      // Logging-Fehler nicht propagieren
      debugPrint('⚠️ Failed to write to log file: $e');
    }
  }
}

/// Globale Logger-Instanz für einfachen Zugriff
///
/// Verwendung:
/// ```dart
/// logger.info(LogCategory.ui, 'App started');
/// logger.error(LogCategory.service, 'Failed', data: {'error': e.toString()});
/// ```
final logger = AppLogger();
