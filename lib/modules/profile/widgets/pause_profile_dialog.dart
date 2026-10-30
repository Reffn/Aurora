import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/widgets/paused_parts_sheet.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';

/// Fragt, ob [profile] pausiert werden soll, pausiert ihn und bietet danach
/// „Rückgängig" an.
///
/// Pausieren ist die Antwort auf „Wie entferne ich einen Anteil?": Er
/// verschwindet aus der Auswahl, aber nichts geht verloren, und der Rückweg
/// steht sichtbar in „Anteile & Rechte“ unter „Pausiert“. Deshalb heißt der
/// Knopf nie „Löschen" und trägt keine Warnfarbe.
///
/// [context] muss den Dialog überdauern. Snackbar und Rückgängig laufen
/// darüber, wenn der Dialog längst zu ist.
Future<void> showPauseProfileDialog(
  BuildContext context,
  Profile profile,
) async {
  final l10n = AppLocalizations.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1F1F1F),
      title: Row(
        children: [
          // Wer pausiert wird, ist ohne Lesen erkennbar.
          ProfileAvatar(
            profile: profile,
            size: 48,
            avatarSize: AvatarSize.small,
            showName: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.profilePauseTitle(profile.name),
              style: const TextStyle(color: AppColors.paper),
            ),
          ),
        ],
      ),
      content: Text(
        l10n.profilePauseMessage(profile.name),
        style: TextStyle(
          color: AppColors.paper.withValues(alpha: 0.8),
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            l10n.actionCancel,
            style: const TextStyle(color: AppColors.paper),
          ),
        ),
        // Ruhig und hell statt in der Anteilsfarbe: Eine kräftige Fläche
        // gehört Halt, Notfall und Hilfe (Richtlinie 4).
        FilledButton.icon(
          onPressed: () => Navigator.pop(dialogContext, true),
          icon: const Icon(Icons.pause_circle_outline),
          label: Text(l10n.profilePauseAction),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.paper,
            foregroundColor: AppColors.inkDeep,
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final bool paused;
  try {
    paused = await getIt<DataEntry>().pauseProfile(profile.id);
  } on Object catch (e, stackTrace) {
    logger.error(
      LogCategory.ui,
      'Pausing a part failed',
      data: {'error': e.toString()},
      stackTrace: stackTrace,
    );
    if (context.mounted) {
      showCustomSnackBar(
        context,
        message: l10n.errorGeneric(e.toString()),
        type: SnackBarType.error,
      );
    }
    return;
  }
  if (!context.mounted) return;

  if (!paused) {
    // Angeboten wird der Knopf nur mit Recht. Hier landet nur, wem es
    // zwischen Anzeigen und Tippen genommen wurde.
    showCustomSnackBar(context, message: l10n.commonNoPermission);
    return;
  }

  showCustomSnackBar(
    context,
    message: l10n.profilePausedSnack(profile.name),
    icon: Icons.pause_circle_outline,
    // Länger als üblich: Rückgängig soll ohne Eile erreichbar sein
    // (Richtlinie 10). Der dauerhafte Rückweg bleibt „Anteile & Rechte“.
    duration: const Duration(seconds: 8),
    actionLabel: l10n.actionUndo,
    actionIcon: Icons.undo,
    onAction: () => unawaited(resumePausedPart(context, profile)),
  );
}
