import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:flutter/material.dart';

/// Eine Marke auf einer Zeitleiste: Symbol und Wort.
///
/// Beides, nie nur eines (Regel 5) — das Symbol trägt, das Wort bestätigt.
///
/// Wird von [QuickTimelineBand] und von den Randleisten der Zeitkarte
/// benutzt. Beide zeigen dieselben Ereignisse, nur in anderer Anordnung;
/// zwei Zeichnungen desselben Dings würden früher oder später auseinander
/// laufen.
class TimelineMark extends StatelessWidget {
  const TimelineMark({
    required this.icon,
    required this.label,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Das Symbol für einen Ereignistyp.
IconData timelineSymbol(TimelineEvent event) {
  return switch (event.type) {
    TimelineEventType.profileSwitch => Icons.swap_horiz,
    TimelineEventType.medication => Icons.medication,
    TimelineEventType.calendarEvent => Icons.event,
  };
}

/// Die Beschriftung: bei Wechseln der Name des Anteils, sonst der Titel.
String timelineLabel(
  TimelineEvent event,
  String? Function(String profileId) profileNameOf,
) {
  if (event.type == TimelineEventType.profileSwitch) {
    final id = event.data?['toProfileId'] as String?;
    final name = id == null ? null : profileNameOf(id);
    if (name != null) return name;
  }
  return event.title ?? '';
}

/// Darf dieses Ereignis dem aktiven Anteil gezeigt werden?
///
/// Wechsel gelten dem Körper und erscheinen immer. Medikamente und Termine
/// hängen an den Rechten.
///
/// `profile == null` heißt: noch niemand angemeldet. Dann wird nicht
/// gefiltert — aus demselben Grund, aus dem die Tageszeile schon vor der
/// Wahl Termine und Medikamente zählt: Sie gelten dem Körper, nicht dem
/// Anteil.
bool timelineVisibleFor(TimelineEvent event, Profile? profile) {
  if (profile == null) return true;
  // Die Inhalts-Rechte („… ansehen"), nicht die Tab-Rechte: Das Tab-Recht
  // steuert die Navigation, dieses hier den Inhalt. Vorher hing beides am
  // Tab-Recht — „Kalender ansehen" ließ sich damit entziehen, ohne dass
  // irgendwo irgendetwas verschwand.
  return switch (event.type) {
    TimelineEventType.medication => profile.hasPermission(
      Permission.viewMedication,
    ),
    TimelineEventType.calendarEvent => profile.hasPermission(
      Permission.viewCalendar,
    ),
    _ => true,
  };
}

/// Fasst aufeinanderfolgende Wechsel zum selben Anteil zu einer Marke
/// zusammen.
///
/// „Dev › Dev › Dev" beantwortet keine Frage — es verdeckt nur die Marke
/// davor. Behalten wird der jüngste Wechsel der Episode, weil er sagt, seit
/// wann dieser Anteil ununterbrochen da war.
///
/// Erwartet chronologisch sortierte Ereignisse, älteste zuerst.
List<TimelineEvent> collapseSwitchEpisodes(List<TimelineEvent> sorted) {
  final result = <TimelineEvent>[];
  for (final event in sorted) {
    final prev = result.isEmpty ? null : result.last;
    if (event.type == TimelineEventType.profileSwitch &&
        prev != null &&
        prev.type == TimelineEventType.profileSwitch &&
        prev.data?['toProfileId'] == event.data?['toProfileId']) {
      result[result.length - 1] = event;
      continue;
    }
    result.add(event);
  }
  return result;
}
