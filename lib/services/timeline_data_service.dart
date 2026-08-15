import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:hive_ce/hive.dart';

/// Timeline Event - Unified Event für Timeline-Darstellung
/// Kombiniert verschiedene Event-Typen in einheitliches Interface
class TimelineEvent {
  TimelineEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    this.title,
    this.description,
    this.profileId,
    this.iconData,
    this.color,
    this.data,
  }); // Zusätzliche Daten

  /// Factory: Von ProfileSwitchEvent
  factory TimelineEvent.fromProfileSwitch(
    ProfileSwitchEvent event,
    String? fromProfileName,
    String? toProfileName,
  ) {
    return TimelineEvent(
      id: event.id,
      timestamp: event.timestamp,
      type: TimelineEventType.profileSwitch,
      title: AppTexts.current.timelineProfileSwitch,
      description:
          '${fromProfileName ?? "App-Start"} → ${toProfileName ?? "Unbekannt"}',
      profileId: event.toProfileId,
      data: {
        'fromProfileId': event.fromProfileId,
        'toProfileId': event.toProfileId,
        'isAppStart': event.isAppStart,
        'latitude': event.latitude,
        'longitude': event.longitude,
      },
    );
  }

  /// Factory: Von MedicationLog
  factory TimelineEvent.fromMedicationLog(
    MedicationLog log,
    String medicationName,
    String? medicationImagePath,
  ) {
    String statusEmoji;
    String statusText;

    switch (log.status) {
      case MedicationStatus.taken:
        statusEmoji = '✓';
        statusText = 'genommen';
      case MedicationStatus.refused:
        statusEmoji = '✗';
        statusText = 'verweigert';
      case MedicationStatus.snoozed:
        statusEmoji = '⏰';
        statusText = 'verschoben';
      case MedicationStatus.skipped:
        statusEmoji = '⊘';
        statusText = AppTexts.current.timelineSkipped;
    }

    return TimelineEvent(
      id: log.id,
      timestamp: log.takenAt,
      type: TimelineEventType.medication,
      title: '$statusEmoji $medicationName',
      description: statusText,
      profileId: log.profileId,
      data: {
        'medicationId': log.medicationId,
        'medicationName': medicationName,
        'medicationImagePath': medicationImagePath,
        'status': log.status.toString(),
        'scheduledTime': log.scheduledTime,
        'note': log.note,
        'feedback': log.feedback,
      },
    );
  }

  /// Factory: Von CalendarEvent
  factory TimelineEvent.fromCalendarEvent(CalendarEvent event) {
    return TimelineEvent(
      id: event.id,
      timestamp: event.startTime,
      type: TimelineEventType.calendarEvent,
      title: event.title,
      description: event.description,
      profileId: event.profileIds.isNotEmpty ? event.profileIds.first : null,
      data: {
        'startTime': event.startTime.toIso8601String(),
        'endTime': event.endTime.toIso8601String(),
        'category': event.category,
        'profileIds': event.profileIds,
      },
    );
  }

  /// Factory: Von Medication Schedule (geplante Einnahme)
  factory TimelineEvent.fromMedicationSchedule(
    Medication medication,
    DateTime scheduledTime,
  ) {
    final now = DateTime.now();
    final isPast = scheduledTime.isBefore(now);
    final isSoon = !isPast && scheduledTime.difference(now).inHours < 1;

    String statusText;
    String statusEmoji;

    if (isPast) {
      statusText = 'Verpasst';
      statusEmoji = '⚠️';
    } else if (isSoon) {
      statusText = AppTexts.current.timelineDueSoon;
      statusEmoji = '🔔';
    } else {
      statusText = 'Geplant';
      statusEmoji = '⏰';
    }

    return TimelineEvent(
      id: '${medication.id}_${scheduledTime.toIso8601String()}',
      timestamp: scheduledTime,
      type: TimelineEventType.medication,
      title: '$statusEmoji ${medication.name}',
      description: statusText,
      data: {
        'medicationId': medication.id,
        'medicationName': medication.name,
        'medicationImagePath': medication.imagePath,
        'status': isPast ? 'missed' : 'scheduled',
        'dosage': medication.dosage,
        'scheduledTime': scheduledTime.toIso8601String(),
      },
    );
  }

  final String id;
  final DateTime timestamp;
  final TimelineEventType type;
  final String? title;
  final String? description;
  final String? profileId;
  final String? iconData; // Icon-Name als String
  final int? color; // Color.value als int
  final Map<String, dynamic>? data;

  /// Ist Event in der Vergangenheit?
  bool get isPast => timestamp.isBefore(DateTime.now());

  /// Ist Event in der Zukunft?
  bool get isFuture => timestamp.isAfter(DateTime.now());

  /// Zeitdifferenz zu jetzt (in Minuten)
  int get minutesFromNow => timestamp.difference(DateTime.now()).inMinutes;
}

