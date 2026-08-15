import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';

/// Wie viele Wiederholungen nach der Einnahmezeit, im Abstand von zehn
/// Minuten. Vorher war die Wiederholung unbegrenzt: wer schlief, fand
/// morgens vierzig Meldungen.
const int kMaxRepeats = 3;

/// Wie lange „später" aufschiebt, wenn die Einnahmezeit schon vorbei ist.
const Duration kSnoozeAfterDue = Duration(minutes: 30);

/// Abstand, den eine aufgeschobene Erinnerung zur nächsten Dosis hält.
const Duration kSnoozeGuard = Duration(minutes: 5);

/// Vorlaufzeiten der Freigabe-Erinnerung bei Bedarfsmedizin.
const List<Duration> kAvailabilityOffsets = [
  Duration(minutes: 30),
  Duration(minutes: 10),
  Duration(minutes: 5),
  Duration.zero,
];

/// Was erinnert werden soll — abgeleitet, nicht nachgeführt.
///
/// Rein: keine Uhr, kein Hive, kein Plugin. Alles, was die Antwort
/// beeinflusst, steht in der Signatur. Deshalb ist jede Regel mit einer
/// festen Uhr prüfbar — und deshalb kann keine Abbruchzeile mehr vergessen
/// werden: es gibt keine.
///
/// Vorher wurde der Soll-Zustand an jeder Ereignisstelle einzeln von Hand
/// nachgezogen. „Genommen" räumte nur die Wiederholungen ab und ließ die
/// Vorwarnungen stehen; „später" meldete gar nichts beim Betriebssystem an.
/// Beides sind hier Regeln, keine Aufrufe.
Set<Reminder> desiredReminders({
  required List<Medication> medications,
  required List<MedicationLog> logs,
  required bool notificationsAllowed,
  List<CalendarEvent> events = const [],
  required DateTime now,
  Duration horizon = const Duration(hours: 36),
  Duration dueHorizon = const Duration(days: 7),
  int budget = 56,
  void Function(int count)? onDropped,
}) {
  // R1: Ohne Erlaubnis gibt es nichts zu planen. Kein stilles `return`
  // mitten im Code — die Oberfläche liest denselben Zustand und sagt es.
  if (!notificationsAllowed) {
    onDropped?.call(0);
    return const <Reminder>{};
  }

  // R5: Der Schlüssel enthält bewusst kein Profil. Siehe [DoseTarget].
  final byDose = _latestLogByDose(logs);
  final result = <Reminder>{};
  final detailUntil = now.add(horizon);
  final dueUntil = now.add(dueHorizon);

  for (final medication in medications) {
    if (!medication.isActive || !medication.remindersEnabled) continue;

    // R6: Bedarfsmedizin kennt keine festen Zeiten, nur einen
    // Mindestabstand nach der letzten Einnahme.
    if (medication.type == MedicationType.asNeeded) {
      result.addAll(_availabilityFor(medication, logs, now));
      continue;
    }

    if (medication.type != MedicationType.daily) continue;

    for (final dose in _dosesInWindow(medication, now, dueUntil)) {
      final log = byDose[dose];

      // R3: Eine erledigte Dosis erzeugt nichts mehr.
      if (_isSettled(log)) continue;

      // R4: Ein Aufschub ersetzt alle übrigen Erinnerungen dieser Dosis.
      if (log != null && log.status == MedicationStatus.snoozed) {
        final ziel = _snoozeTarget(
          dose: dose,
          tappedAt: log.confirmedAt ?? log.takenAt,
          nextDoseAt: _nextDoseAfter(medication, dose.at),
        );
        if (ziel.isAfter(now)) {
          result.add(
            Reminder(target: dose, kind: ReminderKind.snooze, fireAt: ziel),
          );
        }
        continue;
      }

      // Die Meldung zur Einnahmezeit reicht sieben Tage weit.
      if (dose.at.isAfter(now)) {
        result.add(
          Reminder(target: dose, kind: ReminderKind.due, fireAt: dose.at),
        );
      }

      // R2: Zwei Vorwarnungen und drei Wiederholungen, aber nur im
      // kurzen Horizont — sie kosten fünfmal so viele Vormerkungen.
      if (!dose.at.isAfter(detailUntil)) {
        result.addAll(_singleShotFor(dose, now));
      }
    }
  }

  for (final event in events) {
    final reminder = _eventReminder(event, now);
    if (reminder != null) result.add(reminder);
  }

  return _applyBudget(result, budget, onDropped);
}

