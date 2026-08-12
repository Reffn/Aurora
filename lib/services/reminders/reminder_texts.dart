import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';

/// Was auf dem Bildschirm steht.
///
/// Eine Erinnerung erscheint auf dem Sperrbildschirm, also auch vor Augen,
/// die nicht dafür gedacht sind. „Ritalin 10mg jetzt nehmen" ist ein
/// Gesundheitsdatum, „Termin bei Dr. Berg" ebenfalls. Der Schalter für
/// diskrete Erinnerungen entscheidet hier — und nur hier.
class ReminderTexts {
  ReminderTexts({required this.discreet});

  final bool discreet;

  String title(Reminder reminder) {
    final l10n = AppTexts.current;
    if (discreet) return 'Aurora';
    switch (reminder.kind) {
      case ReminderKind.event:
        return l10n.notificationEventReminder;
      case ReminderKind.available:
        return reminder.repeatIndex == 0
            ? l10n.notificationMedicationAvailableNow
            : l10n.notificationMedicationAvailableSoon;
      case ReminderKind.due:
      case ReminderKind.snooze:
        return l10n.notificationMedicationTakeNowTitle;
      case ReminderKind.before30:
      case ReminderKind.before10:
      case ReminderKind.repeat:
        return l10n.notificationMedicationReminder;
    }
  }

  String medicationBody(Reminder reminder, Medication medication) {
    final l10n = AppTexts.current;
    if (discreet) return l10n.notificationDiscreetBody;

    switch (reminder.kind) {
      case ReminderKind.available:
        return l10n.notificationMedicationAvailableBody(medication.name);
      case ReminderKind.before30:
      case ReminderKind.before10:
        return l10n.notificationMedicationBodyWithTime(
          medication.name,
          medication.dosage,
          reminder.dose?.scheduledTime ?? '',
        );
      case ReminderKind.repeat:
        return '${l10n.notificationMedicationBodyNow(medication.name, medication.dosage)}'
            ' - ${l10n.notificationMedicationNotTakenYet}';
      case ReminderKind.due:
      case ReminderKind.snooze:
      case ReminderKind.event:
        return l10n.notificationMedicationBodyNow(
          medication.name,
          medication.dosage,
        );
    }
  }

  String eventBody(CalendarEvent event) {
    final l10n = AppTexts.current;
    if (discreet) return l10n.notificationDiscreetBody;
    return l10n.notificationEventBody(
      event.title,
      _leadTime(event.reminderMinutesBefore ?? 0),
    );
  }

  /// „in 15 Minuten", „in 1 Stunde", „in 2 Stunden", „jetzt".
  String _leadTime(int minutes) {
    final l10n = AppTexts.current;
    if (minutes <= 0) return l10n.notificationTimeNow;
    if (minutes < 60) return l10n.notificationTimeInMinutes(minutes);
    if (minutes == 60) return l10n.notificationTimeIn1Hour;
    if (minutes < 1440) return l10n.notificationTimeInHours(minutes ~/ 60);
    return l10n.notificationTimeInHours(minutes ~/ 60);
  }
}
