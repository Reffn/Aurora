import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// In welcher Lage das Blatt gezeigt wird
enum ReminderSheetMode {
  /// Noch nie gefragt: Aurora erklärt, dann fragt das System.
  ask,

  /// Der Systemdialog ist verbraucht; der Weg führt nur noch über die
  /// Einstellungen des Geräts.
  settingsPath,

  /// Das System hat gerade Nein gesagt.
  denied,
}

/// Was der Mensch auf dem Blatt gewählt hat
enum ReminderSheetChoice { yes, openSettings, notNow }

/// Auroras eigene Erklärung, bevor das System nach der Erlaubnis fragt.
///
/// Sechs Ablehnungen auf acht geplante Erinnerungen: Der nackte Android-
/// Dialog sprang mitten ins Speichern, ohne ein Wort davor, und wer dort
/// Nein sagte, bekam sofort einen zweiten Systemschirm und danach ein
/// oranges Band. Dieses Blatt sagt vorher, warum Aurora fragt und was als
/// Nächstes passiert (Richtlinie 10), und lässt die Entscheidung beim
/// Menschen.
///
/// Das Bild trägt, das Wort bestätigt (Richtlinie 5): große Glocke oben,
/// jede Wahl mit Symbol und Wort, 64 dp hoch. Keine gesättigte Fläche —
/// eine fehlende Erlaubnis ist kein Notfall (Richtlinie 4).
class ReminderPermissionSheet extends StatelessWidget {
  const ReminderPermissionSheet({
    required this.mode,
    this.showsExactAlarmStep = false,
    super.key,
  });

  final ReminderSheetMode mode;

  /// Ob nach dem Benachrichtigungs-Dialog noch die Systemseite „Wecker und
  /// Erinnerungen" kommen kann. Nur Android, und nur solange sie fehlt —
  /// ein Schritt, der nicht kommt, wird auch nicht angekündigt.
  final bool showsExactAlarmStep;

  /// Zeigt das Blatt und liefert die Wahl; `null` heißt weggewischt.
  static Future<ReminderSheetChoice?> show(
    BuildContext context, {
    required ReminderSheetMode mode,
    bool showsExactAlarmStep = false,
  }) {
    return showModalBottomSheet<ReminderSheetChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => ReminderPermissionSheet(
        mode: mode,
        showsExactAlarmStep: showsExactAlarmStep,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final asking = mode == ReminderSheetMode.ask;

    final title = asking
        ? l10n.reminderAskTitle
        : l10n.reminderPermissionMissingTitle;
    final body = switch (mode) {
      ReminderSheetMode.ask => l10n.reminderAskBody,
      ReminderSheetMode.settingsPath => l10n.reminderSettingsPathBody,
      ReminderSheetMode.denied => l10n.reminderDeniedBody,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHighest,
              ),
              child: Icon(
                asking
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                size: 52,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: text.titleLarge),
          const SizedBox(height: 12),
          Text(body, textAlign: TextAlign.center, style: text.bodyLarge),
          if (asking) ...[
            const SizedBox(height: 20),
            _StepRow(
              icon: Icons.phone_android_outlined,
              text: l10n.reminderAskStepNotifications,
            ),
            if (showsExactAlarmStep) ...[
              const SizedBox(height: 12),
              _StepRow(
                icon: Icons.alarm_outlined,
                text: l10n.reminderAskStepExactAlarms,
              ),
            ],
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 64,
            child: asking
                ? FilledButton.tonalIcon(
                    key: const ValueKey('reminder-sheet-yes'),
                    onPressed: () =>
                        Navigator.pop(context, ReminderSheetChoice.yes),
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(
                      l10n.reminderAskYes,
                      style: const TextStyle(fontSize: 18),
                    ),
                  )
                : FilledButton.tonalIcon(
                    key: const ValueKey('reminder-sheet-settings'),
                    onPressed: () => Navigator.pop(
                      context,
                      ReminderSheetChoice.openSettings,
                    ),
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(
                      l10n.reminderOpenSettings,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: OutlinedButton.icon(
              key: ValueKey(
                asking ? 'reminder-sheet-not-now' : 'reminder-sheet-later',
              ),
              onPressed: () =>
                  Navigator.pop(context, ReminderSheetChoice.notNow),
              icon: const Icon(Icons.close),
              label: Text(
                asking ? l10n.reminderAskNotNow : l10n.reminderLater,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ein Schritt dessen, was gleich passiert: Symbol links, Satz rechts.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surfaceContainerHighest,
          ),
          child: Icon(icon, size: 24, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

/// Die Zeile im Formular, wenn die Erlaubnis fehlt.
///
/// Steht unter dem Erinnerungs-Schalter und sagt, bevor gespeichert wird,
/// dass das Versprechen so nicht gehalten wird — mit dem Weg daneben. Ein
/// Formular, das „Aurora meldet sich" verspricht, während das Gerät es
/// verbietet, lügt (Richtlinie 10: sagen, was wirklich passiert).
class ReminderNotAllowedRow extends StatelessWidget {
  const ReminderNotAllowedRow({
    required this.onRequest,
    this.message,
    super.key,
  });

  final VoidCallback onRequest;

  /// Ersetzt den Formular-Satz. Auf einer Detailseite ist längst
  /// gespeichert — „Gespeichert wird trotzdem" wäre dort falsch.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message ?? l10n.reminderFormNotAllowed,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            key: const ValueKey('reminder-form-request'),
            onPressed: onRequest,
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(l10n.reminderPermissionMissingAction),
          ),
        ),
      ],
    );
  }
}
