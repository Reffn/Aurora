import 'dart:async';
import 'dart:io' show Platform;

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:dis_app/services/reminders/reminder_reconciler.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:dis_app/widgets/reminder_permission_sheet.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Merkt sich, dass der Systemdialog schon einmal offen war.
///
/// Die Plattform sagt das nicht verlässlich: Auf iOS ist die erste Ablehnung
/// endgültig, der Status bleibt aber `denied` — nicht zu unterscheiden von
/// „noch nie gefragt". Auf Android 13+ gilt dasselbe ab der zweiten
/// Ablehnung. Wer sich nicht selbst merkt, dass er gefragt hat, bietet
/// jahrelang einen Knopf an, der nichts mehr tut.
const String kReminderPermissionAskedKey = 'reminder_permission_asked';

/// Merkt sich, dass der Mensch auf Auroras eigenem Blatt „Jetzt nicht"
/// gesagt hat.
///
/// Danach fragt Aurora nicht mehr von sich aus — nicht beim nächsten
/// Speichern, nicht beim übernächsten. Das Blatt kommt dann nur noch, wenn
/// jemand selbst danach greift: am Schalter, am Erlaubnisband, an der Zeile
/// im Formular. Ein „Jetzt nicht", das bei jedem Speichern neu gestellt
/// wird, ist kein Angebot, sondern Nötigung.
const String kReminderPermissionPostponedKey = 'reminder_permission_postponed';

/// Wie die Frage nach der Erlaubnis ausgegangen ist
enum ReminderPermissionOutcome {
  /// Aurora darf erinnern.
  granted,

  /// Der Mensch hat auf Auroras Blatt „Jetzt nicht" gesagt. Das System wurde
  /// nicht gefragt; der Wunsch nach Erinnerungen wird zurückgenommen.
  declinedByPerson,

  /// Das Gerät verweigert — gerade eben oder schon früher. Der Wunsch bleibt
  /// stehen: Das Erlaubnisband auf der Medikamentenseite trägt den Weg.
  deniedBySystem,

  /// Kein Benachrichtigungsdienst da (Widget-Test, Startfehler).
  unavailable,
}

/// Darf Aurora gerade erinnern? Sieht nur nach, fragt nicht.
///
/// Für Formulare, die den Zustand zeigen wollen, bevor jemand speichert —
/// sie dürfen den Dienst nicht selbst anfassen (`no_direct_service_access`).
Future<bool> hasReminderPermission() async {
  if (!getIt.isRegistered<NotificationService>()) return false;
  return getIt<NotificationService>().hasPermission();
}

/// Holt die Erlaubnis für Benachrichtigungen ein und sagt nur, ob Aurora
/// danach erinnern darf. Für Stellen, denen das Wie gleich ist.
Future<bool> ensureReminderPermission(
  BuildContext context, {
  bool uninvited = false,
}) async {
  final outcome = await askReminderPermission(context, uninvited: uninvited);
  return outcome == ReminderPermissionOutcome.granted;
}

