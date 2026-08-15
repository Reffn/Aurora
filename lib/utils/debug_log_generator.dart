import 'dart:async';
import 'dart:io';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/calendar_service.dart';
import 'package:dis_app/services/chat_service.dart';
import 'package:dis_app/services/contact_service.dart';
import 'package:dis_app/services/diary_service.dart';
import 'package:dis_app/services/finder_service.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:dis_app/services/medication_service.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Debug-Log Generator für Diagnose & Support
///
/// Sammelt umfassende System-Informationen und erstellt
/// einen formatierten Debug-Report, den User kopieren/teilen können.
class DebugLogGenerator {
  /// Generiert vollständigen Debug-Report
  static Future<String> generateFullReport() async {
    logger.info(LogCategory.ui, 'Generating debug log report...');

    final buffer = StringBuffer();
    final timestamp = DateTime.now();

    // Header
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('       AURORA DEBUG LOG REPORT');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('Erstellt: ${_formatDateTime(timestamp)}');
    buffer.writeln();

    // System Info
    buffer.writeln('─── SYSTEM INFORMATION ───');
    await _addSystemInfo(buffer);
    buffer.writeln();

    // App Info
    buffer.writeln('─── APP INFORMATION ───');
    await _addAppInfo(buffer);
    buffer.writeln();

    // Performance Metrics
    buffer.writeln('─── PERFORMANCE METRICS ───');
    await _addPerformanceMetrics(buffer);
    buffer.writeln();

    // Recent Errors (WICHTIG für Diagnose)
    buffer.writeln('─── RECENT ERRORS & WARNINGS ───');
    await _addRecentErrors(buffer);
    buffer.writeln();

    // Permissions
    buffer.writeln('─── PERMISSIONS STATUS ───');
    await _addPermissionsStatus(buffer);
    buffer.writeln();

    // GPS & Location Tracking
    buffer.writeln('─── GPS & LOCATION TRACKING ───');
    await _addGpsLocationTracking(buffer);
    buffer.writeln();

    // Database Status
    buffer.writeln('─── DATABASE STATUS ───');
    await _addDatabaseStatus(buffer);
    buffer.writeln();

    // Storage Health
    buffer.writeln('─── STORAGE HEALTH ───');
    await _addStorageHealth(buffer);
    buffer.writeln();

    // Services Status
    buffer.writeln('─── SERVICES STATUS ───');
    await _addServicesStatus(buffer);
    buffer.writeln();

    // Network Status
    buffer.writeln('─── NETWORK STATUS ───');
    await _addNetworkStatus(buffer);
    buffer.writeln();

    // Active Profile
    buffer.writeln('─── ACTIVE PROFILE ───');
    await _addActiveProfileInfo(buffer);
    buffer.writeln();

    // Footer
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('           END OF REPORT');
    buffer.writeln('═══════════════════════════════════════════');

    final report = buffer.toString();
    logger.info(
      LogCategory.ui,
      'Debug report generated',
      data: {'length': report.length},
    );

    return report;
  }

  /// Formatiert DateTime für Logs
  static String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  /// System Information
  static Future<void> _addSystemInfo(StringBuffer buffer) async {
    try {
      buffer.writeln('Platform: ${Platform.operatingSystem}');
      buffer.writeln('OS Version: ${Platform.operatingSystemVersion}');
      buffer.writeln('Dart Version: ${Platform.version}');
      buffer.writeln('Number of Processors: ${Platform.numberOfProcessors}');
      buffer.writeln('Is Debug Mode: ${kDebugMode ? "YES" : "NO"}');
      buffer.writeln('Is Profile Mode: ${kProfileMode ? "YES" : "NO"}');
      buffer.writeln('Is Release Mode: ${kReleaseMode ? "YES" : "NO"}');
    } catch (e) {
      buffer.writeln('Error collecting system info: $e');
    }
  }

