import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/reminders/reminder_scheduler.dart';
import 'package:meta/meta.dart';
import 'package:dis_app/services/tile_cache_manager.dart';
import 'package:dis_app/services/transmission_log_service.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Jede Box, die je Daten eines Menschen getragen hat.
///
/// Diese Liste ist der Löschumfang. Sie darf nicht kleiner sein als das, was
/// die App anlegt — `test/core/delete_all_data_test.dart` schlägt fehl,
/// sobald in [HiveBoxNames] ein Name auftaucht, der hier fehlt. Das ist kein
/// Formalismus: Genau diese Lücke hat den Standortverlauf und das
/// Übertragungsprotokoll ein „Alle Daten löschen" überleben lassen.
const List<String> deletableBoxNames = <String>[
  HiveBoxNames.chatMessages,
  HiveBoxNames.profiles,
  HiveBoxNames.calendarEvents,
  HiveBoxNames.medications,
  HiveBoxNames.medicationLogs,
  HiveBoxNames.contacts,
  HiveBoxNames.contactRatings,
  HiveBoxNames.contactComments,
  HiveBoxNames.finderItems,
  HiveBoxNames.diaryEntries,
  HiveBoxNames.diaryComments,
  HiveBoxNames.locationHistory,
  HiveBoxNames.profileSwitches,
  HiveBoxNames.notificationQueue,
  HiveBoxNames.transmissionLog,
  HiveBoxNames.telemetryQueue,
  HiveBoxNames.comments,
  HiveBoxNames.settings,
  ...HiveBoxNames.legacy,
];

/// Was ein Löschlauf erreicht hat.
///
/// Ein Teilerfolg ist kein Erfolg. Wer „Alle Daten löschen" antippt, trifft
/// eine Entscheidung über Gesundheitsdaten; ein grünes Häkchen über
/// verbliebenen Daten wäre eine Lüge an der Stelle, an der sie am meisten
/// wehtut.
class DeleteAllResult {
  const DeleteAllResult(this.failedSteps);

  /// Benannte Schritte, die nicht durchliefen. Ohne Pfade und ohne Inhalte —
  /// eine Fehlermeldung ist kein Ort für Dateinamen.
  final List<String> failedSteps;

  bool get isComplete => failedSteps.isEmpty;
}

/// Löscht alle lokalen Daten — aus den Einstellungen wie aus dem Notfall-Reset.
///
/// Die Funktion braucht **keine** funktionierende Anmeldung von Diensten.
/// Das ist Absicht: Der Notfall-Reset wird auf dem Splash-Screen ausgelöst,
/// also genau dann, wenn jemand unter Druck steht oder der Start klemmt. Ein
/// Löschweg, der einen geglückten Start voraussetzt, ist tot, wenn er
/// gebraucht wird. Alles, was hier über [getIt] läuft, läuft deshalb hinter
/// `isRegistered` und in einem eigenen Schritt.
///
/// Der Ablauf ist wiederholbar: Was schon weg ist, gilt als erledigt.
///
/// Das Ergebnis darf nicht verworfen werden — deshalb [useResult]. Eine der
/// drei Aufrufstellen hat es verworfen und danach neu gestartet; auf der
/// Fläche stand ein geglückter Start über Daten, die noch da waren.
@useResult
Future<DeleteAllResult> deleteAllLocalData() async {
  final failedSteps = <String>[];

  // Boxen, die ein Dienst selbst geleert hat. Sie bleiben offen und
  // benutzbar — die App läuft danach weiter, nur ohne Inhalte.
  final handled = <String>{};

  // 1. Erst die geplanten Meldungen. Andernfalls klingelt hinterher eine
  //    Erinnerung an ein Medikament, das es nicht mehr gibt.
  await _step('reminders', failedSteps, () async {
    if (!getIt.isRegistered<ReminderScheduler>()) return;
    await getIt<ReminderScheduler>().cancelEverything();
  });

  // 2. Dann die Dienste, damit ihre Listener von der Leerung erfahren.
  await _step('services', failedSteps, () async {
    if (!getIt.isRegistered<DataEntry>()) return;
    await getIt<DataEntry>().clearAllData();
    handled.addAll(const <String>[
      HiveBoxNames.chatMessages,
      HiveBoxNames.calendarEvents,
      HiveBoxNames.profiles,
      HiveBoxNames.settings,
      HiveBoxNames.medications,
      HiveBoxNames.medicationLogs,
      HiveBoxNames.contacts,
      HiveBoxNames.contactRatings,
      HiveBoxNames.contactComments,
      HiveBoxNames.finderItems,
      HiveBoxNames.diaryEntries,
      HiveBoxNames.diaryComments,
      HiveBoxNames.comments,
    ]);
  });

  await _step('tracking', failedSteps, () async {
    if (!getIt.isRegistered<LocationTrackingService>()) return;
    await getIt<LocationTrackingService>().clearAllData();
    handled
      ..add(HiveBoxNames.locationHistory)
      ..add(HiveBoxNames.profileSwitches);
  });

  await _step('transmissionLog', failedSteps, () async {
    if (!getIt.isRegistered<TransmissionLogService>()) return;
    await getIt<TransmissionLogService>().clear();
    handled.add(HiveBoxNames.transmissionLog);
  });

  // 3. Der Kehraus. Alles, was kein Dienst angefasst hat, kommt von der
  //    Platte — auch eine offene Box. Eine Box, die niemandem gehört, ist
  //    genau der Fall, der bisher stehenblieb; lieber verliert ein Dienst
  //    seine Referenz, als dass Gesundheitsdaten liegenbleiben.
  for (final name in deletableBoxNames) {
    if (handled.contains(name)) continue;
    await _step('box', failedSteps, () => Hive.deleteBoxFromDisk(name));
  }

  // 4. Anhänge: Bilder, Sprachnachrichten, Doodles, Avatare.
  await _step('attachments', failedSteps, AttachmentHelper.clearAll);

  // 5. Kartenkacheln verraten besuchte Orte genauso wie ein Standortverlauf.
  await _step('tileCache', failedSteps, () async {
    if (!getIt.isRegistered<TileCacheManager>()) return;
    await getIt<TileCacheManager>().clearCache();
  });

  // 6. Nachsehen statt behaupten.
  await _step('verify', failedSteps, () async {
    final ordner = AttachmentHelper.directory.value;
    if (ordner == null || !ordner.existsSync()) return;
    final reste = ordner.listSync();
    if (reste.isNotEmpty) {
      throw StateError('${reste.length} Anhänge übrig');
    }
  });

  final result = DeleteAllResult(List.unmodifiable(failedSteps));
  logger.warning(
    LogCategory.hive,
    result.isComplete
        ? 'Alle lokalen Daten geloescht'
        : 'Loeschen unvollstaendig',
    data: {'failedSteps': result.failedSteps},
  );
  return result;
}

/// Führt einen Schritt aus und merkt sich nur, ob er lief.
///
/// Kein Schritt darf die folgenden verhindern: Wenn das Abbrechen der
/// Meldungen scheitert, sollen die Daten trotzdem verschwinden.
Future<void> _step(
  String name,
  List<String> failedSteps,
  Future<void> Function() body,
) async {
  try {
    await body();
  } catch (e, stackTrace) {
    if (!failedSteps.contains(name)) failedSteps.add(name);
    logger.error(
      LogCategory.hive,
      'Loeschschritt fehlgeschlagen',
      data: {'step': name, 'error': e.toString()},
      stackTrace: stackTrace,
    );
  }
}
