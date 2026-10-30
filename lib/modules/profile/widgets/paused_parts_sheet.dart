import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';

// Hier stand auch das Blatt „Pausierte Anteile“, geöffnet aus einer Zeile
// unter dem Raster der Auswahl. Die Auswahl steht aber nur da, wenn niemand
// angemeldet ist, und dann darf niemand zurückholen: Die Zeile war am Gerät
// nie zu sehen (Regel 30). Der Rückweg ist „Anteile & Rechte“ unter
// „Pausiert“. Geblieben ist, was dort und in „Rückgängig“ gebraucht wird.

/// Holt [profile] zurück und sagt es. Gibt zurück, ob es geklappt hat.
///
/// `false` heißt hier fast immer „schon wieder da", etwa nach einem zweiten
/// Tipp. Das ist kein Fehler, also kommt auch keine Meldung.
///
/// Erst zurückholen, dann nach dem Kontext fragen: Die Snackbar mit
/// „Rückgängig" überlebt den Schirm, der sie gezeigt hat. Ist er weg, holt
/// der Tipp den Anteil trotzdem zurück, nur die zweite Meldung entfällt.
Future<bool> resumePausedPart(BuildContext context, Profile profile) async {
  final bool back;
  try {
    back = await getIt<DataEntry>().resumeProfile(profile.id);
  } on Object catch (e, stackTrace) {
    logger.error(
      LogCategory.ui,
      'Resuming a part failed',
      data: {'error': e.toString()},
      stackTrace: stackTrace,
    );
    if (context.mounted) {
      showCustomSnackBar(
        context,
        message: AppLocalizations.of(context).errorGeneric(e.toString()),
        type: SnackBarType.error,
      );
    }
    return false;
  }
  if (back && context.mounted) {
    showCustomSnackBar(
      context,
      message: AppLocalizations.of(context).profileResumedSnack(profile.name),
      icon: Icons.play_circle_outline,
    );
  }
  return back;
}
