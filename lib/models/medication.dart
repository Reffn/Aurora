import 'package:hive_ce/hive.dart';

part 'medication.g.dart';

/// Typ des Medikaments
@HiveType(typeId: 9)
enum MedicationType {
  @HiveField(0)
  daily, // Tagesmedizin (feste Zeiten)

  @HiveField(1)
  asNeeded, // Bedarfsmedizin (nach Bedarf / PRN)
}

/// Medikament Model
@HiveType(typeId: 6)
class Medication {
  // Detaillierte Beschreibung für Unterscheidung

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timesOfDay,
    required this.profileIds,
    required this.createdAt,
    this.notes,
    this.type = MedicationType.daily,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.imagePath,
    this.description,
    this.maxDailyDoses,
    this.minIntervalHours,
    this.remindersEnabled = true,
  });

  /// Von Map erstellen
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      timesOfDay: List<String>.from(map['timesOfDay'] as List),
      profileIds: List<String>.from(map['profileIds'] as List),
      notes: map['notes'] as String?,
      type: map['type'] != null
          ? MedicationType.values.firstWhere(
              (t) => t.name == map['type'],
              orElse: () => MedicationType.daily,
            )
          : MedicationType.daily,
      isActive: map['isActive'] as bool? ?? true,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      imagePath: map['imagePath'] as String?,
      description: map['description'] as String?,
      maxDailyDoses: map['maxDailyDoses'] as int?,
      minIntervalHours: map['minIntervalHours'] as int?,
      remindersEnabled: map['remindersEnabled'] as bool? ?? true,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage; // z.B. "1 Tablette", "10mg", "5ml"

  @HiveField(3)
  final List<String> timesOfDay; // z.B. ["08:00", "20:00"]

  @HiveField(4)
  final List<String> profileIds; // Zugeordnete Profile

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final bool isActive; // false = archiviert

  @HiveField(7)
  final DateTime? startDate;

  @HiveField(8)
  final DateTime? endDate;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final String? imagePath; // Pfad zum Tablettenbild

  @HiveField(11)
  final String? description;

  @HiveField(12)
  final MedicationType type; // Tages- oder Bedarfsmedizin

  @HiveField(13)
  final int? maxDailyDoses; // Maximale Anzahl pro Tag (nur bei asNeeded)

  @HiveField(14)
  final int? minIntervalHours; // Mindestabstand zwischen Einnahmen in Stunden (nur bei asNeeded)

  /// Erinnert Aurora an dieses Medikament?
  ///
  /// Erinnerungen liefen bisher still im Hintergrund: Wer ein Medikament
  /// anlegte, bekam Meldungen, ohne dass das Formular sie je erwähnt hätte,
  /// und konnte sie einzeln nicht abstellen. Alte Einträge behalten das
  /// bisherige Verhalten, deshalb ist die Voreinstellung `true`.
  @HiveField(15)
  final bool remindersEnabled;

  /// Kopie mit geänderten Werten
  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    List<String>? timesOfDay,
    List<String>? profileIds,
    String? notes,
    MedicationType? type,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    String? imagePath,
    String? description,
    int? maxDailyDoses,
    int? minIntervalHours,
    bool? remindersEnabled,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      profileIds: profileIds ?? this.profileIds,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      maxDailyDoses: maxDailyDoses ?? this.maxDailyDoses,
      minIntervalHours: minIntervalHours ?? this.minIntervalHours,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }

  /// Zu Map konvertieren
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'timesOfDay': timesOfDay,
      'profileIds': profileIds,
      'notes': notes,
      'type': type.name,
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'description': description,
      'maxDailyDoses': maxDailyDoses,
      'minIntervalHours': minIntervalHours,
      'remindersEnabled': remindersEnabled,
    };
  }

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, dosage: $dosage, times: $timesOfDay, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Status der Medikamenten-Einnahme
@HiveType(typeId: 8)
enum MedicationStatus {
  @HiveField(0)
  taken, // Genommen ✓ (grün)

  @HiveField(1)
  refused, // Verweigert ✗ (rot)

  @HiveField(2)
  snoozed, // Später erinnern ⏰ (orange)

  @HiveField(3)
  skipped, // Nicht genommen (grau)
}

/// Medikamenten-Einnahme-Log
@HiveType(typeId: 7)
class MedicationLog {
  // Erfahrung/Feedback nach Einnahme

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.takenAt,
    required this.profileId,
    required this.status,
    this.confirmedAt,
    this.note,
    this.snoozedUntil,
    this.refusalNote,
    this.feedback,
    this.scheduledTime,
  });

  /// Von Map erstellen
  factory MedicationLog.fromMap(Map<String, dynamic> map) {
    return MedicationLog(
      id: map['id'] as String,
      medicationId: map['medicationId'] as String,
      takenAt: DateTime.parse(map['takenAt'] as String),
      profileId: map['profileId'] as String,
      status: MedicationStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => MedicationStatus.skipped,
      ),
      confirmedAt: map['confirmedAt'] != null
          ? DateTime.parse(map['confirmedAt'] as String)
          : null,
      note: map['note'] as String?,
      snoozedUntil: map['snoozedUntil'] != null
          ? DateTime.parse(map['snoozedUntil'] as String)
          : null,
      refusalNote: map['refusalNote'] as String?,
      feedback: map['feedback'] as String?,
      scheduledTime: map['scheduledTime'] as String?,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicationId;

  @HiveField(2)
  final DateTime takenAt; // Wann sollte es eingenommen werden

  @HiveField(3)
  final String profileId; // Wer hat den Status gesetzt

  @HiveField(4)
  final MedicationStatus status; // Status: genommen/verweigert/später/übersprungen

  @HiveField(5)
  final DateTime? confirmedAt; // Wann wurde Status gesetzt

  @HiveField(6)
  final String? note; // Optionale Notiz (deprecated, nutze refusalNote/feedback)

  @HiveField(7)
  final DateTime? snoozedUntil; // Bis wann ist "später" aktiv (1 Stunde)

  @HiveField(8)
  final String? refusalNote; // Notiz bei Verweigerung

  @HiveField(9)
  final String? feedback;

  @HiveField(10)
  final String? scheduledTime; // Geplante Einnahmezeit z.B. "08:00", "12:00"

  /// Kopie mit geänderten Werten
  MedicationLog copyWith({
    String? id,
    String? medicationId,
    DateTime? takenAt,
    String? profileId,
    MedicationStatus? status,
    DateTime? confirmedAt,
    String? note,
    DateTime? snoozedUntil,
    String? refusalNote,
    String? feedback,
    String? scheduledTime,
  }) {
    return MedicationLog(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      takenAt: takenAt ?? this.takenAt,
      profileId: profileId ?? this.profileId,
      status: status ?? this.status,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      note: note ?? this.note,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      refusalNote: refusalNote ?? this.refusalNote,
      feedback: feedback ?? this.feedback,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }

  /// Zu Map konvertieren
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationId': medicationId,
      'takenAt': takenAt.toIso8601String(),
      'profileId': profileId,
      'status': status.name,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'note': note,
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'refusalNote': refusalNote,
      'feedback': feedback,
      'scheduledTime': scheduledTime,
    };
  }

  @override
  String toString() {
    return 'MedicationLog(id: $id, medId: $medicationId, takenAt: $takenAt, status: ${status.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicationLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
