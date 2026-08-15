import 'package:hive_ce/hive.dart';

part 'calendar_event.g.dart';

/// Standardvorlauf fuer Koerpertermine, auch fuer alte gespeicherte Eintraege.
const int defaultCalendarEventReminderMinutes = 30;

/// Kalender-Event Model
@HiveType(typeId: 3)
class CalendarEvent {
  // Bilder (Kamera/Galerie)

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.profileIds,
    this.description,
    this.category,
    this.notes,
    this.imagePaths,
    this.notificationEnabled = false,
    this.reminderMinutesBefore,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  /// Von Map erstellen
  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      profileIds: List<String>.from(map['profileIds'] as List),
      description: map['description'] as String?,
      category: map['category'] as String?,
      notes: map['notes'] as String?,
      imagePaths: map['imagePaths'] != null
          ? List<String>.from(map['imagePaths'] as List)
          : null,
      notificationEnabled: map['notificationEnabled'] as bool? ?? false,
      reminderMinutesBefore: map['reminderMinutesBefore'] as int?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationName: map['locationName'] as String?,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime endTime;

  @HiveField(4)
  final List<String> profileIds;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String? category;

  @HiveField(7)
  final String? notes; // Zusätzliche Notizen zum Event

  @HiveField(8)
  final List<String>? imagePaths;

  @HiveField(9)
  final bool notificationEnabled; // Benachrichtigungen aktiviert?

  @HiveField(10)
  final int? reminderMinutesBefore; // Minuten vorher (15, 30, 60, 120, 1440)

  /// Wo der Termin stattfindet.
  ///
  /// Ein Termin ohne Ort beantwortet nur die halbe Frage. „Arzt um 15 Uhr"
  /// hilft niemandem, der nicht weiß, wo der Arzt ist — und wer nach Stunden
  /// oder Monaten wieder vorn ist, weiß es womöglich nicht.
  ///
  /// Auch „zuhause" ist ein Ort und gehört hierher: Er sagt, dass man
  /// gerade *nicht* losmuss, und das ist genauso eine Auskunft.
  ///
  /// Die Koordinaten stehen am Termin selbst, nicht als Verweis auf einen
  /// gespeicherten Ort. Ein Verweis bräche, wenn der Ort gelöscht wird, und
  /// ein vergangener Termin soll zeigen, wo er war — nicht, wo der Ort
  /// heute liegt.
  @HiveField(11)
  final double? latitude;

  @HiveField(12)
  final double? longitude;

  /// Der Name des Orts, wie er auf dem Schirm steht — „Zuhause", „Praxis
  /// Dr. Berg". Ohne ihn stünde dort eine Zahl.
  @HiveField(13)
  final String? locationName;

  /// Kopie mit geänderten Werten
  CalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? profileIds,
    String? description,
    String? category,
    String? notes,
    List<String>? imagePaths,
    bool? notificationEnabled,
    int? reminderMinutesBefore,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      profileIds: profileIds ?? this.profileIds,
      description: description ?? this.description,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      imagePaths: imagePaths ?? this.imagePaths,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  /// Zu Map konvertieren (für Logging/Debugging)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'profileIds': profileIds,
      'description': description,
      'category': category,
      'notes': notes,
      'imagePaths': imagePaths,
      'notificationEnabled': notificationEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
  }

  @override
  String toString() {
    return 'CalendarEvent(id: $id, title: $title, startTime: $startTime, endTime: $endTime, profileIds: $profileIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CalendarEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
