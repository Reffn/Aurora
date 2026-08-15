import 'dart:async';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:dis_app/services/reminders/reminder_reconciler.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:dis_app/utils/snackbar_helper.dart';
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

/// Holt die Erlaubnis für Benachrichtigungen ein, wenn jemand eine
/// Erinnerung einschaltet.
///
/// Der Systemdialog gehört an diese eine Stelle: den Moment, in dem ein
/// Mensch „erinnere mich" antippt. Vorher fragte der NotificationService
/// selbst — beim Speichern eines Termins, beim Anlegen eines Medikaments —
/// und der Android-Dialog sprang mitten in einer Handlung auf, die mit
/// Berechtigungen nichts zu tun hatte.
///
/// Ist die Entscheidung einmal gefallen, kommt der Dialog nicht wieder. Dann
/// führt der einzige Weg über die Systemeinstellungen, und genau dorthin
/// zeigt die Meldung — plattformneutral, weil der Pfad auf iOS anders heißt
/// als auf Android.
///
/// Gibt `true` zurück, wenn Aurora danach erinnern darf.
Future<bool> ensureReminderPermission(BuildContext context) async {
  if (!getIt.isRegistered<NotificationService>()) return false;
  final service = getIt<NotificationService>();

  if (await service.hasPermission()) return true;

  if (!_alreadyAsked) {
    _rememberAsked();
    final granted = await service.requestPermissions();

    // Eine Ablehnung hier ist kein Geschmack, sondern eine kaputte Funktion:
    // Ohne Benachrichtigungen ist eine Medikamenten-App ohne Erinnerungen —
    // ein plausibler Loeschgrund, den sonst niemand je erfaehrt. Nur diese
    // eine Berechtigung wird gemeldet; Kamera, Mikrofon und Ort abzulehnen
    // ist eine Vorliebe und geht niemanden etwas an.
    if (!granted && getIt.isRegistered<TelemetryRecorder>()) {
      unawaited(
        getIt<TelemetryRecorder>().record(
          TelemetryEventName.berechtigungVerweigertBenachrichtigungen,
        ),
      );
    }
    if (granted) {
      // Wer die Erlaubnis erst jetzt gibt, hat vorher womöglich schon
      // Medikamente angelegt. Der Abgleich holt sie nach.
      await getIt<ReminderReconciler>().reconcile();
      return true;
    }
  }

  if (!context.mounted) return false;

  // Kein wirkungsloser zweiter Versuch mehr: Der Weg, der noch offen ist,
  // steht als Handlung daneben.
  context.showCustomSnackBar(
    AppTexts.current.reminderPermissionBlocked,
    backgroundColor: Colors.orange,
    duration: const Duration(seconds: 6),
    action: SnackBarAction(
      label: AppTexts.current.reminderOpenSettings,
      onPressed: openAppSettings,
    ),
  );
  return false;
}

bool get _alreadyAsked {
  if (!getIt.isRegistered<ProfileService>()) return false;
  return getIt<ProfileService>().settingsBox.get(
        kReminderPermissionAskedKey,
        defaultValue: false,
      )
      as bool;
}

void _rememberAsked() {
  if (!getIt.isRegistered<ProfileService>()) return;
  getIt<ProfileService>().settingsBox.put(kReminderPermissionAskedKey, true);
}