/// Holt die Erlaubnis für Benachrichtigungen ein — mit Auroras eigener
/// Erklärung vor dem Systemdialog.
///
/// Sechs Ablehnungen auf acht geplante Erinnerungen: Der nackte Dialog kam
/// ohne ein Wort davor, mitten im Speichern, und wer Nein sagte, bekam
/// sofort einen zweiten Systemschirm und ein oranges Band. Jetzt sagt
/// Aurora zuerst, warum sie fragt und was als Nächstes passiert; erst ein
/// „Ja" ruft das System. Die Entscheidung bleibt beim Menschen.
///
/// Ist der Systemdialog einmal verbraucht, kommt er nicht wieder — die
/// Plattform sagt das nicht verlässlich, deshalb merkt Aurora es sich
/// selbst ([kReminderPermissionAskedKey]). Dann führt der Weg über die
/// Einstellungen des Geräts, und das Blatt sagt genau das, statt einen
/// Knopf anzubieten, der nichts mehr tut.
///
/// [uninvited] heißt: Aurora fragt von sich aus, weil gerade ein
/// Versprechen gespeichert wird (Termin, Medikament mit Erinnerung). Wer
/// das einmal mit „Jetzt nicht" beantwortet hat, wird so nicht wieder
/// gefragt.
Future<ReminderPermissionOutcome> askReminderPermission(
  BuildContext context, {
  bool uninvited = false,
}) async {
  if (!getIt.isRegistered<NotificationService>()) {
    return ReminderPermissionOutcome.unavailable;
  }
  final service = getIt<NotificationService>();

  if (await service.hasPermission()) return ReminderPermissionOutcome.granted;

  // Ein früheres „Jetzt nicht" unterdrückt nur das ungefragte Blatt. Der
  // Zustand bleibt der des Geräts: Es verweigert. Der Wunsch nach
  // Erinnerungen bleibt also stehen, und das Erlaubnisband zeigt den Weg —
  // ein stilles `declinedByPerson` hätte hier den Schalter umgelegt, ohne
  // dass jemand etwas gesagt hat.
  if (uninvited && _postponed) return ReminderPermissionOutcome.deniedBySystem;

  // Der zweite Systemschirm („Wecker und Erinnerungen") wird nur
  // angekündigt, wo er kommen kann: auf Android, solange er fehlt.
  final showsExactAlarmStep =
      Platform.isAndroid && !(await service.canScheduleExactly());

  if (!context.mounted) return ReminderPermissionOutcome.declinedByPerson;
  final choice = await ReminderPermissionSheet.show(
    context,
    mode: _alreadyAsked
        ? ReminderSheetMode.settingsPath
        : ReminderSheetMode.ask,
    showsExactAlarmStep: showsExactAlarmStep,
  );

  switch (choice) {
    case null:
      // Weggewischt ist keine Entscheidung — nichts merken.
      return ReminderPermissionOutcome.declinedByPerson;
    case ReminderSheetChoice.notNow:
      _remember(kReminderPermissionPostponedKey, true);
      return ReminderPermissionOutcome.declinedByPerson;
    case ReminderSheetChoice.openSettings:
      unawaited(openAppSettings());
      return ReminderPermissionOutcome.deniedBySystem;
    case ReminderSheetChoice.yes:
      break;
  }

  // Ein Ja hebt ein früheres „Jetzt nicht" auf. Und erst hier, unmittelbar
  // vor dem Systemdialog, gilt er als verbraucht — nicht bei „Jetzt nicht",
  // das hätte den einen Schuss verschenkt.
  _remember(kReminderPermissionPostponedKey, false);
  _remember(kReminderPermissionAskedKey, true);
  final granted = await service.requestPermissions();

  if (granted) {
    // Wer die Erlaubnis erst jetzt gibt, hat vorher womöglich schon
    // Medikamente angelegt. Der Abgleich holt sie nach.
    if (getIt.isRegistered<ReminderReconciler>()) {
      await getIt<ReminderReconciler>().reconcile();
    }
    return ReminderPermissionOutcome.granted;
  }

  // Eine Ablehnung hier ist kein Geschmack, sondern eine kaputte Funktion:
  // Ohne Benachrichtigungen ist eine Medikamenten-App ohne Erinnerungen —
  // ein plausibler Loeschgrund, den sonst niemand je erfaehrt. Gemeldet
  // wird nur das Nein im Systemdialog, nicht das „Jetzt nicht" auf Auroras
  // Blatt — sonst änderte sich die Bedeutung des Ereignisses unter gleichem
  // Namen. Nur diese eine Berechtigung wird gemeldet; Kamera, Mikrofon und
  // Ort abzulehnen ist eine Vorliebe und geht niemanden etwas an.
  if (getIt.isRegistered<TelemetryRecorder>()) {
    unawaited(
      getIt<TelemetryRecorder>().record(
        TelemetryEventName.berechtigungVerweigertBenachrichtigungen,
      ),
    );
  }

  if (!context.mounted) return ReminderPermissionOutcome.deniedBySystem;

  // Kein oranges Band mehr: Ein ruhiges Blatt sagt, was jetzt gilt, und
  // der Weg, der noch offen ist, steht als Handlung darauf.
  final after = await ReminderPermissionSheet.show(
    context,
    mode: ReminderSheetMode.denied,
  );
  if (after == ReminderSheetChoice.openSettings) {
    unawaited(openAppSettings());
  }
  return ReminderPermissionOutcome.deniedBySystem;
}

bool get _alreadyAsked => _flag(kReminderPermissionAskedKey);

bool get _postponed => _flag(kReminderPermissionPostponedKey);

bool _flag(String key) {
  if (!getIt.isRegistered<ProfileService>()) return false;
  return getIt<ProfileService>().settingsBox.get(key, defaultValue: false)
      as bool;
}

void _remember(String key, bool value) {
  if (!getIt.isRegistered<ProfileService>()) return;
  getIt<ProfileService>().settingsBox.put(key, value);
}
