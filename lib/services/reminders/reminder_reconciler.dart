import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/calendar_event.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/services/reminders/reminder.dart';
import 'package:dis_app/services/reminders/reminder_id.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:dis_app/services/reminders/reminder_scheduler.dart';
import 'package:dis_app/services/reminders/reminder_texts.dart';

/// Was ein Abgleich bewirkt hat.
class ReconcileResult {
  const ReconcileResult({
    required this.added,
    required this.removed,
    required this.kept,
    required this.dropped,
    this.succeeded = true,
    this.failedAtId,
    this.rounds = 1,
  });

  /// Ein Lauf, der nicht stattgefunden hat.
  const ReconcileResult.failed({this.failedAtId})
    : added = 0,
      removed = 0,
      kept = 0,
      dropped = 0,
      succeeded = false,
      rounds = 0;

  final int added;
  final int removed;
  final int kept;

  /// Wie viele Erinnerungen das Budget gekostet hat.
  final int dropped;

  /// Ob das Betriebssystem danach wirklich auf dem Sollstand ist.
  ///
  /// Ohne dieses Feld sah ein Fehlschlag aus wie ein Lauf ohne Änderungen:
  /// beide gaben lauter Nullen zurück. Der Aufrufer konnte nicht
  /// unterscheiden, ob nichts zu tun war oder nichts geklappt hat.
  final bool succeeded;

  /// Die Kennung, an der ein Lauf abbrach — nie ein Name.
  final int? failedAtId;

  /// Wie viele Runden dieser Aufruf gebraucht hat, bis die Daten still lagen.
  final int rounds;
}

/// Die Fassung, in der Meldungen auf dem Bildschirm stehen.
///
/// Eine vorgemerkte Meldung trägt ihren Wortlaut seit dem Vormerken mit sich.
/// Ändert sich die Sprache oder der Diskret-Schalter, ist jeder bereits
/// vorgemerkte Text falsch — und zwar unsichtbar, bis er erscheint. Deshalb
/// wird die Fassung mitgeführt und verglichen.
class ReminderPresentation {
  const ReminderPresentation({required this.localeTag, required this.discreet});

  final String localeTag;
  final bool discreet;

  @override
  bool operator ==(Object other) =>
      other is ReminderPresentation &&
      other.localeTag == localeTag &&
      other.discreet == discreet;

  @override
  int get hashCode => Object.hash(localeTag, discreet);
}

/// Bringt das Betriebssystem auf den berechneten Stand.
///
/// Die einzige Stelle, die Erinnerungen anmeldet oder abmeldet. Vorher war
/// das über neun Methoden verteilt, die einander nachliefen; wurde eine
/// Abbruchzeile vergessen, blieb ein Alarm als Karteileiche stehen — auf
/// dem Testgerät zehn Stück aus zwei vergangenen Tagen. Hier gibt es keine
/// Abbruchzeile mehr, nur eine Differenz.
class ReminderReconciler {
  ReminderReconciler({
    required ReminderScheduler scheduler,
    required List<Medication> Function() readMedications,
    required List<MedicationLog> Function() readLogs,
    required List<CalendarEvent> Function() readEvents,
    required Future<bool> Function() readPermission,
    required bool Function() readDiscreet,
    String Function()? readLocaleTag,
    DateTime Function() clock = DateTime.now,
  }) : _scheduler = scheduler,
       _readMedications = readMedications,
       _readLogs = readLogs,
       _readEvents = readEvents,
       _readPermission = readPermission,
       _readDiscreet = readDiscreet,
       _readLocaleTag = readLocaleTag ?? _currentLocaleTag,
       _clock = clock;

  static String _currentLocaleTag() => AppTexts.current.localeName;

  final ReminderScheduler _scheduler;
  final List<Medication> Function() _readMedications;
  final List<MedicationLog> Function() _readLogs;
  final List<CalendarEvent> Function() _readEvents;
  final Future<bool> Function() _readPermission;
  final bool Function() _readDiscreet;
  final String Function() _readLocaleTag;
  final DateTime Function() _clock;

  /// So oft wiederholt ein Aufruf höchstens.
  ///
  /// Ohne Grenze könnte ein Lauf, der selbst ein Ereignis auslöst, sich
  /// endlos nachlaufen. Fünf Runden reichen für jede reale Folge von
  /// Eingaben; was danach noch kommt, holt der nächste Aufruf.
  static const int _maxRounds = 5;

  Future<ReconcileResult>? _active;
  bool _rerunRequested = false;

  /// Die zuletzt **vollständig** angewendete Fassung.
  ///
  /// `null` heißt „unbekannt", nicht „unverändert". Genau daran hing ein
  /// stiller Fehler: Nach einem Teilausfall — und nach jedem Neustart —
  /// galt der Stand als unverändert, und die stehengebliebenen Klartexte
  /// wurden nie überschrieben. Unbekannt heißt jetzt: alles neu schreiben.
  ReminderPresentation? _lastApplied;

  /// Nach einem Teilausfall schreibt die nächste Runde alles neu.
  bool _needsFullRewrite = false;

