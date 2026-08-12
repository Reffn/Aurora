import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/medication/medication_detail_screen.dart';
import 'package:dis_app/modules/medication/widgets/as_needed_medication_card.dart';
import 'package:dis_app/modules/medication/widgets/medication_card.dart';
import 'package:dis_app/modules/medication/widgets/medication_feedback_dialog.dart';
import 'package:dis_app/modules/medication/widgets/reminder_permission_banner.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:dis_app/services/reminders/reminder_rules.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/reminder_permission.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/animated_empty_state.dart';
import 'package:dis_app/widgets/animated_list_view.dart';
import 'package:dis_app/widgets/permission_guard.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Medikamentenplaner - Hauptansicht
/// Zeigt heutige Medikamente und Einnahme-Status
class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  late final DataEntry _dataEntry;

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();
  }

  /// Medikament als genommen markieren
  Future<void> _markAsTaken(Medication medication, String timeOfDay) async {
    final l10n = AppLocalizations.of(context);
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return;

    // Permission check
    if (!activeProfile.hasPermission(Permission.logMedication)) {
      showNoPermissionSnackBar(context, Permission.logMedication);
      return;
    }

    final log = MedicationLog(
      id: const Uuid().v4(),
      medicationId: medication.id,
      takenAt: DateTime.now(),
      profileId: activeProfile.id,
      status: MedicationStatus.taken,
      confirmedAt: DateTime.now(),
      scheduledTime: timeOfDay,
    );

    try {
      await _dataEntry.logMedicationTaken(log);
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.medicationMarkedTaken(medication.name),
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.errorGeneric(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  /// Medikament als verweigert markieren (mit optionaler Notiz)
  Future<void> _markAsRefused(Medication medication, String timeOfDay) async {
    final l10n = AppLocalizations.of(context);
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return;

    // Permission check
    if (!activeProfile.hasPermission(Permission.logMedication)) {
      showNoPermissionSnackBar(context, Permission.logMedication);
      return;
    }

    // Dialog für optionale Notiz mit dynamischem Button
    final textController = TextEditingController();
    final refusalNote = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          // Dieselbe Vorsorge wie in MedicationFeedbackDialog: Auf realen
          // Geräten passt der Inhalt, aber ein Dialog mit Eingabefeld soll
          // auch dann tragen, wenn er wächst oder die Schrift größer wird.
          scrollable: true,
          title: Text(l10n.medicationRefusalTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.medicationWillBeRefused(medication.name)),
              const SizedBox(height: 16),
              AuroraTextField(
                label: l10n.medicationRefusalReasonLabel,
                controller: textController,
                hint: l10n.medicationRefusalReasonHint,
                maxLines: 3,
                maxLength: 200,
                onChanged: (value) => setState(() {}), // Button-Update triggern
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, textController.text),
              icon: const Icon(Icons.cancel, size: 18),
              label: Text(
                textController.text.trim().isEmpty
                    ? l10n.medicationRefusalWithoutNote
                    : l10n.medicationConfirm,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.medicationRefused,
              ),
            ),
          ],
        ),
      ),
    );

    if (refusalNote == null) return; // Abgebrochen

    final log = MedicationLog(
      id: const Uuid().v4(),
      medicationId: medication.id,
      takenAt: DateTime.now(),
      profileId: activeProfile.id,
      status: MedicationStatus.refused,
      confirmedAt: DateTime.now(),
      refusalNote: refusalNote.isEmpty ? null : refusalNote,
      scheduledTime: timeOfDay,
    );

    try {
      await _dataEntry.logMedicationTaken(log);
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.medicationMarkedRefused(medication.name),
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.errorGeneric(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  /// Medikament aufschieben — wie lange, entscheiden die Erinnerungsregeln
  Future<void> _snoozeMedication(
    Medication medication,
    String timeOfDay,
  ) async {
    final l10n = AppLocalizations.of(context);
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return;

    // Permission check
    if (!activeProfile.hasPermission(Permission.logMedication)) {
      showNoPermissionSnackBar(context, Permission.logMedication);
      return;
    }

    // Dieselbe Rechnung wie die Erinnerungsregeln, nicht eine zweite.
    //
    // Hier stand `DateTime.now().add(const Duration(hours: 1))`. Wer um
    // 12:21 auf die 30-Minuten-Vorwarnung tippte, bekam 13:21 angezeigt —
    // für eine Dosis, die um 12:50 fällig war. Der Aufschub schob die
    // Erinnerung hinter die Einnahmezeit, und die Karte versprach eine
    // Zeit, zu der nichts passierte.
    final snoozedUntil = snoozeTargetFor(
      medication: medication,
      scheduledTime: timeOfDay,
      tappedAt: DateTime.now(),
    );

    final log = MedicationLog(
      id: const Uuid().v4(),
      medicationId: medication.id,
      takenAt: DateTime.now(),
      profileId: activeProfile.id,
      status: MedicationStatus.snoozed,
      confirmedAt: DateTime.now(),
      snoozedUntil: snoozedUntil,
      scheduledTime: timeOfDay,
    );

    try {
      await _dataEntry.logMedicationTaken(log);
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.medicationSnoozedUntil(
            medication.name,
            '${snoozedUntil.hour.toString().padLeft(2, '0')}:'
            '${snoozedUntil.minute.toString().padLeft(2, '0')}',
          ),
          type: SnackBarType.warning,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.errorGeneric(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  /// Feedback hinzufügen
  Future<void> _addFeedback(Medication medication, String timeOfDay) async {
    final l10n = AppLocalizations.of(context);
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return;

    final existingLog = _dataEntry.getTodaysLog(medication.id, timeOfDay);
    if (existingLog == null) return;

    // Dialog für Feedback
    final feedback = await showDialog<String>(
      context: context,
      builder: (context) =>
          MedicationFeedbackDialog(medicationName: medication.name),
    );

    if (feedback == null || feedback.isEmpty) return;

    // Log aktualisieren mit Feedback
    final updatedLog = existingLog.copyWith(feedback: feedback);

    try {
      await _dataEntry.logMedicationTaken(updatedLog);
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.medicationFeedbackSaved,
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.errorGeneric(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  /// Feedback vollständig ansehen
  void _viewFeedback(String feedback) {
    final l10n = AppLocalizations.of(context);
    showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.medicationFeedbackViewTitle),
        content: Text(feedback),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }

  /// Medikament bearbeiten
  void _viewMedicationDetails(Medication medication) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MedicationDetailScreen(
          medicationId: medication.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: StandardAppBar(
          tabBar: TabBar(
            tabs: [
              Tab(text: l10n.medicationTabDaily),
              Tab(text: l10n.medicationTabAsNeeded),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailyMedicationsView(),
            _buildAsNeededView(),
          ],
        ),
      ),
    );
  }

  /// Tagesmedizin-Ansicht (aktueller Inhalt)
  Widget _buildDailyMedicationsView() {
    final activeProfile = _dataEntry.getActiveProfile();

    return ValueListenableBuilder(
      valueListenable: _dataEntry.medicationsBox.listenable(),
      builder: (context, box, _) {
        final todaysMedications = _dataEntry.getTodaysMedications();

        if (todaysMedications.isEmpty) {
          final l10n = AppLocalizations.of(context);
          return AnimatedEmptyState(
            icon: Icons.medication,
            title: l10n.medicationEmptyTitle,
            subtitle: l10n.medicationEmptySubtitle,
          );
        }

        // Medikamente gruppiert nach Einnahmezeit
        final medicationsByTime = <String, List<Medication>>{};
        for (final medication in todaysMedications) {
          for (final time in medication.timesOfDay) {
            if (!medicationsByTime.containsKey(time)) {
              medicationsByTime[time] = [];
            }
            medicationsByTime[time]!.add(medication);
          }
        }

        // Sortiere Zeiten
        final sortedTimes = medicationsByTime.keys.toList()..sort();

        return ListView.builder(
          padding: EdgeInsets.only(
            top: 16,
            bottom: context.safeBottomPaddingForFab,
          ),
          itemCount: sortedTimes.length + 1, // +1 für Header
          itemBuilder: (context, index) {
            final l10n = AppLocalizations.of(context);
            if (index == 0) {
              // Header mit Statistik. Er hört selbst auf die Logs: Der
              // äußere Builder oben reagiert nur auf die Medikamente, und
              // ohne den eigenen Horcher blieb der Zähler nach dem
              // Abhaken auf „0 / 1" stehen, während die Karte darunter
              // längst durchgestrichen war.
              return ValueListenableBuilder(
                valueListenable: _dataEntry.medicationLogsBox.listenable(),
                builder: (context, logsBox, _) {
                  final totalDoses = todaysMedications.fold<int>(
                    0,
                    (sum, med) => sum + med.timesOfDay.length,
                  );
                  final takenCount = _getTakenCount(activeProfile?.id ?? '');

                  return Column(
                    children: [
                      // Zuerst: kann Aurora ueberhaupt erinnern?
                      //
                      // Ein Schalter, der ein Versprechen gibt, das das Geraet
                      // nicht haelt, gehoert nicht ueber, sondern vor die
                      // Tagesuebersicht.
                      const _ErlaubnisBand(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.medicationToday,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.medication,
                                        label: l10n.medicationTitle,
                                        value: todaysMedications.length
                                            .toString(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.schedule,
                                        label: l10n.medicationIntakesLabel,
                                        value: '$takenCount / $totalDoses',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }

            // Medikamente für diese Zeit
            final timeIndex = index - 1;
            final time = sortedTimes[timeIndex];
            final medications = medicationsByTime[time]!;

            return ValueListenableBuilder(
              valueListenable: _dataEntry.medicationLogsBox.listenable(),
              builder: (context, logsBox, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zeit-Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Text(
                        l10n.medicationAtTime(time),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    // Medikamenten-Karten
                    ...medications.map((medication) {
                      // Hole Log für Status-Info
                      final log = _dataEntry.getTodaysLog(
                        medication.id,
                        time,
                      );

                      final status = log?.status;
                      final statusByProfile = log != null
                          ? _dataEntry.getProfiles().firstWhere(
                              (p) => p.id == log.profileId,
                              orElse: () => activeProfile!,
                            )
                          : null;

                      return MedicationCard(
                        medication: medication,
                        timeOfDay: time,
                        status: status,
                        statusByProfile: statusByProfile,
                        refusalNote: log?.refusalNote,
                        feedback: log?.feedback,
                        snoozedUntil: log?.snoozedUntil,
                        onTap: () => _viewMedicationDetails(medication),
                        onMarkTaken: () => _markAsTaken(medication, time),
                        onMarkRefused: () => _markAsRefused(medication, time),
                        onSnooze: () => _snoozeMedication(medication, time),
                        onAddFeedback: () => _addFeedback(medication, time),
                        onViewFeedback: log?.feedback != null
                            ? () => _viewFeedback(log!.feedback!)
                            : null,
                      );
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// Bedarfsmedizin-Ansicht
  Widget _buildAsNeededView() {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder(
      valueListenable: _dataEntry.medicationsBox.listenable(),
      builder: (context, box, _) {
        // Nur Bedarfsmedizin filtern
        final asNeededMedications = _dataEntry
            .getActiveMedications()
            .where((med) => med.type == MedicationType.asNeeded)
            .toList();

        if (asNeededMedications.isEmpty) {
          return AnimatedEmptyState(
            icon: Icons.healing,
            title: l10n.medicationEmptyAsNeededTitle,
            subtitle: l10n.medicationAddFirstAsNeeded,
          );
        }

        // Liste der Bedarfsmedikamente mit reaktiven Updates
        return ValueListenableBuilder(
          valueListenable: _dataEntry.medicationLogsBox.listenable(),
          builder: (context, logsBox, _) {
            return AnimatedListView(
              padding: EdgeInsets.only(
                top: 16,
                bottom: context.safeBottomPaddingForFab,
              ),
              itemCount: asNeededMedications.length,
              itemBuilder: (context, index) {
                final medication = asNeededMedications[index];
                return AsNeededMedicationCard(medication: medication);
              },
            );
          },
        );
      },
    );
  }

  /// Zähle genommene Dosen heute
  int _getTakenCount(String profileId) {
    if (profileId.isEmpty) return 0;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _dataEntry.medicationLogsBox.values
        .where(
          (log) =>
              log.status == MedicationStatus.taken &&
              log.takenAt.isAfter(todayStart) &&
              log.takenAt.isBefore(todayEnd),
        )
        .length;
  }
}

/// Kleine Statistik-Karte
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

/// Verbindet das Erlaubnisband mit dem Dienst.
///
/// Das Band selbst weiss nichts von Diensten und laesst sich deshalb
/// ohne Umgebung pruefen. Hier wird gefragt, nicht dort.
class _ErlaubnisBand extends StatefulWidget {
  const _ErlaubnisBand();

  @override
  State<_ErlaubnisBand> createState() => _ErlaubnisBandState();
}

class _ErlaubnisBandState extends State<_ErlaubnisBand> {
  bool _hasPermission = true;
  int _openPromises = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_nachsehen());
  }

  Future<void> _nachsehen() async {
    if (!getIt.isRegistered<NotificationService>()) return;
    final service = getIt<NotificationService>();
    final erlaubt = await service.hasPermission();
    final offen = service.countPromisedIntakeTimes();
    if (!mounted) return;
    setState(() {
      _hasPermission = erlaubt;
      _openPromises = offen;
    });
  }

  Future<void> _fragen() async {
    await ensureReminderPermission(context);
    await _nachsehen();
  }

  @override
  Widget build(BuildContext context) => ReminderPermissionBanner(
    hasPermission: _hasPermission,
    openPromises: _openPromises,
    onRequest: _fragen,
  );
}
