import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/utils/adaptive.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/action_button_row.dart';
import 'package:dis_app/widgets/medication_avatar.dart';
import 'package:flutter/material.dart';

/// Medikamenten-Karte mit 3-Button-System (Genommen/Verweigert/Später)
class MedicationCard extends StatelessWidget {
  // Nur wenn Feedback vorhanden

  const MedicationCard({
    required this.medication,
    required this.timeOfDay,
    required this.onTap,
    required this.onMarkTaken,
    required this.onMarkRefused,
    required this.onSnooze,
    super.key,
    this.status,
    this.statusByProfile,
    this.refusalNote,
    this.feedback,
    this.snoozedUntil,
    this.onAddFeedback,
    this.onViewFeedback,
  });
  final Medication medication;
  final String timeOfDay;
  final MedicationStatus? status;
  final Profile? statusByProfile; // Wer hat den Status gesetzt
  final String? refusalNote;
  final String? feedback;
  final DateTime? snoozedUntil;
  final VoidCallback onTap;
  final VoidCallback onMarkTaken;
  final VoidCallback onMarkRefused;
  final VoidCallback onSnooze;
  final VoidCallback? onAddFeedback; // Nur bei taken/refused
  final VoidCallback? onViewFeedback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // „Uhr" hängt nur im Deutschen hinter der Zeit. Der Zusatz gehört
    // deshalb in die Sprachdatei, nicht in den Code.
    final formattedTime = l10n.clockTime(timeOfDay);

    // Zeitstatus berechnen
    final now = DateTime.now();
    final timeParts = timeOfDay.split(':');
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    final isTimeReached = now.isAfter(scheduledTime);
    final isOverdue = status == null && isTimeReached;

