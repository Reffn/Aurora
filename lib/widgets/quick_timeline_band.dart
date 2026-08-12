import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:dis_app/widgets/timeline_marks.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Das Marken-Band unter dem Bereichstitel: wer war, was geschah, wer ist
/// jetzt hier, was kommt.
///
///   Sofie › ✓ Ibuprofen › Arzt › [Marie (Du)] ›› Frau Müller 15:00
///
/// Vergangenheit links und gedämpft, das Jetzt als hervorgehobene Marke mit
/// Profilfarbe, rechts die Zukunft mit Uhrzeit. Eine Zeile beantwortet die
/// Fragen, die Zeitverlust offen lässt — ohne dass jemand die Chronologie
/// aufsuchen muss. Wer mehr wissen will, tippt das Band an und landet dort.
///
/// Jede Marke trägt Symbol und Wort (Regel 5). Medikamente und Termine
/// erscheinen nur mit den Rechten des aktiven Profils; Wechsel-Marken
/// gelten dem Körper und erscheinen immer.
class QuickTimelineBand extends StatelessWidget {
  const QuickTimelineBand({
    required this.profile,
    required this.pastEvents,
    required this.upcomingEvents,
    required this.profileNameOf,
    super.key,
    this.onTap,
  });

  final Profile profile;

  /// Bereits chronologisch (älteste zuerst); das Band kappt selbst.
  final List<TimelineEvent> pastEvents;
  final List<TimelineEvent> upcomingEvents;

  /// Löst eine Profil-ID in den Namen auf — `null`, wenn unbekannt.
  final String? Function(String profileId) profileNameOf;

  /// Führt zur Chronologie; das Band selbst liest nur.
  final VoidCallback? onTap;

  /// Mehr Marken beantworten keine Frage besser — sie verstecken das Jetzt.
  static const int maxPast = 3;
  static const int maxUpcoming = 2;

  /// Ob das Band überhaupt etwas zu sagen hat.
  ///
  /// Ohne Marken bliebe der Avatar allein auf einer leeren Leiste stehen —
  /// eine Antwort auf eine Frage, die einen Zentimeter höher schon
  /// beantwortet ist. Wer das Band einhängt, fragt vorher hier.
  static bool hasContent({
    required Profile profile,
    required List<TimelineEvent> pastEvents,
    required List<TimelineEvent> upcomingEvents,
  }) {
    final past = pastEvents
        .where((e) => timelineVisibleFor(e, profile))
        .where(
          (e) =>
              e.type != TimelineEventType.profileSwitch ||
              e.data?['toProfileId'] != profile.id,
        );
    final next = upcomingEvents.where((e) => timelineVisibleFor(e, profile));
    return past.isNotEmpty || next.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dim = Theme.of(context).colorScheme.onSurfaceVariant;

    final sortiert =
        pastEvents.where((e) => timelineVisibleFor(e, profile)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final vergangenheit = [...collapseSwitchEpisodes(sortiert)];
    final zukunft =
        upcomingEvents.where((e) => timelineVisibleFor(e, profile)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    // Der Wechsel auf den, der gerade hier ist, sagt nichts: Der Drehpunkt
    // rechts daneben sagt es schon, und zwar deutlicher. Am Gerät stand
    // „⇄ Lina › [Lina]" — zweimal derselbe Mensch nebeneinander.
    while (vergangenheit.isNotEmpty &&
        vergangenheit.last.type == TimelineEventType.profileSwitch &&
        vergangenheit.last.data?['toProfileId'] == profile.id) {
      vergangenheit.removeLast();
    }

    final past = vergangenheit.length <= maxPast
        ? vergangenheit
        : vergangenheit.sublist(vergangenheit.length - maxPast);
    final next = zukunft.take(maxUpcoming).toList();

    final kinder = <Widget>[
      for (final e in past) ...[
        TimelineMark(
          icon: timelineSymbol(e),
          label: timelineLabel(e, profileNameOf),
          color: dim,
        ),
        Icon(Icons.chevron_right, size: 14, color: dim),
      ],
      // Das Jetzt: die einzige laute Marke des Bandes.
      _DuMarke(profile: profile, youMarker: l10n.quickTimelineYou),
      if (next.isNotEmpty) ...[
        Icon(Icons.double_arrow, size: 14, color: dim),
        for (final e in next) ...[
          // Die Uhrzeit zuerst: Sie ist der Handlungsanker, und ein langer
          // Name darf sie nicht von der Fläche drängen.
          TimelineMark(
            icon: timelineSymbol(e),
            label:
                '${DateFormat.Hm().format(e.timestamp)} '
                '${timelineLabel(e, profileNameOf)}',
            color: Colors.white70,
          ),
          if (e != next.last) Icon(Icons.chevron_right, size: 14, color: dim),
        ],
      ],
    ];

    final band = SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [Row(mainAxisSize: MainAxisSize.min, children: kinder)],
      ),
    );

    // Ohne Ziel bleibt das Band reine Orientierung. Ein Ripple ohne Wirkung
    // wäre ein Versprechen, das die Fläche nicht halten kann.
    if (onTap == null) return band;

    // Ein klickbares Band ohne Namen zwingt Vorlesehilfen zum Probieren.
    // Der Name nennt beides: die Handlung und wohin sie führt.
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).openTimelineSemantics,
      child: InkWell(onTap: onTap, child: band),
    );
  }
}

/// Der Jetzt-Anker des Bandes: Avatar mit Farbring.
///
/// Er trug einmal Name und „(Du)" in einer Pille mit Rand — direkt unter der
/// Kopfzeile, in der derselbe Name mit demselben Avatar schon steht. Zwei
/// Antworten auf dieselbe Frage, und die untere sah nach einem Knopf aus,
/// ohne einer zu sein: Wer den Weg zum Profil suchte, griff dorthin ins
/// Leere. Der Name steht jetzt einmal, oben und beim Scrollen sichtbar; hier
/// bleibt der Avatar als Drehpunkt zwischen Vergangenheit und Zukunft. Für
/// Vorlesehilfen trägt er den Namen weiter.
class _DuMarke extends StatelessWidget {
  const _DuMarke({required this.profile, required this.youMarker});

  final Profile profile;
  final String youMarker;

  @override
  Widget build(BuildContext context) {
    final farbe = profile.preferredColor;
    return Semantics(
      container: true,
      label: '${profile.name} $youMarker',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: farbe, width: 2),
        ),
        child: ClipOval(
          child: ProfileImageWidget(
            avatarPath: profile.avatarPath,
            profileName: profile.name,
            profileColor: farbe,
            size: 20,
          ),
        ),
      ),
    );
  }
}
