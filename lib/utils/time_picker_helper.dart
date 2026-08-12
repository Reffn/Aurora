import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

/// Zeigt einen iOS-Style Wheel Time Picker mit konfigurierbarem Format
///
/// Nutzt Einstellungen aus settingsBox:
/// - 'time_format_preference': "system" (Standard), "12h", oder "24h"
///
/// Features:
/// - Vertikale Scroll-Räder (iOS-Style)
/// - Respektiert System-Zeitformat als Standard
/// - Überschreibbar durch User-Einstellung
/// - Highlight-Box, Labels, Separator, Icon
Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  // Erst den Eingabefokus loslassen, dann das Rad zeigen.
  //
  // Ohne diese Zeile kehrt der Fokus nach dem Schließen ins zuletzt
  // beschriebene Textfeld zurück und die Tastatur springt auf. Wer danach
  // scrollt, wischt über die Tastatur und schreibt Ziffern in das Feld —
  // im Gerätetest am 07.08.2026 zweimal reproduziert: aus „1 Tablette"
  // wurde „1 Tablette55".
  FocusManager.instance.primaryFocus?.unfocus();

  final profileService = getIt<ProfileService>();
  final settingsBox = profileService.settingsBox;

  // Zeit-Format-Präferenz aus Settings laden
  final timeFormatPref =
      settingsBox.get('time_format_preference', defaultValue: 'system')
          as String;

  // Bestimme ob 24h-Format verwendet werden soll
  bool use24HourFormat;

  switch (timeFormatPref) {
    case '12h':
      use24HourFormat = false;
    case '24h':
      use24HourFormat = true;
    case 'system':
    default:
      // Nutze System-Einstellung
      use24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
  }

  // Konvertiere initialTime zu DateTime für den Spinner
  final now = DateTime.now();
  final initialDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    initialTime.hour,
    initialTime.minute,
  );

  DateTime? selectedDateTime;

  final result = await showDialog<TimeOfDay>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Theme.of(dialogContext).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(AppTexts.current.timePickerTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Die Spaltenueberschriften standen fest auf Deutsch. In einer
            // englischen Oberflaeche las sich der Waehler dann als
            // „Choose a time / Stunden : Minuten".
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Text(
                      AppTexts.current.timePickerHours,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(dialogContext).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      AppTexts.current.timePickerMinutes,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(dialogContext).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Highlight-Box mit Spinner
            Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(
                color: Theme.of(
                  dialogContext,
                ).colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    dialogContext,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Highlight-Bereich für ausgewählte Zeit
                  Positioned(
                    top: 70,
                    child: Container(
                      height: 60,
                      width: 280,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          dialogContext,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            dialogContext,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Doppelpunkt-Separator
                  Positioned(
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(dialogContext).colorScheme.primary,
                      ),
                    ),
                  ),

                  // TimePickerSpinner
                  TimePickerSpinner(
                    time: initialDateTime,
                    is24HourMode: use24HourFormat,
                    normalTextStyle: TextStyle(
                      fontSize: 24,
                      color: Theme.of(
                        dialogContext,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    highlightedTextStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(dialogContext).colorScheme.primary,
                    ),
                    spacing: 40,
                    itemHeight: 60,
                    isForce2Digits: true,
                    onTimeChange: (time) {
                      selectedDateTime = time;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(dialogContext).actionCancel),
          ),
          FilledButton(
            onPressed: () {
              final timeToReturn = selectedDateTime ?? initialDateTime;
              final timeOfDay = TimeOfDay(
                hour: timeToReturn.hour,
                minute: timeToReturn.minute,
              );
              Navigator.of(dialogContext).pop(timeOfDay);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );

  return result;
}
