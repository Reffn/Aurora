import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/medication/medication_detail_screen.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/widgets/medication_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Card für Bedarfsmedizin mit Quick-Take-Button
class AsNeededMedicationCard extends StatelessWidget {
  const AsNeededMedicationCard({
    required this.medication,
    super.key,
  });

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataEntry = getIt<DataEntry>();

    // Verfügbarkeit berechnen
    final availableDoses = dataEntry.getAvailableDoses(medication);
    final maxDoses = medication.maxDailyDoses ?? 0;
    final canTake = dataEntry.canTakeNow(medication);
    final nextAllowed = dataEntry.getNextAllowedTime(medication);
    final todaysLogs = dataEntry.getTodaysAsNeededLogs(medication.id);
    final lastLog = todaysLogs.isNotEmpty ? todaysLogs.last : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => MedicationDetailScreen(
                medicationId: medication.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar + Name + Dosierung + Button
              Row(
                children: [
                  // Medikamenten-Avatar (Pillenform)
                  MedicationAvatar(
                    imagePath: medication.imagePath,
                    name: medication.name,
                    width: 60,
                    height: 30,
                    statusColor: canTake
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                    showShadow: false,
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medication.dosage,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Quick-Take Button
                  FilledButton.icon(
                    onPressed: canTake
                        ? () => _handleQuickTake(context, dataEntry)
                        : null,
                    icon: const Icon(Icons.medication),
                    label: Text(l10n.medicationTake),
                    style: FilledButton.styleFrom(
                      backgroundColor: availableDoses > 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Verfügbarkeit
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.medicationDoseCountToday(availableDoses, maxDoses),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Letzte Einnahme
              if (lastLog != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.medicationLastTaken(
                        DateFormat('HH:mm').format(lastLog.takenAt),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],

              // Nächste erlaubte Zeit (wenn blockiert durch Intervall)
              if (!canTake &&
                  nextAllowed != null &&
                  DateTime.now().isBefore(nextAllowed)) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.medicationNextPossible(
                        DateFormat('HH:mm').format(nextAllowed),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],

              // Warnung bei Limit erreicht
              if (availableDoses <= 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.medicationDailyLimitReached,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Beschreibung (optional)
              if (medication.description != null &&
                  medication.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  medication.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Notizen (optional)
              if (medication.notes != null && medication.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.medicationNoteLabel(medication.notes!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Quick-Take-Handler: Zeigt Warnung wenn nötig, erstellt sonst direkt Log
  Future<void> _handleQuickTake(
    BuildContext context,
    DataEntry dataEntry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final availableDoses = dataEntry.getAvailableDoses(medication);

    // Wenn Limit erreicht: Warnung zeigen
    if (availableDoses <= 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.medicationDailyLimitReached),
          content: Text(
            '${l10n.medicationLimitWarning(
              medication.maxDailyDoses ?? 0,
              medication.name,
            )}\n\n${l10n.medicationAnotherDose}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.medicationTakeAnyway),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    // Log erstellen
    final currentProfile = dataEntry.getActiveProfile();
    if (currentProfile == null) {
      if (!context.mounted) return;
      showCustomSnackBar(
        context,
        message: l10n.medicationNoProfileSelected,
        type: SnackBarType.error,
      );
      return;
    }

    // Permission check
    if (!currentProfile.hasPermission(Permission.logMedication)) {
      if (!context.mounted) return;
      showCustomSnackBar(
        context,
        message: l10n.medicationNoLogPermission,
        type: SnackBarType.error,
      );
      return;
    }

    final log = MedicationLog(
      id: const Uuid().v4(),
      medicationId: medication.id,
      takenAt: DateTime.now(),
      confirmedAt: DateTime.now(),
      profileId: currentProfile.id,
      status: MedicationStatus.taken,
    );

    // Via DataEntry speichern
    await dataEntry.logMedicationTaken(log);

    if (!context.mounted) return;
    showCustomSnackBar(
      context,
      message: l10n.medicationTakenConfirmation(medication.name),
      type: SnackBarType.success,
    );
  }
}
