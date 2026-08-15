import 'package:hive_ce/hive.dart';

part 'notification_queue_entry.g.dart';

/// Notification Queue Entry - Represents a scheduled notification
///
/// This model stores all information needed for local notifications
/// and tracks their status throughout the notification lifecycle.
///
/// ## Status Flow:
/// ```
/// scheduled → sent (app running) / assumed_shown (app was closed) → confirmed (user tapped)
/// ```
///
/// ## Use Cases:
/// - **Medication Reminders**: Multiple entries per medication time (-30min, -10min, 0min, +10min repeat)
/// - **Availability Notifications**: When as-needed medication becomes available again
/// - **Event Reminders**: User-configurable reminders for calendar events
///
/// ## Queue System:
/// - All entries stored in Hive box `notification_queue`
/// - Timer checks queue every minute (when app running)
/// - AlarmManager fallback (when app closed)
/// - Sync on app start: Mark missed notifications as "assumed_shown"
@HiveType(typeId: 26)
class NotificationQueueEntry extends HiveObject {
  NotificationQueueEntry({
    required this.id,
    required this.scheduledTime,
    required this.type,
    required this.referenceId,
    required this.status,
    required this.title,
    required this.body,
    required this.platformNotificationId,
    this.payload,
    this.createdAt,
    this.sentAt,
  });

  /// Unique identifier for this queue entry (UUID)
  @HiveField(0)
  final String id;

  /// When this notification should be shown
  @HiveField(1)
  final DateTime scheduledTime;

  /// Type of notification
  ///
  /// **Values:**
  /// - `medication_reminder`: Medication reminder (-30min, -10min, 0min, +10min)
  /// - `medication_available`: As-needed medication is available again
  /// - `event_reminder`: Calendar event reminder
  @HiveField(2)
  final String type;

  /// Reference to source entity (medicationId or eventId)
  @HiveField(3)
  final String referenceId;

  /// Current status of this notification
  ///
  /// **Values:**
  /// - `scheduled`: Queued, not yet sent
  /// - `sent`: Sent while app was running (confirmed)
  /// - `assumed_shown`: Scheduled time passed while app closed (assumed shown by AlarmManager)
  /// - `confirmed`: User tapped the notification
  /// - `cancelled`: Manually cancelled (e.g., medication deleted)
  @HiveField(4)
  String status;

  /// Notification title
  ///
  /// **Examples:**
  /// - "Medikamenten-Erinnerung"
  /// - "Medikament verfügbar"
  /// - "Termin-Erinnerung"
  @HiveField(5)
  final String title;

  /// Notification body text
  ///
  /// **Examples:**
  /// - "Aspirin - 1 Tablette"
  /// - "Ibuprofen kann jetzt wieder eingenommen werden"
  /// - "Arzttermin in 30 Minuten"
  @HiveField(6)
  final String body;

  /// Platform-specific notification ID (for cancellation)
  ///
  /// Generated from hash of id + type
  /// Used to cancel notifications via flutter_local_notifications
  @HiveField(7)
  final int platformNotificationId;

  /// Additional data payload
  ///
  /// **Keys:**
  /// - `medicationId`: For medication notifications
  /// - `eventId`: For event notifications
  /// - `timeOffset`: For medication reminders (-30, -10, 0, +10)
  /// - `repeatIndex`: For +10min repeats (0, 1, 2, ...)
  @HiveField(8)
  final Map<String, dynamic>? payload;

  /// When this entry was created (for debugging)
  @HiveField(9)
  final DateTime? createdAt;

  /// When this notification was actually sent (if sent)
  @HiveField(10)
  DateTime? sentAt;

  /// Check if this notification is pending (should be sent)
  bool get isPending => status == 'scheduled';

  /// Check if scheduled time has passed
  bool get isPast => scheduledTime.isBefore(DateTime.now());

  /// Check if this is a medication reminder
  bool get isMedicationReminder => type == 'medication_reminder';

  /// Check if this is a medication availability notification
  bool get isMedicationAvailable => type == 'medication_available';

  /// Check if this is an event reminder
  bool get isEventReminder => type == 'event_reminder';

  /// Mark as sent
  void markAsSent() {
    status = 'sent';
    sentAt = DateTime.now();
    save();
  }

  /// Mark as assumed shown (app was closed)
  void markAsAssumedShown() {
    status = 'assumed_shown';
    sentAt = scheduledTime; // Use scheduled time as best guess
    save();
  }

  /// Mark as confirmed (user tapped)
  void markAsConfirmed() {
    status = 'confirmed';
    save();
  }

  /// Mark as cancelled
  void markAsCancelled() {
    status = 'cancelled';
    save();
  }

  /// Create a copy with updated fields
  NotificationQueueEntry copyWith({
    String? id,
    DateTime? scheduledTime,
    String? type,
    String? referenceId,
    String? status,
    String? title,
    String? body,
    int? platformNotificationId,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    DateTime? sentAt,
  }) {
    return NotificationQueueEntry(
      id: id ?? this.id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      status: status ?? this.status,
      title: title ?? this.title,
      body: body ?? this.body,
      platformNotificationId:
          platformNotificationId ?? this.platformNotificationId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  String toString() {
    return 'NotificationQueueEntry('
        'id: $id, '
        'scheduledTime: $scheduledTime, '
        'type: $type, '
        'referenceId: $referenceId, '
        'status: $status, '
        'title: $title'
        ')';
  }
}
