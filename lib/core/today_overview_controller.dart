import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/calendar_events.dart';
import 'package:dis_app/core/events/medication_events.dart';
import 'package:flutter/foundation.dart';

/// Das Lesemodell hinter der Tagesübersicht.
///
/// Die Zeile im Anker beantwortet zwei Fragen: Wie viele Termine hat der Tag,
/// und wie viele Medikamente stehen an. Sie lag vorher direkt auf den
/// Hive-Boxen von `CalendarService` und `MedicationService` — die Oberfläche
/// griff also an `DataEntry` vorbei, obwohl genau das die eine Tür für
/// Lesezugriffe ist. Auffallen konnte es niemandem: Die Lint-Regel
/// `no_direct_service_access` sah `lib/modules/` und `lib/widgets/`, aber
/// nicht `main.dart`.
///
/// Hier liegt der Zugriff jetzt. Die Oberfläche kennt nur noch diesen
/// Controller: ein Listenable und zwei Zahlen.
class TodayOverviewController extends ChangeNotifier {
  TodayOverviewController({
    required DataEntry dataEntry,
    required EventBus eventBus,
  }) : _dataEntry = dataEntry {
    // Auf Ereignisse statt auf Boxen: Der Controller weiß dadurch nicht, wo
    // die Daten liegen, und die Zeile bleibt trotzdem aktuell, wenn ein
    // Termin angelegt oder ein Medikament abgesetzt wird.
    _subscriptions.addAll([
      eventBus.on<CalendarEventCreatedEvent>().listen(_changed),
      eventBus.on<CalendarEventUpdatedEvent>().listen(_changed),
      eventBus.on<CalendarEventDeletedEvent>().listen(_changed),
      eventBus.on<MedicationCreatedEvent>().listen(_changed),
      eventBus.on<MedicationUpdatedEvent>().listen(_changed),
      eventBus.on<MedicationDeletedEvent>().listen(_changed),
      eventBus.on<MedicationTakenEvent>().listen(_changed),
      eventBus.on<MedicationLogUpdatedEvent>().listen(_changed),
    ]);
  }

  final DataEntry _dataEntry;
  final List<StreamSubscription<void>> _subscriptions = [];

  void _changed(void _) => notifyListeners();

  int countEventsForDay(DateTime day) =>
      _dataEntry.getCalendarEventsForDay(day).length;

  int countMedicationsToday() => _dataEntry.getTodaysMedications().length;

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