/// Die eine Erinnerung eines Termins.
///
/// Termine kennen keine Wiederholungen und keine Bestätigung — es gibt
/// nichts abzuhaken, nur etwas rechtzeitig zu wissen. Deshalb genau eine
/// Meldung, und kein Sieben-Tage-Deckel: ein Termin in drei Wochen bekommt
/// seine Vormerkung sofort, denn er ist ein Einzeltermin und kostet eine
/// einzige.
Reminder? _eventReminder(CalendarEvent event, DateTime now) {
  final lead =
      event.reminderMinutesBefore ?? defaultCalendarEventReminderMinutes;

  // Ein vergangener Termin erinnert an nichts mehr.
  if (!event.startTime.isAfter(now)) return null;

  final fireAt = event.startTime.subtract(Duration(minutes: lead));

  // Die Vorwarnzeit kann vorbei sein, obwohl der Termin noch bevorsteht —
  // wer um 15:50 einen Termin für 16:00 mit einer Stunde Vorlauf anlegt,
  // bekommt keine Meldung mehr. Der alte Dienst sagte dazu „Event reminder
  // time has passed"; hier ist es dieselbe Entscheidung, nur als Regel.
  if (!fireAt.isAfter(now)) return null;

  return Reminder(
    target: EventTarget(eventId: event.id, startTime: event.startTime),
    kind: ReminderKind.event,
    fireAt: fireAt,
  );
}

/// Wann Aurora nach einem „später" für diese Dosis erinnert.
///
/// Die Oberfläche schreibt den Wert als `snoozedUntil` in den Log und
/// zeigt ihn auf der Karte an. Ohne diese gemeinsame Stelle rechnete sie
/// „+1 Stunde", während die Regeln etwas anderes planen — die Karte
/// verspräche dann eine Zeit, zu der nichts passiert.
DateTime snoozeTargetFor({
  required Medication medication,
  required String scheduledTime,
  required DateTime tappedAt,
}) {
  final dose = DoseTarget(
    medicationId: medication.id,
    date: DateTime(tappedAt.year, tappedAt.month, tappedAt.day),
    scheduledTime: scheduledTime,
  );
  return _snoozeTarget(
    dose: dose,
    tappedAt: tappedAt,
    nextDoseAt: _nextDoseAfter(medication, dose.at),
  );
}

/// Gilt das Medikament an diesem Tag?
bool _appliesOn(Medication medication, DateTime day) {
  final start = medication.startDate;
  final end = medication.endDate;
  if (start != null &&
      day.isBefore(DateTime(start.year, start.month, start.day))) {
    return false;
  }
  if (end != null && day.isAfter(DateTime(end.year, end.month, end.day))) {
    return false;
  }
  return true;
}

/// Alle Dosen dieses Medikaments zwischen [from] und [until].
List<DoseTarget> _dosesInWindow(
  Medication medication,
  DateTime from,
  DateTime until,
) {
  final doses = <DoseTarget>[];

  // Einen Tag zurück anfangen.
  //
  // Wer um 23:50 auf die 22-Uhr-Dosis „später" tippt, bekommt ein Ziel um
  // 00:20 am Folgetag. Begänne das Fenster erst heute, fiele die Dosis von
  // gestern heraus und die Meldung verschwände Punkt Mitternacht — dieselbe
  // Art von stiller Lücke wie Befund 3. Alles, was in der Vergangenheit
  // liegt, filtert der Zeitvergleich ohnehin weg.
  var day = DateTime(
    from.year,
    from.month,
    from.day,
  ).subtract(const Duration(days: 1));
  final lastDay = DateTime(until.year, until.month, until.day);
  while (!day.isAfter(lastDay)) {
    if (_appliesOn(medication, day)) {
      for (final time in medication.timesOfDay) {
        doses.add(
          DoseTarget(
            medicationId: medication.id,
            date: day,
            scheduledTime: time,
          ),
        );
      }
    }
    day = day.add(const Duration(days: 1));
  }
  return doses;
}

