import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/medication/medication_form_screen.dart';
import 'package:dis_app/modules/medication/medication_history.dart';
import 'package:dis_app/modules/medication/medication_labels.dart';
import 'package:dis_app/modules/medication/widgets/medication_history_list.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/reminder_permission.dart';
import 'package:dis_app/widgets/comments/comment_section.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/medication_avatar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Medication Detail Screen - Zeigt Medikamenten-Details mit Kommentaren
class MedicationDetailScreen extends StatefulWidget {
  const MedicationDetailScreen({
    required this.medicationId,
    super.key,
  });

  final String medicationId;

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  late final DataEntry _dataEntry;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _darfVerwalten {
    final profil = _dataEntry.getActiveProfile();
    if (profil == null) return false;
    return profil.isAdmin || profil.hasPermission(Permission.manageMedication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder(
      valueListenable: _dataEntry.medicationsBox.listenable(),
      builder: (context, box, _) {
        // Auch pausierte: Sonst führt „Pausiert" in der Liste zu
        // „nicht gefunden", und niemand käme an „Wieder aufnehmen".
        //
        // Kein firstWhere mit orElse: Dessen Rückgabe müsste ein Medication
        // sein, und ein untergeschobenes null hätte hier geworfen, statt den
        // "nicht gefunden"-Bildschirm zu zeigen.
        final matches = _dataEntry.getAllMedications().where(
          (m) => m.id == widget.medicationId,
        );
        final medication = matches.isEmpty ? null : matches.first;

        if (medication == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.medicationNotFound)),
            body: Center(
              child: Text(l10n.medicationNotFoundMessage),
            ),
          );
        }

        // Bearbeiten und Löschen standen hier als zwei Symbole ohne Wort
        // oben rechts in der Kopfzeile; Stummschalten gab es nur tief im
        // Formular. Rückmeldung vom 01.09.2026: „Medikamente rausnehmen
        // nicht möglich" — es war möglich, nur nicht zu finden. Die
        // Handlungen stehen jetzt als eigene Gruppe auf der Seite, jede mit
        // Symbol und Wort (Richtlinie 5).
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.medicationDetailTitle),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
          ),
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _MedicationDetailCard(medication: medication),
              if (_darfVerwalten) ...[
                const SizedBox(height: 16),
                _Verwalten(
                  medication: medication,
                  onReminders: (an) => _setReminders(medication, an),
                  onEdit: () => _edit(medication),
                  onPauseToggle: () => _togglePause(medication),
                  onRemove: () => _deleteMedication(medication),
                ),
              ],
              const SizedBox(height: 16),
              _Verlauf(medication: medication),
              const SizedBox(height: 24),
              CommentSection(
                type: CommentableType.medication,
                parentId: medication.id,
                permission: Permission.commentOnMedication,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Stummschalten ohne Umweg über das Formular.
  ///
  /// Beim Einschalten wird hier nach der Erlaubnis gefragt, wie im Formular:
  /// Ein Schalter, der Erinnerungen verspricht, die das Gerät nicht zustellt,
  /// ist schlimmer als keiner.
  Future<void> _setReminders(Medication medication, bool an) async {
    if (an) {
      final outcome = await askReminderPermission(context);
      if (!mounted) return;
      // Nur das eigene „Jetzt nicht" lässt den Schalter stehen. Ein Nein
      // des Geräts nimmt den Wunsch nicht weg — das Erlaubnisband auf der
      // Medikamentenseite zeigt dann den Weg.
      if (outcome == ReminderPermissionOutcome.declinedByPerson) return;
    }
    await _dataEntry.updateMedication(
      medication.copyWith(remindersEnabled: an),
    );
  }

  void _edit(Medication medication) {
    unawaited(
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) =>
              MedicationFormScreen(existingMedication: medication),
        ),
      ),
    );
  }

  Future<void> _togglePause(Medication medication) async {
    final l10n = AppLocalizations.of(context);
    final pausieren = medication.isActive;
    await _dataEntry.updateMedication(
      medication.copyWith(isActive: !pausieren),
    );
    if (!mounted) return;
    showCustomSnackBar(
      context,
      message: pausieren ? l10n.medicationPauseHint : l10n.medicationResumeHint,
    );
  }

  Future<void> _deleteMedication(Medication medication) async {
    final l10n = AppLocalizations.of(context);
    // Vor der Folge warnen, bevor sie eintritt (Richtlinie 10) — und den
    // sanfteren Weg nennen: Wer ein Medikament nur absetzt, will den
    // Verlauf meist behalten.
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: l10n.medicationDeleteTitle,
      message: l10n.medicationRemoveConfirmMessage(medication.name),
      actionText: l10n.medicationRemove,
    );

    if (confirmed) {
      try {
        await _dataEntry.deleteMedication(widget.medicationId);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.medicationDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
          );
        }
      }
    }
  }
}

