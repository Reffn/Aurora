import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/medication/medication_history.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Der Verlauf als Tagesgruppen: Überschrift, darunter je Zeitpunkt eine
/// Zeile mit Stand, Uhrzeit und wer es eingetragen hat.
///
/// Eine Arbeitsfläche, keine Wahlfläche (Richtlinie 2): schlichte Zeilen,
/// gruppiert nach Tag (Richtlinie 3). Jeder Stand trägt Symbol *und* Wort
/// (Richtlinie 5). „Nichts eingetragen" ist grau, nicht rot — es ist eine
/// Auskunft, kein Vorwurf.
class MedicationHistoryList extends StatelessWidget {
  const MedicationHistoryList({
    required this.tage,
    required this.profile,
    this.mitMedikamentName = true,
    super.key,
  });

  final List<VerlaufTag> tage;
  final List<Profile> profile;

  /// Auf der Detailseite steht der Name schon oben.
  final bool mitMedikamentName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final heute = DateUtils.dateOnly(DateTime.now());

    String tagesName(DateTime tag) {
      final abstand = heute.difference(tag).inDays;
      if (abstand == 0) return l10n.medicationToday;
      if (abstand == 1) return l10n.chatDayYesterday;
      return DateFormat.MMMMEEEEd(locale).format(tag);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final tag in tage) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 6),
            child: Text(
              tagesName(tag.tag),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < tag.eintraege.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _Zeile(
                    eintrag: tag.eintraege[i],
                    profile: profile,
                    mitMedikamentName: mitMedikamentName,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({
    required this.eintrag,
    required this.profile,
    required this.mitMedikamentName,
  });

  final VerlaufEintrag eintrag;
  final List<Profile> profile;
  final bool mitMedikamentName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final log = eintrag.log;
    final (farbe, symbol, wort) = switch (log?.status) {
      MedicationStatus.taken => (
        AppColors.go,
        Icons.check_circle,
        l10n.medicationStatusTaken,
      ),
      MedicationStatus.refused => (
        AppColors.signal,
        Icons.cancel,
        l10n.medicationStatusRefused,
      ),
      MedicationStatus.snoozed => (
        AppColors.wait,
        Icons.schedule,
        l10n.medicationStatusSnoozed,
      ),
      MedicationStatus.skipped => (
        Colors.white54,
        Icons.redo,
        l10n.medicationStatusSkipped,
      ),
      null => (
        Colors.white38,
        Icons.remove_circle_outline,
        l10n.medicationHistoryNothing,
      ),
    };

    final titel = [
      eintrag.sortierschluessel,
      if (mitMedikamentName) eintrag.medication.name,
    ].join(' · ');

    Profile? wer;
    if (log != null) {
      for (final p in profile) {
        if (p.id == log.profileId) wer = p;
      }
    }
    final bestaetigt = log?.confirmedAt ?? log?.takenAt;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(symbol, color: farbe, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: wort,
                        style: TextStyle(
                          color: log == null ? Colors.white54 : farbe,
                        ),
                      ),
                      if (bestaetigt != null && eintrag.slot != null)
                        TextSpan(
                          text: ' · ${_uhrzeit(bestaetigt)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          if (wer != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: wer.preferredColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: Text(
                wer.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _uhrzeit(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}