/// Die Vorwarnungen und Wiederholungen einer Dosis.
///
/// Die Meldung zur Dosiszeit selbst entsteht in [desiredReminders] und
/// reicht weiter in die Zukunft — sie ist die Ebene, die auch nach Tagen
/// ohne geöffnete App noch trägt.
Set<Reminder> _singleShotFor(DoseTarget dose, DateTime now) {
  final at = dose.at;
  final candidates = <Reminder>{
    Reminder(
      target: dose,
      kind: ReminderKind.before30,
      fireAt: at.subtract(const Duration(minutes: 30)),
    ),
    Reminder(
      target: dose,
      kind: ReminderKind.before10,
      fireAt: at.subtract(const Duration(minutes: 10)),
    ),
    for (var i = 1; i <= kMaxRepeats; i++)
      Reminder(
        target: dose,
        kind: ReminderKind.repeat,
        fireAt: at.add(Duration(minutes: 10 * i)),
        repeatIndex: i,
      ),
  };
  return candidates.where((r) => r.fireAt.isAfter(now)).toSet();
}

/// Der jüngste Log je Dosis.
///
/// „Jünger" heißt: zuletzt bestätigt. Wer sich vertippt und korrigiert,
/// soll die Korrektur wirksam sehen — deshalb entscheidet `confirmedAt`,
/// nicht die Reihenfolge in der Box.
Map<DoseTarget, MedicationLog> _latestLogByDose(List<MedicationLog> logs) {
  final result = <DoseTarget, MedicationLog>{};
  for (final log in logs) {
    final time = log.scheduledTime;
    if (time == null) continue; // Bedarfsmedizin, siehe R6
    final dose = DoseTarget(
      medicationId: log.medicationId,
      date: DateTime(log.takenAt.year, log.takenAt.month, log.takenAt.day),
      scheduledTime: time,
    );
    final existing = result[dose];
    final stamp = log.confirmedAt ?? log.takenAt;
    final existingStamp = existing == null
        ? null
        : existing.confirmedAt ?? existing.takenAt;
    if (existingStamp == null || stamp.isAfter(existingStamp)) {
      result[dose] = log;
    }
  }
  return result;
}

/// Ist diese Dosis abgeschlossen? Aufschub zählt nicht dazu.
bool _isSettled(MedicationLog? log) =>
    log != null &&
    (log.status == MedicationStatus.taken ||
        log.status == MedicationStatus.refused ||
        log.status == MedicationStatus.skipped);

/// Wann erinnert Aurora nach einem „später"?
///
/// Wer **vor** der Einnahmezeit aufschiebt, meint „nicht jetzt" — und
/// nicht „nach der Einnahmezeit". Deshalb rückt die Erinnerung auf die
/// Dosiszeit, statt sich dahinter zu schieben. Auf dem Gerät war es
/// umgekehrt: Tippen um 12:21 auf die 30-Minuten-Vorwarnung ergab 13:21,
/// die Dosis war für 12:50 gedacht.
DateTime _snoozeTarget({
  required DoseTarget dose,
  required DateTime tappedAt,
  required DateTime? nextDoseAt,
}) {
  final due = dose.at;
  if (tappedAt.isBefore(due)) return due;
  var target = tappedAt.add(kSnoozeAfterDue);
  if (nextDoseAt != null) {
    final guard = nextDoseAt.subtract(kSnoozeGuard);
    if (target.isAfter(guard)) target = guard;
  }
  return target;
}

