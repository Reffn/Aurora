import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Sagt, wenn Aurora ein Versprechen nicht halten kann.
///
/// Auf dem Testgerät stand der Schalter „Aurora erinnert dich" auf an, die
/// Medikamentenkarte trug ein Weckersymbol, und im Alarmspeicher lag
/// nichts. Im Protokoll eine einzige Zeile: „Nothing rescheduled — still
/// no permission". Was ein Mensch nicht sehen kann, kann er nicht in
/// Ordnung bringen — und wer die Erlaubnis einmal abgelehnt hat, wird nie
/// wieder gefragt, solange er kein neues Medikament anlegt.
///
/// Kein Rot: die Farbregel aus `docs/oberflaechen-richtlinien.md`
/// reserviert Sättigung für das, was im schlechtesten Zustand gefunden
/// werden muss. Ruhig, aber nicht zu übersehen.
class ReminderPermissionBanner extends StatelessWidget {
  const ReminderPermissionBanner({
    required this.hasPermission,
    required this.openPromises,
    required this.onRequest,
    super.key,
  });

  /// Darf Aurora Benachrichtigungen zeigen?
  final bool hasPermission;

  /// Wie viele Einnahmezeiten tragen „Erinnerungen an", ohne dass etwas
  /// geplant ist.
  final int openPromises;

  /// Führt zum Systemdialog oder in die Einstellungen.
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    // Ohne offenes Versprechen gibt es nichts zu melden. Ein Band, das
    // auch dann steht, wenn niemand etwas erwartet, ist Lärm.
    if (hasPermission || openPromises == 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surfaceContainerHighest,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_off_outlined, color: scheme.onSurface),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.reminderPermissionMissingTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.reminderPermissionMissingBody(openPromises)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRequest,
                child: Text(l10n.reminderPermissionMissingAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