    // Status-Farbe & Icon
    Color statusColor;
    IconData statusIcon;
    if (status == MedicationStatus.taken) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == MedicationStatus.refused) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (status == MedicationStatus.snoozed) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    } else if (isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    }

    final hasStatus = status != null;

    return Card(
      elevation: 2,
      margin: Adaptive.padding(context, horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Haupt-Content
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: Adaptive.padding(context, all: 16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medikamenten-Avatar (Pillenform)
                      MedicationAvatar(
                        imagePath: medication.imagePath,
                        name: medication.name,
                        width: 60,
                        height: 30,
                        statusColor: statusColor,
                        showShadow: false,
                      ),
                      SizedBox(width: Adaptive.spacing(context, 12)),

                      // Medikamenten-Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                              medication.name,
                              style: TextStyle(
                                fontSize: Adaptive.fontSize(context, 16),
                                fontWeight: FontWeight.bold,
                                decoration: status == MedicationStatus.taken
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: hasStatus
                                    ? Colors.white70
                                    : Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Adaptive.spacing(context, 4)),

                            // Dosierung
                            Text(
                              medication.dosage,
                              style: TextStyle(
                                fontSize: Adaptive.fontSize(context, 14),
                                color: hasStatus
                                    ? Colors.white54
                                    : Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: Adaptive.spacing(context, 4)),

                            // Zeit
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: Adaptive.iconSize(context, 14),
                                  color: Colors.white54,
                                ),
                                SizedBox(width: Adaptive.spacing(context, 4)),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: Adaptive.fontSize(context, 13),
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),

                            // Status-Badge
                            if (status == MedicationStatus.taken &&
                                statusByProfile != null) ...[
                              SizedBox(height: Adaptive.spacing(context, 8)),
                              _buildStatusBadge(
                                context,
                                l10n.medicationTakenBy(statusByProfile!.name),
                                Colors.green,
                                Icons.check_circle,
                              ),
                            ],

                            if (status == MedicationStatus.refused &&
                                statusByProfile != null) ...[
                              SizedBox(height: Adaptive.spacing(context, 8)),
                              _buildStatusBadge(
                                context,
                                l10n.medicationRefusedBy(statusByProfile!.name),
                                Colors.red,
                                Icons.cancel,
                              ),
                              if (refusalNote != null &&
                                  refusalNote!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '"$refusalNote"',
                                  style: TextStyle(
                                    fontSize: Adaptive.fontSize(context, 11),
                                    color: Colors.red.shade300,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],

                            if (status == MedicationStatus.snoozed &&
                                snoozedUntil != null) ...[
                              SizedBox(height: Adaptive.spacing(context, 8)),
                              _buildStatusBadge(
                                context,
                                // Dasselbe Zeitformat wie die Dosiszeit
                                // darüber. `DateFormat.jm()` schrieb in
                                // englischer Oberfläche „1:21 PM" unter ein
                                // „12:50" — zwei Uhren auf einer Karte.
                                '⏰ ${l10n.medicationReminderAtTime('${snoozedUntil!.hour.toString().padLeft(2, '0')}:${snoozedUntil!.minute.toString().padLeft(2, '0')}')}',
                                Colors.orange,
                                Icons.schedule,
                              ),
                            ],

                            // Notizen
                            if (medication.notes != null &&
                                medication.notes!.isNotEmpty) ...[
                              SizedBox(height: Adaptive.spacing(context, 6)),
                              Text(
                                medication.notes!,
                                style: TextStyle(
                                  fontSize: Adaptive.fontSize(context, 12),
                                  color: Colors.white54,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],

                            // Beschreibung
                            if (medication.description != null &&
                                medication.description!.isNotEmpty) ...[
                              SizedBox(height: Adaptive.spacing(context, 6)),
                              Text(
                                medication.description!,
                                style: TextStyle(
                                  fontSize: Adaptive.fontSize(context, 11),
                                  color: Colors.white60,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Status-Icon
                      Container(
                        padding: Adaptive.padding(context, all: 8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: Adaptive.borderRadius(context, 8),
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                          size: Adaptive.iconSize(context, 24),
                        ),
                      ),
                    ],
                  ),

                  // Feedback-Anzeige (falls vorhanden)
                  if (feedback != null && feedback!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: onViewFeedback,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.feedback,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feedback!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Die drei Knöpfe bleiben auch nach der Entscheidung stehen.
          //
          // Vorher standen sie unter `if (!hasStatus)` und verschwanden,
          // sobald etwas gesetzt war. Wer sich vertippte — und im Gerätetest
          // war „Später" einen Daumen von „Genommen" entfernt —, kam ohne
          // Umweg über den Detailbildschirm nicht zurück. In einem System
          // mit Wechseln und Erinnerungslücken muss Korrigieren billiger
          // sein als Festlegen, nicht teurer.
          //
          // Der gesetzte Zustand ist gefüllt, die anderen bleiben Umriss.
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ActionButtonRow(
              buttons: [
                ActionButtonConfig(
                  label: l10n.medicationStatusTaken,
                  icon: Icons.check,
                  color: AppColors.go,
                  filled: !hasStatus || status == MedicationStatus.taken,
                  onPressed: onMarkTaken,
                ),
                ActionButtonConfig(
                  label: l10n.medicationStatusRefused,
                  icon: Icons.cancel,
                  color: AppColors.signal,
                  filled: status == MedicationStatus.refused,
                  onPressed: onMarkRefused,
                ),
                ActionButtonConfig(
                  label: l10n.medicationStatusSnoozed,
                  icon: Icons.schedule,
                  color: AppColors.wait,
                  filled: status == MedicationStatus.snoozed,
                  onPressed: onSnooze,
                ),
              ],
            ),
          ),

          // Feedback-Button (bei taken/refused)
          if ((status == MedicationStatus.taken ||
                  status == MedicationStatus.refused) &&
              feedback == null &&
              onAddFeedback != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                onPressed: onAddFeedback,
                icon: const Icon(Icons.add_comment, size: 18),
                label: Text(l10n.medicationAddFeedback),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: Adaptive.fontSize(context, 11),
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