/// Event-Typ für Timeline
enum TimelineEventType {
  profileSwitch,
  medication,
  calendarEvent,
}

/// Timeline Data Service
/// Aggregiert Events aus verschiedenen Quellen für Timeline-Darstellung
class TimelineDataService {
  TimelineDataService({
    required this.profileSwitchBox,
    required this.medicationLogsBox,
    required this.calendarEventsBox,
    required this.medicationsBox,
    required this.profilesBox,
    required this.profileService,
  });

  final Box<ProfileSwitchEvent> profileSwitchBox;
  final Box<MedicationLog> medicationLogsBox;
  final Box<CalendarEvent> calendarEventsBox;
  final Box<Medication> medicationsBox;
  final Box<dynamic>
  profilesBox; // Box<Profile> - untyped wegen circular dependency
  final dynamic
  profileService; // ProfileService - dynamic wegen circular dependency

  /// Holt alle Events in einem Zeitraum
  ///
  /// Kombiniert ProfileSwitchEvents, MedicationLogs und CalendarEvents
  /// Sortiert chronologisch nach timestamp
  List<TimelineEvent> getEventsInRange(
    DateTime start,
    DateTime end,
  ) {
    final events = <TimelineEvent>[];

    // 1. Profile Switches
    final profileSwitches = profileSwitchBox.values.where((event) {
      return event.timestamp.isAfter(start) && event.timestamp.isBefore(end);
    });

    for (final switchEvent in profileSwitches) {
      // Get profile names for better description
      String? fromName;
      String? toName;

      try {
        if (switchEvent.fromProfileId != null) {
          final fromProfile = profilesBox.get(switchEvent.fromProfileId);
          fromName = fromProfile?.name as String?;
        }
        final toProfile = profilesBox.get(switchEvent.toProfileId);
        toName = toProfile?.name as String?;
      } catch (e) {
        // Profile not found - use IDs
      }

      events.add(
        TimelineEvent.fromProfileSwitch(
          switchEvent,
          fromName,
          toName,
        ),
      );
    }

    // 2. Medication Logs
    final medLogs = medicationLogsBox.values.where((log) {
      return log.takenAt.isAfter(start) && log.takenAt.isBefore(end);
    });

    for (final log in medLogs) {
      // Get medication name and image path
      var medicationName = 'Medikament';
      String? medicationImagePath;
      try {
        final medication = medicationsBox.get(log.medicationId);
        if (medication != null) {
          medicationName = medication.name;
          medicationImagePath = medication.imagePath;
        }
      } catch (e) {
        // Medication not found
      }

      events.add(
        TimelineEvent.fromMedicationLog(
          log,
          medicationName,
          medicationImagePath,
        ),
      );
    }

    // 2b. Medication Schedules (geplante Einnahmen)
    final currentProfileId = profileService?.activeProfile?.id;
    if (currentProfileId != null) {
      final activeMedications = medicationsBox.values.where((med) {
        return med.isActive &&
            med.type == MedicationType.daily &&
            med.profileIds.contains(currentProfileId);
      });

      for (final medication in activeMedications) {
        for (final timeStr in medication.timesOfDay) {
          try {
            // Parse time "08:00" → DateTime
            final parts = timeStr.split(':');
            if (parts.length != 2) continue;

            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);

            // Generiere Schedules für jeden Tag im Zeitraum
            var currentDay = DateTime(start.year, start.month, start.day);
            while (currentDay.isBefore(end) ||
                currentDay.isAtSameMomentAs(end)) {
              final scheduledTime = DateTime(
                currentDay.year,
                currentDay.month,
                currentDay.day,
                hour,
                minute,
              );

              if (scheduledTime.isAfter(start) &&
                  scheduledTime.isBefore(end) &&
                  scheduledTime.isAfter(medication.createdAt)) {
                // Check: Wurde diese Einnahme bereits geloggt?
                final hasLog = medLogs.any(
                  (log) =>
                      log.medicationId == medication.id &&
                      log.takenAt.difference(scheduledTime).abs().inMinutes <
                          30,
                );

                if (!hasLog) {
                  // Nur zeigen wenn NICHT bereits eingenommen
                  events.add(
                    TimelineEvent.fromMedicationSchedule(
                      medication,
                      scheduledTime,
                    ),
                  );
                }
              }

              currentDay = currentDay.add(const Duration(days: 1));
            }
          } catch (e) {
            // Invalid time format - skip
            logger.debug(
              LogCategory.service,
              'Timeline: Invalid time format',
              data: {'timeStr': timeStr, 'error': e.toString()},
            );
          }
        }
      }
    }

