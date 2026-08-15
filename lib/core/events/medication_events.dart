import 'package:dis_app/core/events/app_event.dart';
import 'package:dis_app/models/medication.dart';

/// Event: Neues Medikament wurde erstellt
class MedicationCreatedEvent extends AppEvent {
  MedicationCreatedEvent(this.medication);
  final Medication medication;
}

/// Event: Medikament wurde aktualisiert
class MedicationUpdatedEvent extends AppEvent {
  MedicationUpdatedEvent(this.medication);
  final Medication medication;
}

/// Event: Medikament wurde gelöscht
class MedicationDeletedEvent extends AppEvent {
  MedicationDeletedEvent(this.medicationId);
  final String medicationId;
}

/// Event: Medikamenten-Einnahme wurde geloggt
class MedicationTakenEvent extends AppEvent {
  MedicationTakenEvent(this.log);
  final MedicationLog log;
}

/// Event: Medikamenten-Log wurde aktualisiert
class MedicationLogUpdatedEvent extends AppEvent {
  MedicationLogUpdatedEvent(this.log);
  final MedicationLog log;
}

/// Event: Medikamenten-Log wurde gelöscht
class MedicationLogDeletedEvent extends AppEvent {
  MedicationLogDeletedEvent(this.logId);
  final String logId;
}
