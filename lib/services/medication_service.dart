import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/events/medication_events.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/comment_service.dart';
import 'package:hive_ce/hive.dart';

/// Medication-Service - Verwaltet Medikamente und Einnahme-Logs
/// Verwendet Hive ValueListenable für reaktive UI-Updates
class MedicationService extends BaseService {
  MedicationService(super.eventBus);
  late Box<Medication> _medicationsBox;
  late Box<MedicationLog> _logsBox;

  @override
  Future<void> openBoxes() async {
    // PARALLEL: Öffne beide Boxes gleichzeitig für bessere Performance
    final results = await Future.wait([
      Hive.openBox<Medication>(HiveBoxNames.medications),
      Hive.openBox<MedicationLog>(HiveBoxNames.medicationLogs),
    ]);

    _medicationsBox = results[0] as Box<Medication>;
    _logsBox = results[1] as Box<MedicationLog>;
  }

  @override
  void subscribeToEvents() {
    eventBus.on<MedicationCreatedEvent>().listen(_handleMedicationCreated);
    eventBus.on<MedicationUpdatedEvent>().listen(_handleMedicationUpdated);
    eventBus.on<MedicationDeletedEvent>().listen(_handleMedicationDeleted);
    eventBus.on<MedicationTakenEvent>().listen(_handleMedicationTaken);
    eventBus.on<MedicationLogUpdatedEvent>().listen(_handleLogUpdated);
    eventBus.on<MedicationLogDeletedEvent>().listen(_handleLogDeleted);
  }

  @override
  Future<void> closeBoxes() async {
    await _medicationsBox.close();
    await _logsBox.close();
  }

  /// Zugriff auf Medications-Box für ValueListenable
  Box<Medication> get medicationsBox => _medicationsBox;

  /// Zugriff auf Logs-Box für ValueListenable
  Box<MedicationLog> get logsBox => _logsBox;

  /// Alle Medikamente abrufen (nur aktive)
  List<Medication> get activeMedications =>
      _medicationsBox.values.where((med) => med.isActive).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  /// Alle Medikamente abrufen (inkl. inaktive)
  List<Medication> get allMedications => List.unmodifiable(
    _medicationsBox.values.toList()..sort((a, b) => a.name.compareTo(b.name)),
  );

  /// Medikamente für heute abrufen (aktive Medikamente)
  List<Medication> getTodaysMedications() {
    final today = DateTime.now();
    return activeMedications.where((med) {
      // Prüfen ob Medikament heute eingenommen werden soll
      if (med.startDate != null && today.isBefore(med.startDate!)) {
        return false; // Noch nicht gestartet
      }
      if (med.endDate != null && today.isAfter(med.endDate!)) {
        return false; // Bereits beendet
      }
      return true;
    }).toList();
  }

  /// Medikament nach ID abrufen
  Medication? getMedicationById(String id) {
    try {
      return _medicationsBox.values.firstWhere((med) => med.id == id);
    } catch (e) {
      logger.warning(
        LogCategory.service,
        'Medication not found',
        data: {'medicationId': id},
      );
      return null;
    }
  }

  /// Heutigen Status für ein Medikament abrufen
  MedicationStatus? getStatusToday(String medicationId, String timeOfDay) {
    final log = getTodaysLog(medicationId, timeOfDay);
    return log?.status;
  }

  /// Prüfen ob Medikament heute gesnoozed ist (und bis wann)
  DateTime? getSnoozedUntil(String medicationId, String timeOfDay) {
    final log = getTodaysLog(medicationId, timeOfDay);
    if (log?.status == MedicationStatus.snoozed) {
      return log?.snoozedUntil;
    }
    return null;
  }

