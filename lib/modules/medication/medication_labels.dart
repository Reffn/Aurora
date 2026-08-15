import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/medication.dart';

/// Die Wörter für Medikamentenart und Einnahmestatus.
///
/// Sie standen vorher als `label`-Getter im Modell, also in der Datei, die
/// beschreibt, wie ein Medikament gespeichert wird. Ein Datenmodell kennt
/// aber keine Sprache: Es wird einmal geschrieben und viele Jahre später
/// wieder gelesen, womöglich mit einer anderen Spracheinstellung. Deshalb
/// stehen die Wörter hier, wo die Oberfläche zu Hause ist, und werden bei
/// jedem Aufruf neu aus AppLocalizations geholt.
extension MedicationTypeLabel on MedicationType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case MedicationType.daily:
        return l10n.medicationTypeDailyTitle;
      case MedicationType.asNeeded:
        return l10n.medicationTypeAsNeededTitle;
    }
  }
}

extension MedicationStatusLabel on MedicationStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case MedicationStatus.taken:
        return l10n.medicationStatusTaken;
      case MedicationStatus.refused:
        return l10n.medicationStatusRefused;
      case MedicationStatus.snoozed:
        return l10n.medicationStatusSnoozed;
      case MedicationStatus.skipped:
        return l10n.medicationStatusSkipped;
    }
  }
}