  /// Gleicht ab und kommt erst zurück, wenn die Daten still liegen.
  ///
  /// Ein Aufruf während eines laufenden Abgleichs wird nicht mehr verworfen
  /// — er merkt eine weitere Runde vor. Vorher gewann der erste Lauf mit
  /// seinen bereits gelesenen Daten, und eine Einnahme, die eine
  /// Millisekunde zu spät kam, blieb bis zum nächsten App-Start
  /// unberücksichtigt.
  Future<ReconcileResult> reconcile() {
    _rerunRequested = true;
    return _active ??= _drain().whenComplete(() => _active = null);
  }

  Future<ReconcileResult> _drain() async {
    var result = const ReconcileResult(
      added: 0,
      removed: 0,
      kept: 0,
      dropped: 0,
      rounds: 0,
    );
    var rounds = 0;

    while (_rerunRequested && rounds < _maxRounds) {
      _rerunRequested = false;
      rounds++;
      result = await _runOnce(rounds: rounds);
    }

    if (_rerunRequested) {
      // Die Grenze hat gegriffen. Kein stilles Abschneiden: Wer das im
      // Log sieht, sucht die Quelle der Ereignisse, nicht den Abgleich.
      logger.warning(
        LogCategory.service,
        'ReminderReconciler: Rundengrenze erreicht',
        data: {'rounds': rounds},
      );
    }
    return result;
  }

  Future<ReconcileResult> _runOnce({required int rounds}) async {
    try {
      final medications = _readMedications();
      final events = _readEvents();
      var dropped = 0;

      final desired = desiredReminders(
        medications: medications,
        logs: _readLogs(),
        events: events,
        notificationsAllowed: await _readPermission(),
        now: _clock(),
        onDropped: (count) => dropped = count,
      );

      final presentation = ReminderPresentation(
        localeTag: _readLocaleTag(),
        discreet: _readDiscreet(),
      );
      final rewriteAll = _needsFullRewrite || _lastApplied != presentation;

      final desiredById = <int, Reminder>{
        for (final reminder in desired) reminderId(reminder): reminder,
      };
      final pending = await _scheduler.pendingOwnIds();

      final toRemove = pending.difference(desiredById.keys.toSet());
      final toAdd = rewriteAll
          ? desiredById.keys.toSet()
          : desiredById.keys.toSet().difference(pending);

      for (final id in toRemove) {
        await _scheduler.cancel(id);
      }

      final texts = ReminderTexts(discreet: presentation.discreet);
      final medById = {for (final m in medications) m.id: m};
      final eventById = {for (final e in events) e.id: e};
      var added = 0;
      var skipped = 0;
      for (final id in toAdd) {
        final reminder = desiredById[id]!;

        // Der Zieltyp entscheidet, welcher Text gilt. Kommt ein dritter
        // hinzu, meldet sich der Compiler — die sealed class lässt keinen
        // stillen Zweig zu.
        final body = switch (reminder.target) {
          DoseTarget(:final medicationId) =>
            medById[medicationId] == null
                ? null
                : texts.medicationBody(reminder, medById[medicationId]!),
          EventTarget(:final eventId) =>
            eventById[eventId] == null
                ? null
                : texts.eventBody(eventById[eventId]!),
        };
        if (body == null) {
          skipped++;
          continue;
        }

        try {
          await _scheduler.schedule(
            reminder,
            title: texts.title(reminder),
            body: body,
          );
        } catch (e, stackTrace) {
          // Ab hier stimmt der Bildschirm nicht mehr mit dem Sollstand
          // überein. Die Fassung darf deshalb **nicht** als angewendet
          // gelten, und die nächste Runde schreibt alles neu — sonst
          // blieben die restlichen Klartexte stehen, obwohl jemand auf
          // diskrete Erinnerungen umgeschaltet hat.
          _needsFullRewrite = true;
          logger.error(
            LogCategory.service,
            'ReminderReconciler: Anmelden fehlgeschlagen',
            data: {'failedAtId': id, 'applied': added, 'error': e.toString()},
            stackTrace: stackTrace,
          );
          return ReconcileResult.failed(failedAtId: id);
        }
        added++;
      }

      _lastApplied = presentation;
      _needsFullRewrite = false;

      final result = ReconcileResult(
        added: added,
        removed: toRemove.length,
        kept: pending.length - toRemove.length,
        dropped: dropped,
        rounds: rounds,
      );

      logger.info(
        LogCategory.service,
        'ReminderReconciler: abgeglichen',
        data: {
          'requested': desiredById.length,
          'applied': result.added,
          'removed': result.removed,
          'kept': result.kept,
          'dropped': result.dropped,
          'skipped': skipped,
          'rounds': rounds,
          'rewriteAll': rewriteAll,
        },
      );

      return result;
    } catch (e, stackTrace) {
      _needsFullRewrite = true;
      logger.error(
        LogCategory.service,
        'ReminderReconciler: Abgleich fehlgeschlagen',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      return const ReconcileResult.failed();
    }
  }
}