  /// Heutigen Log für ein Medikament + Zeitpunkt abrufen
  MedicationLog? getTodaysLog(String medicationId, String timeOfDay) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    try {
      return _logsBox.values.firstWhere((log) {
        return log.medicationId == medicationId &&
            log.scheduledTime == timeOfDay &&
            log.takenAt.isAfter(todayStart) &&
            log.takenAt.isBefore(todayEnd);
      });
    } catch (e) {
      return null; // Kein Log für heute gefunden
    }
  }

  /// Alle Feedbacks für ein Medikament abrufen
  List<MedicationLog> getFeedbacksForMedication(String medicationId) {
    return _logsBox.values
        .where(
          (log) =>
              log.medicationId == medicationId &&
              log.feedback != null &&
              log.feedback!.isNotEmpty,
        )
        .toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt)); // Neueste zuerst
  }

  /// Logs für ein bestimmtes Medikament abrufen
  List<MedicationLog> getLogsForMedication(String medicationId) {
    return _logsBox.values
        .where((log) => log.medicationId == medicationId)
        .toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt)); // Neueste zuerst
  }

  /// Logs für einen Zeitraum abrufen
  List<MedicationLog> getLogsForDateRange(DateTime start, DateTime end) {
    return _logsBox.values
        .where((log) => log.takenAt.isAfter(start) && log.takenAt.isBefore(end))
        .toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  // ============ Bedarfsmedizin-Methoden ============

  /// Heutige Einnahmen eines Bedarfsmedikaments
  List<MedicationLog> getTodaysAsNeededLogs(String medicationId) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _logsBox.values
        .where(
          (log) =>
              log.medicationId == medicationId &&
              log.status == MedicationStatus.taken &&
              log.takenAt.isAfter(todayStart) &&
              log.takenAt.isBefore(todayEnd),
        )
        .toList()
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt)); // Älteste zuerst
  }

  /// Verfügbare Dosen heute (für Bedarfsmedizin)
  int getAvailableDoses(Medication medication) {
    if (medication.type != MedicationType.asNeeded ||
        medication.maxDailyDoses == null) {
      return 0;
    }

    final todaysLogs = getTodaysAsNeededLogs(medication.id);
    final taken = todaysLogs.length;
    final available = medication.maxDailyDoses! - taken;

    return available < 0 ? 0 : available;
  }

  /// Nächste erlaubte Einnahme-Zeit (für Bedarfsmedizin mit Mindestabstand)
  DateTime? getNextAllowedTime(Medication medication) {
    if (medication.type != MedicationType.asNeeded) {
      return null;
    }

    // Wenn kein Mindestabstand definiert, sofort erlaubt
    if (medication.minIntervalHours == null ||
        medication.minIntervalHours == 0) {
      return DateTime.now();
    }

    // Letzte Einnahme finden
    final todaysLogs = getTodaysAsNeededLogs(medication.id);
    if (todaysLogs.isEmpty) {
      return DateTime.now(); // Noch nicht genommen heute, sofort erlaubt
    }

    // Letzte Einnahme + Mindestabstand
    final lastTaken = todaysLogs.last.takenAt;
    final nextAllowed = lastTaken.add(
      Duration(hours: medication.minIntervalHours!),
    );

    return nextAllowed;
  }

  /// Kann Bedarfsmedikament jetzt genommen werden?
  bool canTakeNow(Medication medication) {
    if (medication.type != MedicationType.asNeeded) {
      return false;
    }

    // Prüfe Tageslimit
    if (medication.maxDailyDoses != null) {
      final available = getAvailableDoses(medication);
      if (available <= 0) {
        return false; // Limit erreicht
      }
    }

    // Prüfe Mindestabstand
    if (medication.minIntervalHours != null &&
        medication.minIntervalHours! > 0) {
      final nextAllowed = getNextAllowedTime(medication);
      if (nextAllowed != null && DateTime.now().isBefore(nextAllowed)) {
        return false; // Mindestabstand noch nicht abgelaufen
      }
    }

    return true;
  }

  /// Medikament erstellt
  void _handleMedicationCreated(MedicationCreatedEvent event) {
    _medicationsBox.put(event.medication.id, event.medication);
    // Hive notified automatisch alle ValueListenable Listener!
  }

  /// Medikament aktualisiert
  void _handleMedicationUpdated(MedicationUpdatedEvent event) {
    if (_medicationsBox.containsKey(event.medication.id)) {
      _medicationsBox.put(event.medication.id, event.medication);
      // Hive notified automatisch alle ValueListenable Listener!
    }
  }

  /// Medikament gelöscht
  void _handleMedicationDeleted(MedicationDeletedEvent event) {
    _medicationsBox.delete(event.medicationId);

    // Cascade delete: Alle unified Comments löschen
    final commentService = getIt<CommentService>();
    commentService.deleteCommentsForParent(
      CommentableType.medication,
      event.medicationId,
    );

    // Hive notified automatisch alle ValueListenable Listener!
  }

  /// Medikamenten-Einnahme geloggt
  void _handleMedicationTaken(MedicationTakenEvent event) {
    _logsBox.put(event.log.id, event.log);
    // Hive notified automatisch alle ValueListenable Listener!
  }

  /// Log aktualisiert
  void _handleLogUpdated(MedicationLogUpdatedEvent event) {
    if (_logsBox.containsKey(event.log.id)) {
      _logsBox.put(event.log.id, event.log);
      // Hive notified automatisch alle ValueListenable Listener!
    }
  }

  /// Log gelöscht
  void _handleLogDeleted(MedicationLogDeletedEvent event) {
    _logsBox.delete(event.logId);
    // Hive notified automatisch alle ValueListenable Listener!
  }

  /// Alle Medikamente und Logs löschen (Debug-Option)
  Future<void> clearAll() async {
    await _medicationsBox.clear();
    await _logsBox.clear();
    // Hive notified automatisch alle ValueListenable Listener!
  }
}