/// Die Handlungen an einem Medikament, als eigene Gruppe.
class _Verwalten extends StatelessWidget {
  const _Verwalten({
    required this.medication,
    required this.onReminders,
    required this.onEdit,
    required this.onPauseToggle,
    required this.onRemove,
  });

  final Medication medication;
  final ValueChanged<bool> onReminders;
  final VoidCallback onEdit;
  final VoidCallback onPauseToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final aktiv = medication.isActive;
    final erinnert = medication.remindersEnabled;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.medicationManageTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Pausiert gibt es keine Erinnerungen, egal wie der Schalter
          // steht — er wird dann nicht angeboten, statt zu lügen.
          if (aktiv)
            SwitchListTile(
              secondary: Icon(
                erinnert
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
              ),
              title: Text(l10n.medicationRemindersSwitch),
              subtitle: Text(
                erinnert
                    ? l10n.medicationRemindersOnShort
                    : l10n.medicationRemindersMutedShort,
              ),
              value: erinnert,
              onChanged: onReminders,
            ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.actionEdit),
            onTap: onEdit,
          ),
          ListTile(
            leading: Icon(
              aktiv ? Icons.pause_circle_outline : Icons.play_circle_outline,
            ),
            title: Text(aktiv ? l10n.medicationPause : l10n.medicationResume),
            subtitle: Text(
              aktiv ? l10n.medicationPauseHint : l10n.medicationResumeHint,
            ),
            onTap: onPauseToggle,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.delete_outline,
              color: AppColors.signal,
            ),
            title: Text(
              l10n.medicationRemove,
              style: const TextStyle(color: AppColors.signal),
            ),
            subtitle: Text(l10n.medicationRemoveHint),
            onTap: onRemove,
          ),
        ],
      ),
    );
  }
}

/// Wer dieses Medikament wann genommen hat — die letzten zwei Wochen.
class _Verlauf extends StatelessWidget {
  const _Verlauf({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataEntry = getIt<DataEntry>();

    return ValueListenableBuilder(
      valueListenable: dataEntry.medicationLogsBox.listenable(),
      builder: (context, logsBox, _) {
        final tage = verlaufBerechnen(
          medikamente: [medication],
          eintraege: logsBox.values.where(
            (l) => l.medicationId == medication.id,
          ),
          jetzt: DateTime.now(),
          // Eine Woche genügt hier: „Hab ich gestern genommen?" ist die
          // Frage. Zwei Wochen voller Zeilen schoben die Kommentare aus dem
          // Bild; der volle Verlauf steht im eigenen Reiter.
          tage: 7,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.medicationTabHistory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (tage.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.medicationHistoryEmptyHint,
                  style: const TextStyle(color: Colors.white60),
                ),
              )
            else
              MedicationHistoryList(
                tage: tage,
                profile: dataEntry.getAllProfiles(),
                mitMedikamentName: false,
              ),
          ],
        );
      },
    );
  }
}

/// Medication Detail Card - Zeigt Medikamenten-Info
class _MedicationDetailCard extends StatelessWidget {
  const _MedicationDetailCard({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar & Name
            Row(
              children: [
                MedicationAvatar(
                  imagePath: medication.imagePath,
                  name: medication.name,
                  width: 80,
                  height: 40,
                  borderWidth: 2,
                  showShadow: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medication.type.label(l10n),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dosierung
            _InfoRow(
              icon: Icons.medication,
              label: l10n.medicationDosageLabel,
              value: medication.dosage,
            ),

            // Einnahmezeiten (nur bei daily)
            if (medication.type == MedicationType.daily &&
                medication.timesOfDay.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.access_time,
                label: l10n.medicationIntakeTimesLabel,
                value: medication.timesOfDay.join(', '),
              ),
            ],

            // Max. Tagesdosis (nur bei asNeeded)
            if (medication.type == MedicationType.asNeeded &&
                medication.maxDailyDoses != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.numbers,
                label: l10n.medicationMaxDailyLabel,
                value: l10n.medicationMaxDailyValue(medication.maxDailyDoses!),
              ),
            ],

            // Min. Abstand (nur bei asNeeded)
            if (medication.type == MedicationType.asNeeded &&
                medication.minIntervalHours != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.timer,
                label: l10n.medicationMinGapLabel,
                value: l10n.medicationMinGapValue(medication.minIntervalHours!),
              ),
            ],

            // Aktiv-Status
            const SizedBox(height: 12),
            _InfoRow(
              icon: medication.isActive ? Icons.check_circle : Icons.cancel,
              label: l10n.medicationStatusLabel,
              value: medication.isActive
                  ? l10n.medicationStatusActive
                  : l10n.medicationStatusPaused,
            ),

            // Beschreibung
            if (medication.description != null &&
                medication.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.commonDescription,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                medication.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],

            // Notizen
            if (medication.notes != null && medication.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.commonNotes,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                medication.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Info Row Widget
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