  /// App Information
  static Future<void> _addAppInfo(StringBuffer buffer) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      buffer.writeln('App Name: ${packageInfo.appName}');
      buffer.writeln('Package Name: ${packageInfo.packageName}');
      buffer.writeln('Version: ${packageInfo.version}');
      buffer.writeln('Build Number: ${packageInfo.buildNumber}');
    } catch (e) {
      // package_info_plus requires rebuild in emulator
      buffer.writeln('App Name: Aurora (DIS App)');
      buffer.writeln('Package Name: Unknown (plugin error)');
      buffer.writeln('Version: See pubspec.yaml');
      buffer.writeln('Note: package_info_plus requires rebuild on emulator');
    }
  }

  /// Performance Metrics
  static Future<void> _addPerformanceMetrics(StringBuffer buffer) async {
    try {
      // 1. Uptime seit App-Start
      // (Dart hat keine direkte API, aber wir können approximieren)
      buffer.writeln('App Session: Active (debug report generated)');

      // 2. Service Count & Health
      try {
        final profileService = getIt.isRegistered<ProfileService>();
        final chatService = getIt.isRegistered<ChatService>();
        final calendarService = getIt.isRegistered<CalendarService>();
        final medicationService = getIt.isRegistered<MedicationService>();
        final contactService = getIt.isRegistered<ContactService>();
        final finderService = getIt.isRegistered<FinderService>();
        final diaryService = getIt.isRegistered<DiaryService>();
        final locationService = getIt.isRegistered<LocationTrackingService>();
        final mapService = getIt.isRegistered<MapService>();

        final registeredServices = [
          profileService,
          chatService,
          calendarService,
          medicationService,
          contactService,
          finderService,
          diaryService,
          locationService,
          mapService,
        ].where((s) => s).length;

        buffer.writeln('Registered Services: $registeredServices/9 services');
      } catch (e) {
        buffer.writeln('Registered Services: Unable to determine');
      }

      // 3. Memory Approximation (Dart VM hat limitierte Memory APIs)
      buffer.writeln('Memory Info: Not available (Dart limitation)');

      // 4. Build Mode Info (bereits in System Info, aber hier nochmal für Performance-Context)
      if (kDebugMode) {
        buffer.writeln(
          '⚠️ Running in DEBUG mode (slower performance expected)',
        );
      } else if (kReleaseMode) {
        buffer.writeln('✅ Running in RELEASE mode (optimized performance)');
      } else if (kProfileMode) {
        buffer.writeln('🔍 Running in PROFILE mode (performance analysis)');
      }
    } catch (e) {
      buffer.writeln('Error collecting performance metrics: $e');
    }
  }

  /// Recent Errors & Warnings (aus Logger Circular Buffer)
  static Future<void> _addRecentErrors(StringBuffer buffer) async {
    try {
      final recentErrors = logger.getRecentErrors();

      if (recentErrors.isEmpty) {
        buffer.writeln('✅ No errors or warnings in current session');
        return;
      }

      buffer.writeln(
        'Last ${recentErrors.length} errors/warnings (newest first):',
      );
      buffer.writeln();

      // Zeige neueste zuerst (reverse)
      for (final entry in recentErrors.reversed) {
        buffer.writeln(entry.toDebugString());
      }

      // Statistik
      final errorCount = recentErrors
          .where((e) => e.level.name == 'error')
          .length;
      final warningCount = recentErrors
          .where((e) => e.level.name == 'warning')
          .length;
      final criticalCount = recentErrors
          .where((e) => e.level.name == 'critical')
          .length;

      buffer.writeln();
      buffer.writeln(
        'Summary: $criticalCount critical, $errorCount errors, $warningCount warnings',
      );
    } catch (e) {
      buffer.writeln('Error collecting recent errors: $e');
    }
  }

  /// Permissions Status (General - ohne GPS, das hat eigene Sektion)
  static Future<void> _addPermissionsStatus(StringBuffer buffer) async {
    try {
      // Andere Permissions hier (Storage, Camera, etc.)
      buffer.writeln('(GPS/Location Tracking hat eigene Sektion unten)');
    } catch (e) {
      buffer.writeln('Error checking permissions: $e');
    }
  }

  /// GPS & Location Tracking Status (dedizierte Sektion)
  static Future<void> _addGpsLocationTracking(StringBuffer buffer) async {
    try {
      // 1. Android Permission Status (detailliert)
      final gpsManager = getIt<GpsManager>();
      final permission = gpsManager.hasGpsPermission.value;
      buffer.writeln(
        'Android Permission: ${permission ? "✅ GRANTED" : "❌ DENIED"}',
      );

      // 2. GPS Service Status (System-Level)
      final serviceEnabled = gpsManager.isGpsServiceEnabled.value;
      buffer.writeln(
        'GPS Service (System): ${serviceEnabled ? "✅ ENABLED" : "❌ DISABLED"}',
      );

      // 3. App Tracking Status
      final trackingService = getIt<LocationTrackingService>();
      final isTracking = trackingService.isTrackingRunning.value;
      buffer.writeln(
        'App Tracking: ${isTracking ? "✅ ACTIVE" : "⏸️ INACTIVE"}',
      );

      // 4. Letzte Position/Update
      final lastUpdate = trackingService.lastUpdate.value;
      if (lastUpdate != null) {
        final difference = DateTime.now().difference(lastUpdate);
        buffer.writeln(
          'Last Update: ${difference.inMinutes}m ${difference.inSeconds % 60}s ago',
        );
      } else {
        buffer.writeln('Last Update: Never');
      }

      // 5. Database Statistiken (via LocationTrackingService)
      try {
        buffer.writeln(
          'Location History: ${trackingService.locationHistoryBox.length} entries',
        );
        buffer.writeln(
          'Profile Switches: ${trackingService.switchEventsBox.length} entries',
        );
      } catch (e) {
        buffer.writeln('Location History: Service error');
        buffer.writeln('Profile Switches: Service error');
      }
    } catch (e) {
      buffer.writeln('Error collecting GPS/Location tracking info: $e');
    }
  }

  /// Database Status
  static Future<void> _addDatabaseStatus(StringBuffer buffer) async {
    try {
      // Nutze Services statt direkten Hive-Zugriff (vermeidet Type-Konflikte)

      // Profiles (via ProfileService)
      try {
        final profileService = getIt<ProfileService>();
        buffer.writeln('Profiles: ${profileService.profiles.length} entries');
      } catch (e) {
        buffer.writeln('Profiles: Service not accessible');
      }

      // Settings (untyped box, safe to access directly)
      try {
        if (Hive.isBoxOpen(HiveBoxNames.settings)) {
          final settingsBox = Hive.box<dynamic>(HiveBoxNames.settings);
          buffer.writeln('Settings: ${settingsBox.length} entries');
        } else {
          buffer.writeln('Settings: Not initialized');
        }
      } catch (e) {
        buffer.writeln('Settings: Error');
      }

      // Chat Messages (via ChatService)
      try {
        final chatService = getIt<ChatService>();
        buffer.writeln('Chat Messages: ${chatService.messages.length} entries');
      } catch (e) {
        buffer.writeln('Chat Messages: Service not accessible');
      }

      // Calendar Events (via CalendarService)
      try {
        final calendarService = getIt<CalendarService>();
        buffer.writeln(
          'Calendar Events: ${calendarService.events.length} entries',
        );
      } catch (e) {
        buffer.writeln('Calendar Events: Service not accessible');
      }

      // Medications (via MedicationService)
      try {
        final medicationService = getIt<MedicationService>();
        buffer.writeln(
          'Medications: ${medicationService.medicationsBox.length} entries',
        );
        buffer.writeln(
          'Medication Logs: ${medicationService.logsBox.length} entries',
        );
      } catch (e) {
        buffer.writeln('Medications: Service not accessible');
        buffer.writeln('Medication Logs: Service not accessible');
      }

      // Contacts (via ContactService)
      try {
        final contactService = getIt<ContactService>();
        buffer.writeln('Contacts: ${contactService.contacts.length} entries');
      } catch (e) {
        buffer.writeln('Contacts: Service not accessible');
      }

      // Finder Items (via FinderService)
      try {
        final finderService = getIt<FinderService>();
        buffer.writeln(
          'Finder Items: ${finderService.finderItemsBox.length} entries',
        );
      } catch (e) {
        buffer.writeln('Finder Items: Service not accessible');
      }

      // Diary Entries (via DiaryService)
      try {
        final diaryService = getIt<DiaryService>();
        buffer.writeln('Diary Entries: ${diaryService.entries.length} entries');
      } catch (e) {
        buffer.writeln('Diary Entries: Service not accessible');
      }

      // Location History (via LocationTrackingService)
      try {
        final trackingService = getIt<LocationTrackingService>();
        buffer.writeln(
          'Location History: ${trackingService.locationHistoryBox.length} entries',
        );
      } catch (e) {
        buffer.writeln('Location History: Service not accessible');
      }

      // Profile Switches (via LocationTrackingService)
      try {
        final trackingService = getIt<LocationTrackingService>();
        buffer.writeln(
          'Profile Switches: ${trackingService.switchEventsBox.length} entries',
        );
      } catch (e) {
        buffer.writeln('Profile Switches: Service not accessible');
      }
    } catch (e) {
      buffer.writeln('Error collecting database status: $e');
    }
  }

  /// Storage Health Check
  static Future<void> _addStorageHealth(StringBuffer buffer) async {
    try {
      // 1. App Directory
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          buffer.writeln('App Directory: ${appDir.path}');
        } catch (e) {
          buffer.writeln('App Directory: Unable to determine');
        }
      }

      // 2. Attachments-Verzeichnis analysieren
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final attachmentsDir = Directory('${appDir.path}/attachments');

        if (await attachmentsDir.exists()) {
          // Zähle Dateien nach Kategorie
          final allFiles = await attachmentsDir.list(recursive: true).toList();
          final files = allFiles.whereType<File>().toList();

          var doodleCount = 0;
          var voiceCount = 0;
          var imageCount = 0;
          var videoCount = 0;
          var avatarCount = 0;
          var otherCount = 0;
          var totalSize = 0;

          for (final file in files) {
            final fileName = file.path.split(Platform.pathSeparator).last;
            final size = await file.length();
            totalSize += size;

            if (fileName.startsWith('doodle_')) {
              doodleCount++;
            } else if (fileName.startsWith('voice_')) {
              voiceCount++;
            } else if (fileName.startsWith('image_')) {
              imageCount++;
            } else if (fileName.startsWith('video_')) {
              videoCount++;
            } else if (fileName.startsWith('avatar_') ||
                fileName.endsWith('.jpg') ||
                fileName.endsWith('.png')) {
              avatarCount++;
            } else {
              otherCount++;
            }
          }

          buffer.writeln(
            'Attachments Directory: ${_formatBytes(totalSize)} (${files.length} files)',
          );
          buffer.writeln('  ├─ Doodles: $doodleCount files');
          buffer.writeln('  ├─ Voice Messages: $voiceCount files');
          buffer.writeln('  ├─ Images: $imageCount files');
          buffer.writeln('  ├─ Videos: $videoCount files');
          buffer.writeln('  ├─ Avatars: $avatarCount files');
          if (otherCount > 0) {
            buffer.writeln('  └─ Other: $otherCount files');
          }
        } else {
          buffer.writeln('Attachments Directory: Not created yet');
        }
      } catch (e) {
        buffer.writeln('Attachments Directory: Error accessing ($e)');
      }

      // 3. Hive Box Integrity (alle Boxes erfolgreich geöffnet?)
      try {
        final boxNames = [
          HiveBoxNames.profiles,
          HiveBoxNames.settings,
          HiveBoxNames.chatMessages,
          HiveBoxNames.calendarEvents,
          HiveBoxNames.medications,
          HiveBoxNames.medicationLogs,
          HiveBoxNames.contacts,
          HiveBoxNames.finderItems,
          HiveBoxNames.diaryEntries,
          HiveBoxNames.locationHistory,
          HiveBoxNames.profileSwitches,
        ];

        final openBoxes = boxNames.where(Hive.isBoxOpen).toList();
        final closedBoxes = boxNames
            .where((name) => !Hive.isBoxOpen(name))
            .toList();

        if (closedBoxes.isEmpty) {
          buffer.writeln(
            'Hive Boxes: ✅ All ${boxNames.length} boxes open and healthy',
          );
        } else {
          buffer.writeln(
            'Hive Boxes: ⚠️ ${openBoxes.length}/${boxNames.length} boxes open',
          );
          buffer.writeln('  └─ Closed: ${closedBoxes.join(", ")}');
        }
      } catch (e) {
        buffer.writeln('Hive Boxes: Error checking ($e)');
      }
    } catch (e) {
      buffer.writeln('Error collecting storage health: $e');
    }
  }

  /// Helper: Format bytes to human-readable format
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Services Status
  static Future<void> _addServicesStatus(StringBuffer buffer) async {
    try {
      final services = <String, String>{};

      // Check every service registration and basic functionality
      try {
        if (getIt.isRegistered<ProfileService>()) {
          final service = getIt<ProfileService>();
          final profileCount = service.profiles.length;
          services['ProfileService'] = '✅ Ready ($profileCount profiles)';
        } else {
          services['ProfileService'] = '❌ Not registered';
        }
      } catch (e) {
        services['ProfileService'] =
            '❌ Error: ${e.toString().substring(0, 30)}...';
      }

      try {
        if (getIt.isRegistered<ChatService>()) {
          final service = getIt<ChatService>();
          final msgCount = service.messages.length;
          services['ChatService'] = '✅ Ready ($msgCount messages)';
        } else {
          services['ChatService'] = '❌ Not registered';
        }
      } catch (e) {
        services['ChatService'] =
            '❌ Error: ${e.toString().substring(0, 30)}...';
      }

      try {
        if (getIt.isRegistered<CalendarService>()) {
          final service = getIt<CalendarService>();
          final eventCount = service.events.length;
          services['CalendarService'] = '✅ Ready ($eventCount events)';
        } else {
          services['CalendarService'] = '❌ Not registered';
        }
      } catch (e) {
        services['CalendarService'] =
            '❌ Error: ${e.toString().substring(0, 30)}...';
      }

      try {
        if (getIt.isRegistered<MedicationService>()) {
          final service = getIt<MedicationService>();
          final medCount = service.medicationsBox.length;
          services['MedicationService'] = '✅ Ready ($medCount medications)';
        } else {
          services['MedicationService'] = '❌ Not registered';
        }
      } catch (e) {
        services['MedicationService'] =
            '❌ Error: ${e.toString().substring(0, 30)}...';
      }

      try {
        if (getIt.isRegistered<ContactService>()) {
          final service = getIt<ContactService>();
          final contactCount = service.contacts.length;
          services['ContactService'] = '✅ Ready ($contactCount contacts)';
        } else {
          services['ContactService'] = '❌ Not registered';
        }
      } catch (e) {
        services['ContactService'] =
            '❌ Error: ${e.toString().substring(0, 30)}...';
      }

      try {
        if (getIt.isRegistered<FinderService>()) {
          final service = getIt<FinderService>();
          final itemCount = service.finderItemsBox.length;
          services['FinderService'] = '✅ Ready ($itemCount items)';
        } else {
          services['FinderService'] = '❌ Not registered';
        }
      } catch (e) {
        services['FinderService'] =
            '❌ Error: ${e.toString().substring(0, 30)}...';
      }

      try {
        if (getIt.isRegistered<DiaryService>()) {
          final service = getIt<DiaryService>();
          final entryCount = service.entries.length;
          services['DiaryService'] = '✅ Ready ($entryCount entries)';
        } else {
          services['DiaryService'] = '❌ Not registered';
        }
      } catch (e) {
        services['DiaryService'] =
            '❌ Error: ${e.toString().substring(0, 30)}...';
      }

      try {
        if (getIt.isRegistered<LocationTrackingService>()) {
          final service = getIt<LocationTrackingService>();
          final isTracking = service.isTrackingRunning.value;
          services['LocationTrackingService'] = isTracking
              ? '✅ Ready (tracking active)'
              : '⚠️ Ready (tracking inactive)';
        } else {
          services['LocationTrackingService'] = '❌ Not registered';
        }
      } catch (e) {
        services['LocationTrackingService'] =
            '❌ Error: ${e.toString().substring(0, 30)}...';
      }

      try {
        if (getIt.isRegistered<MapService>()) {
          final service = getIt<MapService>();
          final tilesDownloaded = service.areTilesDownloaded;
          services['MapService'] = tilesDownloaded
              ? '✅ Ready (tiles downloaded)'
              : '⚠️ Ready (no tiles)';
        } else {
          services['MapService'] = '❌ Not registered';
        }
      } catch (e) {
        services['MapService'] = '❌ Error: ${e.toString().substring(0, 30)}...';
      }

      // Output all services
      for (final entry in services.entries) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }

      // Summary
      final readyCount = services.values.where((v) => v.startsWith('✅')).length;
      final warningCount = services.values
          .where((v) => v.startsWith('⚠️'))
          .length;
      final errorCount = services.values.where((v) => v.startsWith('❌')).length;

      buffer.writeln();
      buffer.writeln(
        'Service Health: $readyCount ready, $warningCount warnings, $errorCount errors',
      );
    } catch (e) {
      buffer.writeln('Error collecting services status: $e');
    }
  }

  /// Network Status
  static Future<void> _addNetworkStatus(StringBuffer buffer) async {
    try {
      // Simple connectivity check via DNS lookup
      final stopwatch = Stopwatch()..start();
      try {
        final result = await InternetAddress.lookup(
          'tile.openstreetmap.org',
        ).timeout(const Duration(seconds: 5));
        stopwatch.stop();

        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          buffer.writeln('Internet Connectivity: ✅ ONLINE');
          buffer.writeln('DNS Lookup Time: ${stopwatch.elapsedMilliseconds}ms');
          buffer.writeln('Resolved IP: ${result[0].address}');
        } else {
          buffer.writeln('Internet Connectivity: ❌ OFFLINE (no address)');
        }
      } on SocketException catch (e) {
        stopwatch.stop();
        buffer.writeln('Internet Connectivity: ❌ OFFLINE (SocketException)');
        buffer.writeln('Error: ${e.message}');
      } on TimeoutException {
        stopwatch.stop();
        buffer.writeln('Internet Connectivity: ⚠️ TIMEOUT (>5s)');
      }
    } catch (e) {
      buffer.writeln('Error checking network: $e');
    }
  }

  /// Tab Visibility Analysis
  static void _addTabVisibilityAnalysis(StringBuffer buffer, Profile profile) {
    // Define tab requirements (based on main.dart logic)
    final tabs = <Map<String, dynamic>>[
      {
        'name': 'Chat',
        'permission': Permission.viewChatTab,
        'alwaysVisible': true,
      },
      {
        'name': 'Kalender',
        'permission': Permission.viewCalendarTab,
        'alwaysVisible': false,
      },
      {
        'name': 'Medikation',
        'permission': Permission.viewMedicationTab,
        'alwaysVisible': false,
      },
      {
        'name': 'Kontakte',
        'permission': Permission.viewContactsTab,
        'alwaysVisible': false,
      },
      {
        'name': 'Finder',
        'permission': Permission.viewFinderTab,
        'alwaysVisible': false,
      },
      {
        'name': 'Tagebuch',
        'permission': Permission.viewDiaryTab,
        'alwaysVisible': false,
      },
      {
        'name': 'Zeitachse',
        'permission': Permission.viewTimelineTab,
        'alwaysVisible': false,
      },
      {
        'name': 'Notfall',
        'permission': Permission.viewEmergencyTab,
        'alwaysVisible': false,
      },
      {
        'name': 'Spiele',
        'permission': Permission.viewGamesTab,
        'alwaysVisible': false,
      },
    ];

    final visibleTabs = <String>[];
    final hiddenTabs = <Map<String, String>>[];

    for (final tab in tabs) {
      final tabName = tab['name'] as String;
      final permission = tab['permission'] as Permission;
      final alwaysVisible = tab['alwaysVisible'] as bool;

      if (alwaysVisible ||
          profile.isAdmin ||
          profile.hasPermission(permission)) {
        visibleTabs.add(tabName);
      } else {
        hiddenTabs.add({
          'name': tabName,
          'reason': 'Missing permission: ${permission.persistedValue}',
        });
      }
    }

    buffer.writeln('  Visible: ${visibleTabs.length}/${tabs.length} tabs');
    buffer.writeln('  ✅ ${visibleTabs.join(", ")}');

    if (hiddenTabs.isNotEmpty) {
      buffer.writeln('  ❌ Hidden:');
      for (final hidden in hiddenTabs) {
        buffer.writeln('     - ${hidden['name']}: ${hidden['reason']}');
      }
    }
  }

  /// Helper: Get anonymous profile type
  static String _getProfileType(Profile profile) {
    if (profile.isAdmin) return 'Administrator';
    final age = profile.age;
    if (age == null) return 'Adult (no age set)';
    if (age < 8) return 'Child Profile';
    return 'Adult Profile';
  }

  /// Helper: Get anonymous age group
  static String _getAgeGroup(int? age) {
    if (age == null) return 'Not set';
    if (age < 8) return 'Child (<8 years)';
    if (age < 18) return 'Teen (8-17 years)';
    return 'Adult (18+ years)';
  }

  /// Active Profile Info
  static Future<void> _addActiveProfileInfo(StringBuffer buffer) async {
    try {
      final profileService = getIt<ProfileService>();
      final activeProfile = profileService.activeProfile;

      if (activeProfile != null) {
        buffer.writeln('Profile Type: ${_getProfileType(activeProfile)}');
        buffer.writeln('Profile ID: ${activeProfile.id}');
        buffer.writeln('Age Group: ${_getAgeGroup(activeProfile.age)}');
        buffer.writeln(
          'Preferred Color: 0x${activeProfile.preferredColorValue.toRadixString(16).toUpperCase()}',
        );
        buffer.writeln('Is Admin: ${activeProfile.isAdmin ? "YES" : "NO"}');
        buffer.writeln(
          'Has Avatar: ${activeProfile.avatarPath != null ? "YES" : "NO"}',
        );
        buffer.writeln(
          'Permission Count: ${activeProfile.permissions.length} permissions',
        );

        // Tab Visibility Analysis
        buffer.writeln();
        buffer.writeln('Tab Visibility:');
        _addTabVisibilityAnalysis(buffer, activeProfile);
      } else {
        buffer.writeln('No active profile');
      }
    } catch (e) {
      buffer.writeln('Error collecting profile info: $e');
    }
  }
}