/// Die nächste Dosiszeit desselben Medikaments nach [after].
DateTime? _nextDoseAfter(Medication medication, DateTime after) {
  DateTime? best;
  for (var dayOffset = 0; dayOffset <= 1; dayOffset++) {
    final day = DateTime(
      after.year,
      after.month,
      after.day,
    ).add(Duration(days: dayOffset));
    if (!_appliesOn(medication, day)) continue;
    for (final time in medication.timesOfDay) {
      final at = DoseTarget(
        medicationId: medication.id,
        date: day,
        scheduledTime: time,
      ).at;
      if (at.isAfter(after) && (best == null || at.isBefore(best))) {
        best = at;
      }
    }
  }
  return best;
}

/// Freigabe-Erinnerungen für ein Bedarfsmedikament.
///
/// Wer ein Mittel nur bei Bedarf nimmt, wartet zwischen zwei Dosen einen
/// Mindestabstand ab. Diese Erinnerungen sagen, wann er vorbei ist —
/// abgeleitet aus den Einnahmen, nicht beim Nehmen von Hand gesetzt.
Set<Reminder> _availabilityFor(
  Medication medication,
  List<MedicationLog> logs,
  DateTime now,
) {
  final interval = medication.minIntervalHours;
  if (interval == null || interval == 0) return const <Reminder>{};

  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final takenToday =
      logs
          .where(
            (log) =>
                log.medicationId == medication.id &&
                log.status == MedicationStatus.taken &&
                !log.takenAt.isBefore(today) &&
                log.takenAt.isBefore(tomorrow),
          )
          .toList()
        ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

  if (takenToday.isEmpty) return const <Reminder>{};

  final max = medication.maxDailyDoses;
  if (max != null && takenToday.length >= max) return const <Reminder>{};

  final last = takenToday.last.takenAt;
  final free = last.add(Duration(hours: interval));
  final dose = DoseTarget(
    medicationId: medication.id,
    date: DateTime(free.year, free.month, free.day),
    scheduledTime:
        'prn-${free.hour.toString().padLeft(2, '0')}:'
        '${free.minute.toString().padLeft(2, '0')}',
  );

  return kAvailabilityOffsets
      .map(
        (offset) => Reminder(
          target: dose,
          kind: ReminderKind.available,
          fireAt: free.subtract(offset),
          repeatIndex: offset.inMinutes,
        ),
      )
      .where((r) => r.fireAt.isAfter(now))
      .toSet();
}

/// Kürzt auf das Budget und sagt, was dabei wegfiel.
///
/// iOS merkt höchstens 64 Meldungen vor. Was darüber liegt, verschwände
/// stillschweigend — eine unbemerkte Kürzung liest sich wie
/// Vollständigkeit.
///
/// Reihenfolge: erst die Meldungen zur Einnahmezeit, dann die Termine,
/// dann die Vorwarnungen. Eine Vorwarnung zu verlieren kostet Vorlauf; die
/// Meldung selbst zu verlieren kostet die Dosis, und einen Arzttermin zu
/// verlieren kostet den Termin.
Set<Reminder> _applyBudget(
  Set<Reminder> all,
  int budget,
  void Function(int count)? onDropped,
) {
  if (all.length <= budget) {
    onDropped?.call(0);
    return all;
  }

  final zurEinnahmezeit = all.where((r) => r.kind == ReminderKind.due).toList()
    ..sort((a, b) => a.fireAt.compareTo(b.fireAt));
  final termine = all.where((r) => r.kind == ReminderKind.event).toList()
    ..sort((a, b) => a.fireAt.compareTo(b.fireAt));
  final rest =
      all
          .where(
            (r) => r.kind != ReminderKind.due && r.kind != ReminderKind.event,
          )
          .toList()
        ..sort((a, b) => a.fireAt.compareTo(b.fireAt));

  final kept = <Reminder>{...zurEinnahmezeit.take(budget)};
  for (final reminder in [...termine, ...rest]) {
    if (kept.length >= budget) break;
    kept.add(reminder);
  }

  onDropped?.call(all.length - kept.length);
  return kept;
}
