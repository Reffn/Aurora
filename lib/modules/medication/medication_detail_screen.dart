import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/medication/medication_form_screen.dart';
import 'package:dis_app/modules/medication/medication_labels.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder(
      valueListenable: _dataEntry.medicationsBox.listenable(),
      builder: (context, box, _) {
        // Kein firstWhere mit orElse: Dessen Rückgabe müsste ein Medication
        // sein, und ein untergeschobenes null hätte hier geworfen, statt den
        // "nicht gefunden"-Bildschirm zu zeigen.
        final matches = _dataEntry.getActiveMedications().where(
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

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.medicationDetailTitle),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            actions: [
              _buildEditButton(medication),
              _buildDeleteButton(medication),
            ],
          ),
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _MedicationDetailCard(medication: medication),
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

  Widget _buildEditButton(Medication medication) {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return const SizedBox.shrink();

    // Check if user can edit
    final canEdit =
        activeProfile.isAdmin ||
        activeProfile.hasPermission(Permission.manageMedication);

    if (!canEdit) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) =>
                MedicationFormScreen(existingMedication: medication),
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton(Medication medication) {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return const SizedBox.shrink();

    // Check if user can delete
    final canDelete =
        activeProfile.isAdmin ||
        activeProfile.hasPermission(Permission.manageMedication);

    if (!canDelete) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: _deleteMedication,
    );
  }

  Future<void> _deleteMedication() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: l10n.medicationDeleteTitle,
      message: l10n.medicationDeleteConfirmMessage,
      actionText: l10n.actionDelete,
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
                value: '${medication.maxDailyDoses} Einnahmen',
              ),
            ],

            // Min. Abstand (nur bei asNeeded)
            if (medication.type == MedicationType.asNeeded &&
                medication.minIntervalHours != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.timer,
                label: l10n.medicationMinGapLabel,
                value: '${medication.minIntervalHours} Stunden',
              ),
            ],

            // Aktiv-Status
            const SizedBox(height: 12),
            _InfoRow(
              icon: medication.isActive ? Icons.check_circle : Icons.cancel,
              label: l10n.medicationStatusLabel,
              value: medication.isActive ? 'Aktiv' : 'Inaktiv',
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
