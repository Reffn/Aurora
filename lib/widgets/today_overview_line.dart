import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:flutter/material.dart';

/// „Was steht heute an" — unter der Zeitzeile auf dem Anker.
///
/// Teil der Reorientierung nach Zeitverlust: Wer nach vorn kommt, sieht
/// ohne einen einzigen Schritt, ob dieser Tag Termine oder Medikamente
/// trägt. Gezeigt wird nur, was das aktive Profil sehen darf — die Zeile
/// steht bewusst NACH der Profilwahl, nie davor: Vor dem Profil gibt es
/// keine Rechteprüfung, und der Medikamentenplan ist das sensibelste
/// Datum der App.
///
/// Ein leerer Tag erzeugt Stille, nicht „0 Termine" — nichts anzukündigen
/// ist keine Information, die Platz verdient.
class TodayOverviewLine extends StatelessWidget {
  const TodayOverviewLine({
    required this.profile,
    required this.countEventsForDay,
    required this.countMedicationsToday,
    super.key,
    this.gateByPermissions = true,
    this.refresh,
    this.nowProvider,
    this.centered = false,
  });

  final Profile? profile;

  /// Auf der Profilauswahl aus: Termine und Medikamente gelten dem Körper,
  /// nicht dem Anteil — die Zahlen gehören allen, bevor jemand gewählt hat.
  /// Es bleiben Zahlen: Inhalte (Namen, Uhrzeiten, Präparate) erscheinen
  /// erst nach der Wahl, damit ein Dritter mit dem Gerät in der Hand
  /// nichts über Diagnose oder Medikation erfährt.
  final bool gateByPermissions;

  /// Zählt die Termine eines Tages — die Abfrage gehört dem Service, das
  /// Widget kennt nur die Zahl. So bleibt es ohne Dienste prüfbar.
  final int Function(DateTime day) countEventsForDay;
  final int Function() countMedicationsToday;

  /// Meldet, wenn sich die Datenlage ändert (z. B. die Termin-Box).
  final Listenable? refresh;

  /// Injizierbare Zeitquelle — Tests können die Uhr stellen.
  final DateTime Function()? nowProvider;

  /// Auf zentrierten Flächen (Profilauswahl) mittig statt am linken Rand.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final bool darfKalender;
    final bool darfMedikamente;
    if (gateByPermissions) {
      final p = profile;
      if (p == null) return const SizedBox.shrink();
      // Inhalts-Rechte, nicht Tab-Rechte — siehe [timelineVisibleFor].
      darfKalender = p.hasPermission(Permission.viewCalendar);
      darfMedikamente = p.hasPermission(Permission.viewMedication);
      if (!darfKalender && !darfMedikamente) return const SizedBox.shrink();
    } else {
      darfKalender = true;
      darfMedikamente = true;
    }

    return ListenableBuilder(
      listenable: refresh ?? ValueNotifier<int>(0),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final now = (nowProvider ?? DateTime.now)();

        final teile = <String>[
          if (darfKalender)
            if (countEventsForDay(now) case final n when n > 0)
              l10n.todayEvents(n),
          if (darfMedikamente)
            if (countMedicationsToday() case final m when m > 0)
              l10n.todayMedications(m),
        ];
        if (teile.isEmpty) return const SizedBox.shrink();

        final dim = Theme.of(context).colorScheme.onSurfaceVariant;
        return Padding(
          padding: const EdgeInsets.fromLTRB(28, 6, 28, 0),
          child: Row(
            mainAxisAlignment: centered
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(Icons.event_note, size: 16, color: dim),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  teile.join(' · '),
                  style: TextStyle(fontSize: 13, color: dim),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