    // 3. Calendar Events
    final calendarEvents = calendarEventsBox.values.where((event) {
      // Event ist sichtbar wenn Start ODER End im Zeitraum liegt
      return (event.startTime.isAfter(start) &&
              event.startTime.isBefore(end)) ||
          (event.endTime.isAfter(start) && event.endTime.isBefore(end)) ||
          (event.startTime.isBefore(start) && event.endTime.isAfter(end));
    });

    for (final calEvent in calendarEvents) {
      events.add(TimelineEvent.fromCalendarEvent(calEvent));
    }

    // Sortiere chronologisch
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return events;
  }

  /// Holt Events für Standard-Ansicht (72h Fenster)
  ///
  /// centerTime = Jetzt-Zeitpunkt (Default: DateTime.now())
  /// timeWindow = Zeitfenster (Default: 72 Stunden)
  List<TimelineEvent> getStandardTimelineEvents({
    DateTime? centerTime,
    Duration timeWindow = const Duration(hours: 72),
  }) {
    final center = centerTime ?? DateTime.now();
    final halfWindow = Duration(milliseconds: timeWindow.inMilliseconds ~/ 2);

    final start = center.subtract(halfWindow);
    final end = center.add(halfWindow);

    logger.debug(
      LogCategory.service,
      'Timeline Query Start',
      data: {
        'centerTime': center.toString(),
        'timeWindowHours': timeWindow.inHours,
        'queryStart': start.toString(),
        'queryEnd': end.toString(),
        'medicationLogsInBox': medicationLogsBox.length,
        'calendarEventsInBox': calendarEventsBox.length,
        'profileSwitchesInBox': profileSwitchBox.length,
      },
    );

    final events = getEventsInRange(start, end);

    logger.debug(
      LogCategory.service,
      'Timeline Query Result',
      data: {
        'eventsFound': events.length,
        'eventTypes': {
          'profileSwitch': events
              .where((e) => e.type == TimelineEventType.profileSwitch)
              .length,
          'medication': events
              .where((e) => e.type == TimelineEventType.medication)
              .length,
          'calendar': events
              .where((e) => e.type == TimelineEventType.calendarEvent)
              .length,
        },
        'oldestEvent': events.isEmpty
            ? 'none'
            : events.first.timestamp.toString(),
        'newestEvent': events.isEmpty
            ? 'none'
            : events.last.timestamp.toString(),
      },
    );

    return events;
  }

  /// Holt kommende Events (nächste X Stunden)
  List<TimelineEvent> getUpcomingEvents({int hours = 24}) {
    final now = DateTime.now();
    final end = now.add(Duration(hours: hours));

    return getEventsInRange(now, end).where((event) => event.isFuture).toList();
  }

  /// Holt vergangene Events (letzte X Stunden)
  List<TimelineEvent> getPastEvents({int hours = 24}) {
    final now = DateTime.now();
    final start = now.subtract(Duration(hours: hours));

    return getEventsInRange(start, now).where((event) => event.isPast).toList();
  }

  /// Prüft ob Event-Overlap an einem Zeitpunkt existiert
  ///
  /// Gibt Liste von Events zurück die zur gleichen Zeit existieren
  /// (innerhalb +/- tolerance Minuten)
  List<TimelineEvent> getOverlappingEvents(
    DateTime timestamp, {
    int toleranceMinutes = 15,
  }) {
    final tolerance = Duration(minutes: toleranceMinutes);
    final start = timestamp.subtract(tolerance);
    final end = timestamp.add(tolerance);

    return getEventsInRange(start, end);
  }

  /// Zählt Events pro Tag im Zeitraum
  Map<DateTime, int> getEventCountByDay(DateTime start, DateTime end) {
    final events = getEventsInRange(start, end);
    final countByDay = <DateTime, int>{};

    for (final event in events) {
      // Normalize zu Mitternacht des Tages
      final day = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );

      countByDay[day] = (countByDay[day] ?? 0) + 1;
    }

    return countByDay;
  }

  /// Dispose (optional - falls Service-Lifecycle-Management gewünscht)
  void dispose() {
    // Boxes werden von HiveService verwaltet
    // Nichts zu tun hier
  }
}
