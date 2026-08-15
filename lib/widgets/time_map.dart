import 'dart:async';
import 'dart:math' as math;

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:dis_app/modules/calendar/event_detail_screen.dart';
import 'package:dis_app/modules/contacts/contact_detail_screen.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:dis_app/utils/short_place.dart';
import 'package:dis_app/utils/time_phase.dart';
import 'package:dis_app/widgets/overview_map.dart';
import 'package:dis_app/widgets/timeline_marks.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/// Die Zeitkarte: wo der Körper war, was davor geschah, was noch kommt.
///
/// Die Karte trägt das Wo mit einer Lauflinie, die Ränder tragen das Wann —
/// oben die Vergangenheit, unten die Zukunft, das Jetzt dazwischen als die
/// Fläche selbst. Die Anordnung ist die Aussage: Man liest von oben nach
/// unten durch die Zeit und sieht dabei durchgehend den Ort.
///
/// Gebaut aus dem, was es schon gibt: [OverviewMap] zeichnet Pfad und
/// Wechselpunkte, [TimelineMark] die Marken. Hier kommt nur die Anordnung
/// dazu.
///
/// Die Leisten liegen **auf** der Karte, nicht darüber und darunter. Über
/// einer Karte ist jeder Text schlecht lesbar — Kacheln haben Wiesen und
/// Straßen in jeder Helligkeit. Deshalb liegt unter jeder Leiste ein
/// dunkler Verlauf. Er ist kein Schmuck, er ist die Bedingung dafür, dass
/// die Marken bei jedem Kartenausschnitt lesbar bleiben.
class TimeMap extends StatelessWidget {
  const TimeMap({
    required this.track,
    required this.switchEvents,
    required this.pastEvents,
    required this.upcomingEvents,
    required this.profileNameOf,
    super.key,
    this.profileColorOf,
    this.profile,
    this.height = 220,
    this.onTap,
    this.showPlaces = true,
    this.showContacts = false,
    this.destination,
    this.destinationLabel,
    this.finderLocations,
    this.contacts,
  });

  /// Wo der nächste Termin stattfindet, falls einer einen Ort hat.
  ///
  /// Die Karte zeichnet eine Luftlinie dorthin. Sie beantwortet die Frage, die
  /// direkt nach „wo bin ich" kommt: Muss ich los, und in welche Richtung.
  final LatLng? destination;
  final String? destinationLabel;

  /// Die Bewegung als Lauflinie. Neueste zuerst.
  final List<LocationHistoryEntry> track;

  /// Wechselpunkte auf der Karte.
  final List<ProfileSwitchEvent> switchEvents;

  final List<TimelineEvent> pastEvents;
  final List<TimelineEvent> upcomingEvents;

  /// Finder-Orte mit GPS für die Karte (optional)
  final List<FinderItem>? finderLocations;

  /// Kontakte mit GPS für die Karte (optional)
  final List<Contact>? contacts;

  /// Löst eine Profil-ID in den Namen auf — `null`, wenn unbekannt.
  final String? Function(String profileId) profileNameOf;

  /// Die Farbe eines Anteils. Sie färbt seinen Abschnitt im Strang, seinen
  /// Weg auf der Karte und seine Punkte darauf — dreimal dieselbe Farbe für
  /// dieselbe Person, damit man sie nicht dreimal lesen muss.
  final Color Function(String profileId)? profileColorOf;

  /// Der angemeldete Anteil, für den Rechtefilter. `null` vor der Anmeldung.
  final Profile? profile;

  final double height;

  /// Ab hier trägt die Karte den vollen Kopf.
  ///
  /// Darunter bleibt die Kopfzeile inhaltlich gleich, wird aber kleiner
  /// gesetzt — sonst nimmt sie auf einer 150-dp-Karte fast die Hälfte ein.
  /// Die Grenze liegt dort, wo der Kopf ein Drittel der Fläche erreicht.
  static const double compactBelowHeight = 200;

  /// Die kleinste Höhe, auf die sich diese Karte drücken lässt.
  ///
  /// Darunter trägt sie nichts mehr: Der Kopfstrang allein braucht schon
  /// gut die Hälfte, und was bleibt, zeigte nur noch Straßennamen ohne
  /// Zusammenhang. 150 ist die Höhe, mit der sie auf der Profilauswahl seit
  /// jeher steht — dort ist die kompakte Form belegt.
  static const double minHeight = 150;

  /// Die größte sinnvolle Höhe.
  ///
  /// 180 waren zu wenig: Oben und unten liegt je ein Zeitstrang, dazwischen
  /// standen Standort, Orte, Wechselmarken und Zeiten übereinander.
  static const double maxHeight = 280;

  /// Wie hoch die Karte wird, wenn ein Block ihr [platz] übrig lässt.
  ///
  /// Die Rechnung steht hier und nicht beim Aufrufer. Am 11. August 2026
  /// stand sie in `main.dart` — mit [compactBelowHeight] als Untergrenze,
  /// also mit einer *Darstellungsschwelle* als *Mindesthöhe*. Damit konnte
  /// die kompakte Form, für die es die Schwelle überhaupt gibt, vom Anker
  /// aus nie eintreten: Die Karte blieb auf 200 stehen, und die erste
  /// Kachelreihe darunter blieb angeschnitten.
  ///
  /// Der Aufrufer zieht ab, was neben der Karte im Block steht, und übergibt
  /// den Rest. Was daraus wird, entscheidet die Karte.
  static double hoeheFuerBlock(double platz) =>
      platz.clamp(TimeMap.minHeight, TimeMap.maxHeight);

  /// Führt zur Chronologie. Vor der Anmeldung `null` — dort gibt es noch
  /// keinen Bereich, in den man springen könnte.
  final VoidCallback? onTap;

  /// Wichtige Orte aus dem Finder auf der Karte.
  ///
  /// Sie beantworten die Frage, die nach „wo war ich" sofort kommt: wo ist
  /// von hier aus das, was ich brauche. Das sind eigene Orte, lokal
  /// gespeichert — sie dürfen auch vor der Anmeldung stehen.
  final bool showPlaces;

  /// Kontakte mit hinterlegtem Ort auf der Karte.
  ///
  /// Nur hinter der Anmeldung. Ein Kontaktort ist die Adresse eines anderen
  /// Menschen; die gehört nicht auf eine Fläche, die jeder sieht, der das
  /// Gerät in die Hand nimmt.
  ///
  /// Das ist der gespeicherte Ort, nicht der aktuelle. Wo jemand *jetzt*
  /// ist, weiß diese App nicht — dafür gäbe es keinen Weg ohne einen Server.
  final bool showContacts;

  /// Der Kopfstrang mit Datum, Uhrzeit und Ort.
  static const kopfSchluessel = Key('time-map-kopf');

  /// Der Hinweis, dass der Standort fehlt.
  static const standortHinweisSchluessel = Key('time-map-standort-hinweis');

  /// So viele Marken passen auf eine Leiste, ohne dass man wischen muss.
  static const int maxPerRail = 3;

  /// Wie weit zurück die Karte schaut.
  ///
  /// Wer die App öffnet, will wissen, was seit gestern war, nicht was letzte
  /// Woche war. Der ganze Verlauf steht in der Zeitachse.
  static const Duration window = Duration(hours: 24);

  /// Baut die Karte aus den laufenden Diensten.
  ///
  /// Beide Aufrufer — Anker und Profilauswahl — brauchen dieselben vier
  /// Datensätze aus denselben Boxen. Einmal hier, nicht zweimal dort.
  ///
  /// [hidePasswordProtected] lässt Anteile mit Passwort ganz weg: Lauflinie,
  /// Wechselpunkte und Marken. Das ist die Einstellung für die
  /// Profilauswahl, die vor jeder Anmeldung steht. Hinter der Anmeldung ist
  /// sie falsch — dort hat sich jemand ausgewiesen.
  static TimeMap fromServices({
    Key? key,
    Profile? profile,
    bool hidePasswordProtected = false,
    double height = 220,
    VoidCallback? onTap,
  }) {
    // Kontakte tragen fremde Adressen. Dieselbe Schwelle wie beim Ort der
    // Anteile: vor der Anmeldung nicht.
    final behindLogin = !hidePasswordProtected;
    final since = DateTime.now().subtract(window);
    bool blocked(String? profileId) {
      if (!hidePasswordProtected || profileId == null) return false;
      final matches = getIt<DataEntry>().getProfiles().where(
        (p) => p.id == profileId,
      );
      return matches.isNotEmpty && matches.first.passwordHash != null;
    }

    final timeline = getIt.isRegistered<TimelineDataService>()
        ? getIt<TimelineDataService>()
        : null;
    final tracking = getIt.isRegistered<LocationTrackingService>()
        ? getIt<LocationTrackingService>()
        : null;

    final track = <LocationHistoryEntry>[];
    if (tracking != null) {
      track.addAll(
        tracking.locationHistoryBox.values
            .where((e) => e.timestamp.isAfter(since))
            .where((e) => !blocked(e.profileId)),
      );
      // Neueste zuerst, so erwartet [OverviewMap] den Pfad.
      track.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    final switches = <ProfileSwitchEvent>[];
    final past = <TimelineEvent>[];
    final upcoming = <TimelineEvent>[];
    if (timeline != null) {
      switches.addAll(
        timeline.profileSwitchBox.values
            .where((e) => e.timestamp.isAfter(since))
            .where((e) => !blocked(e.toProfileId)),
      );
      past.addAll(
        timeline
            .getPastEvents(hours: window.inHours)
            .where(
              (e) =>
                  e.type != TimelineEventType.profileSwitch ||
                  !blocked(e.data?['toProfileId'] as String?),
            ),
      );
      upcoming.addAll(timeline.getUpcomingEvents());
    }

    // Der Ort des nächsten Termins, der einen hat.
    //
    // Nur hinter der Anmeldung: Ein Termin trägt Titel und Adresse, und beides
    // gehört nicht auf eine Fläche, die jeder sieht, der das Gerät in die Hand
    // nimmt. Vor der Anmeldung steht dort nur, *dass* etwas ansteht.
    LatLng? destination;
    String? destinationLabel;
    if (behindLogin) {
      for (final event
          in upcoming..sort((a, b) => a.timestamp.compareTo(b.timestamp))) {
        if (event.type != TimelineEventType.calendarEvent) continue;
        final matches = getIt<DataEntry>().getCalendarEvents().where(
          (e) => e.id == event.id,
        );
        if (matches.isEmpty) continue;
        final calendarEvent = matches.first;
        if (calendarEvent.latitude == null || calendarEvent.longitude == null) {
          continue;
        }
        destination = LatLng(calendarEvent.latitude!, calendarEvent.longitude!);
        destinationLabel = calendarEvent.locationName ?? calendarEvent.title;
        break;
      }
    }

    // Finder-Orte und Kontakte für die Karte vorbereiten
    List<FinderItem>? finderLocations;
    List<Contact>? contactsList;

    if (behindLogin) {
      finderLocations = getIt<DataEntry>()
          .getFinderItemsByType(FinderItemType.location)
          .where((item) => item.latitude != null && item.longitude != null)
          .toList();
      contactsList = getIt<DataEntry>()
          .getContacts()
          .where((c) => c.latitude != null && c.longitude != null)
          .toList();
    } else {
      // Vor der Anmeldung: leere Listen statt null. Das Verhalten bleibt gleich
      // (OverviewMap behandelt null und [] identisch), aber der Intent ist klarer.
      finderLocations = const [];
      contactsList = const [];
    }

    return TimeMap(
      key: key,
      profile: profile,
      height: height,
      onTap: onTap,
      showContacts: behindLogin,
      destination: destination,
      destinationLabel: destinationLabel,
      track: track,
      switchEvents: switches,
      pastEvents: past,
      upcomingEvents: upcoming,
      finderLocations: finderLocations,
      contacts: contactsList,
      profileNameOf: (id) {
        final matches = getIt<DataEntry>().getProfiles().where(
          (p) => p.id == id,
        );
        return matches.isEmpty ? null : matches.first.name;
      },
      profileColorOf: (id) {
        final matches = getIt<DataEntry>().getProfiles().where(
          (p) => p.id == id,
        );
        // Nicht Weiß: Der Weg liegt in einer weißen Fassung, damit er über
        // hellen wie dunklen Kacheln trägt. Ein weißer Kern darin wäre
        // unsichtbar — ausgerechnet dort, wo ein Anteil fehlt und man am
        // ehesten hinschaut.
        return matches.isEmpty
            ? const Color(0xFF3949AB)
            : matches.first.preferredColor;
      },
    );
  }

  List<TimelineEvent> _past() {
    final visible =
        pastEvents.where((e) => timelineVisibleFor(e, profile)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final collapsed = collapseSwitchEpisodes(visible);
    // Die jüngsten stehen dem Jetzt am nächsten und werden zuerst gebraucht.
    return collapsed.length <= maxPerRail
        ? collapsed
        : collapsed.sublist(collapsed.length - maxPerRail);
  }

  List<TimelineEvent> _upcoming() {
    final visible =
        upcomingEvents.where((e) => timelineVisibleFor(e, profile)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return visible.take(maxPerRail).toList();
  }

  /// Ein bekannter Ort genügt.
  ///
  /// Vorher standen hier zwei Punkte — mit der Begründung, ohne Bewegung
  /// zeige die Karte eine Gegend statt einer Geschichte. Das war falsch
  /// gedacht: Es hätte auch die Zeitstränge mitgenommen, und die brauchen
  /// keine Bewegung. Wer einen Tag zu Hause bleibt, verlöre damit die
  /// Anzeige, wer wann vorn war — obwohl sie danebensteht.
  ///
  /// Mit einem Punkt zeigt die Karte, wo man ist. Die Linie zeichnet sie
  /// erst ab zwei, das entscheidet [OverviewMap] für sich.
  bool get hasTrack => track.isNotEmpty;

  /// Wo man gerade ist, in Worten.
  ///
  /// Aus dem jüngsten Positionseintrag, der eine Adresse trägt — die
  /// Rückwärts-Geokodierung läuft beim Aufzeichnen und liegt lokal vor. Trägt
  /// der jüngste keine, wird nach hinten gesucht: Eine Adresse von vor zwanzig
  /// Minuten ist immer noch die Gegend, in der man steht, und besser als
  /// keine.
  String? get _place {
    for (final entry in track) {
      final address = entry.address;
      if (address != null && address.isNotEmpty) return shortPlace(address);
    }
    return null;
  }

  /// Wie weit es bis zum Ziel ist, Luftlinie.
  ///
  /// Unter tausend Metern in Metern, darüber in Kilometern mit einer
  /// Nachkommastelle — „5,2 km" sagt genug, „5237 m" täuscht eine Genauigkeit
  /// vor, die eine Luftlinie über Straßen und Ecken nicht hat.
  ///
  /// `m` und `km` bleiben unübersetzt: Es sind SI-Zeichen und in allen fünf
  /// Sprachen dieselben. Das Komma richtet sich nach der Sprache.
  String? _distanceToDestination(String locale) {
    final target = destination;
    if (target == null || track.isEmpty) return null;
    final here = LatLng(track.first.latitude, track.first.longitude);
    final meters = const Distance()(here, target);
    if (meters < 1000) return '${meters.round()} m';
    return '${NumberFormat('0.#', locale).format(meters / 1000)} km';
  }

  /// Die Ecken des Wegs.
  ///
  /// Das Ziel gehört ausdrücklich **nicht** dazu. Es mit hineinzurechnen war
  /// der naheliegende Versuch, damit die Luftlinie ganz ins Bild passt — am
  /// Gerät wurde daraus eine Karte über zehn Kilometer, auf der keine
  /// Straße mehr zu lesen war. Die erste Frage dieser Fläche ist „wo bin
  /// ich", und die beantwortet nur der nahe Ausschnitt. Die Linie läuft
  /// stattdessen aus dem Bild und zeigt damit die Richtung; wie weit es ist,
  /// steht als Entfernung an der Terminzeile.
  ({double minLat, double maxLat, double minLon, double maxLon}) get _bounds {
    var minLat = track.first.latitude;
    var maxLat = minLat;
    var minLon = track.first.longitude;
    var maxLon = minLon;
    for (final point in track) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }
    return (minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon);
  }

  /// Das Zentrum: die aktuelle Position, nicht die Mitte des Wegs.
  ///
  /// Hier steht die eigene Marke, und um sie herum ordnet sich alles —
  /// Weg, Wechsel, Orte. Die Wegmitte war ein Kompromiss, der den ganzen
  /// Weg ins Bild holte, aber die eine Frage „wo bin ich" an den Rand
  /// schob. Wer den ganzen Weg sehen will, pant oder öffnet die Zeitachse.
  ///
  /// Ohne bekannte Position nimmt [OverviewMap] ihren Rückfallwert.
  LatLng? get _center {
    if (track.isEmpty) return null;
    // [track] ist absteigend sortiert — vorn steht das Jetzt.
    return LatLng(track.first.latitude, track.first.longitude);
  }

  /// Zoomstufe, bei der der ganze Weg ins Bild passt.
  ///
  /// Die Weltkarte ist bei Stufe 0 genau 360 Grad breit und verdoppelt sich
  /// mit jeder Stufe. Aus der Spanne des Wegs folgt die Stufe deshalb direkt;
  /// die abgezogene Stufe lässt Rand, damit die Linie nicht am Rahmen klebt.
  double get _zoom {
    if (track.isEmpty) return 14;
    final b = _bounds;
    // Ein Breitengrad braucht auf dem Schirm mehr Platz als ein Längengrad —
    // in der Mercator-Projektion um 1/cos(Breite), hierzulande rund das
    // Anderthalbfache. Dazu ist die Karte breiter als hoch, also kostet
    // Nord-Süd noch einmal mehr Stufe. Beides zusammen: der Faktor drei.
    final span = math.max((b.maxLat - b.minLat) * 3, b.maxLon - b.minLon);
    // Alles an einem Fleck: Straßenzug statt Kontinent.
    if (span < 0.0005) return 16;
    // Der Abzug lässt Rand für die Beschriftungen, die über ihre Punkte
    // hinausragen. Vorher stand hier eine ganze Stufe — das ist die vierfache
    // Fläche, und der Weg lag als Strich in der Mitte.
    // Untergrenze 12: Auch ein Weg quer durchs Land darf die Karte nicht so
    // weit herausziehen, dass die eigene Straße verschwindet. Dann läuft der
    // Weg eben aus dem Bild — die Richtung bleibt lesbar, „wo bin ich" auch.
    return (math.log(360 / span) / math.ln2 - 0.15).clamp(12.0, 16.0);
  }

  /// Die Abschnitte des Vergangenheitsstrangs: wer war wann vorn.
  ///
  /// Zwischen zwei Wechseln war durchgehend derselbe Anteil da. Der Strang
  /// ist deshalb keine Punktreihe, sondern eine lückenlose Belegung — man
  /// sieht auf einen Blick, wer den Tag getragen hat und wie lange.
  ///
  /// Vor dem ersten bekannten Wechsel steht ein grauer Abschnitt. Er
  /// behauptet nicht, dass niemand da war; er sagt, dass es niemand
  /// aufgeschrieben hat. Bei Zeitverlust ist das der ehrlichere Zustand.
  List<_Span> _spans(DateTime from, DateTime to) {
    final sorted = switchEvents.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final spans = <_Span>[];
    for (var i = 0; i < sorted.length; i++) {
      final start = sorted[i].timestamp.isBefore(from)
          ? from
          : sorted[i].timestamp;
      final rawEnd = i + 1 < sorted.length ? sorted[i + 1].timestamp : to;
      final end = rawEnd.isAfter(to) ? to : rawEnd;
      if (!end.isAfter(start)) continue;
      spans.add(_Span(from: start, to: end, profileId: sorted[i].toProfileId));
    }

    if (spans.isNotEmpty && spans.first.from.isAfter(from)) {
      spans.insert(0, _Span(from: from, to: spans.first.from));
    }
    return spans;
  }

  /// Der Kontakt hinter seinem Punkt auf der Karte.
  ///
  /// Wer nach Stunden an einem fremden Ort hochkommt, sieht auf der Karte
  /// zuerst, dass jemand Vertrautes in der Nähe wohnt. Das allein hilft noch
  /// nicht: Man braucht die Nummer, die Adresse, und was zu diesem Menschen
  /// hinterlegt ist. Deshalb führt der Punkt zu ihm.
  ///
  /// Nur Kontakte. Ein Tipp auf die Karte selbst führt weiter zur Chronologie
  /// — das bleibt so, weil der Kontaktpunkt ein eigener Gegenstand ist und
  /// nicht bloß eine Stelle der Fläche.
  void _openContact(BuildContext context, MarkerType type, String id) {
    if (type != MarkerType.contact) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContactDetailScreen(contactId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Die Karte behauptet „Jetzt" — dann muss ihr Jetzt auch stimmen. Ohne
    // den Ticker fror die Datumszeile auf dem Stand des letzten Aufbaus ein
    // und zeigte nach Minuten auf dem Anker eine falsche Uhrzeit. Für
    // Menschen, die sich an genau dieser Zeile orientieren, ist eine
    // stehende Uhr schlimmer als keine.
    return _EveryMinute(builder: _buildContent);
  }

  Widget _buildContent(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final from = now.subtract(window);
    final past = _past();
    final upcoming = _upcoming();

    // Das nächste Ereignis steht als Zeile am Zukunftsstrang, nicht nur als
    // Kerbe. Die Kerbe sagt „da kommt etwas", aber wer in fünfzig Minuten
    // beim Arzt sein muss, braucht das Was und Wann ohne einen weiteren
    // Schritt. Eine Zeile, nur das nächste — mehr Text verdeckte die Karte.
    final next = upcoming.isEmpty ? null : upcoming.first;
    // Die Entfernung dahinter, wenn der Termin einen Ort hat. Die Luftlinie
    // auf der Karte zeigt die Richtung, aber nicht, ob es zehn Minuten zu Fuß
    // oder eine Fahrt sind — und bei einem entfernten Ziel läuft sie ohnehin
    // aus dem Bild. Ein Wort beantwortet das, ohne die Karte herauszuziehen.
    final away = _distanceToDestination(locale);
    final nextLabel = next == null
        ? null
        : '${DateFormat.Hm(locale).format(next.timestamp)} · '
              '${timelineLabel(next, profileNameOf)}'
              '${away == null ? '' : ' · $away'}';
    // Zum Termin führt die Zeile nur hinter der Anmeldung — davor gibt es
    // keinen Anteil, dessen Rechte den Detailschirm tragen würden.
    final onNextTap =
        next != null &&
            profile != null &&
            next.type == TimelineEventType.calendarEvent
        ? () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => EventDetailScreen(eventId: next.id),
            ),
          )
        : null;

    // Beide Stränge tragen dasselbe Fenster: oben die 24 Stunden bis zum
    // Jetzt, unten die 24 Stunden danach. So heißt „gleich weit vom Rand"
    // auch „gleich weit in der Zeit" — ein Termin in einer Stunde sitzt
    // unten so nah am Jetzt wie ein Wechsel vor einer Stunde oben.
    final horizon = now.add(window);

    // Was diese Karte zeigen kann, hängt an der Standortfreigabe — und mit
    // ihr, wie viel Höhe sie verdient. Beides entscheidet deshalb eine
    // Stelle.
    //
    // Vorher lag die Entscheidung an dreien, und keine kannte die andere: die
    // feste Höhe hier, die Höhe der Karte darin, und zwei innere Abfragen der
    // Freigabe, die je ein Stück ausblendeten. Herausgekommen ist am Gerät
    // eine schwarze Fläche in voller Höhe.
    Widget karte({required bool erlaubt}) {
      final hoehe = height;
      // Der Kopf richtet sich nach der Karte, nicht umgekehrt. Ohne Freigabe
      // steht er allein und immer in seiner kompakten Form.
      final kompakt = !erlaubt || hoehe < TimeMap.compactBelowHeight;

      // Ohne Freigabe gibt es keine Karte — also auch keine Kartenhöhe.
      //
      // Hier stand eine Konstante: 104 dp, „der Kopf allein". Der Kopf ist
      // aber keine 104 dp hoch, und die Differenz war eine schwarze Fläche
      // zwischen den runden Symbolknöpfen und dem Hinweisband darunter. Auf
      // dem S24 fehlten genau diese Zentimeter der ersten Kachelreihe am
      // Anker. Eine Zahl, die den Inhalt beschreibt, driftet vom Inhalt weg;
      // eine Spalte, die ihren Inhalt misst, kann das nicht.
      if (!erlaubt) {
        return _mitHinweis(
          context,
          l10n,
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColoredBox(
              color: Colors.black,
              child: _Strand(
                key: TimeMap.kopfSchluessel,
                fromTop: true,
                spans: _spans(from, now),
                marks: past,
                from: from,
                to: now,
                profileColorOf: profileColorOf,
                profileNameOf: profileNameOf,
                compact: true,
                nowLabel: DateFormat.yMMMEd(locale).format(now),
                nowTimeLabel:
                    '${DateFormat.Hm(locale).format(now)} · '
                    '${timePhaseOf(l10n, now.hour)}',
                placeLabel: _place,
              ),
            ),
          ),
        );
      }

      final stapel = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: hoehe,
          child: Stack(
            fit: StackFit.expand,
            children: [
              OverviewMap(
                height: hoehe,
                // Diese Karte hat ihr eigenes Band unten (`_LocationNotice`).
                // Zwei Bitten um dieselbe Sache, ineinander gezeichnet, waren
                // am 8. August 2026 am Gerät zu sehen.
                showPermissionBanner: false,
                showFinderLocations: showPlaces,
                showContacts: showContacts,
                historyPath: track,
                // Wechselpunkte auf jeder Größe: Sie liegen jetzt zuunterst im
                // Marker-Stapel und verdecken nichts mehr. Vorher waren sie auf
                // kleinen Karten abgeschaltet — ein Behelf gegen ein Problem,
                // das die Rangfolge löst.
                switchEvents: switchEvents,
                initialCenter: _center,
                initialZoom: _zoom,
                pathColorOf: profileColorOf,
                destination: destination,
                destinationLabel: destinationLabel,
                onMarkerTap: (type, id) => _openContact(context, type, id),
                finderLocations: finderLocations,
                contacts: contacts,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _Strand(
                  key: TimeMap.kopfSchluessel,
                  fromTop: true,
                  spans: _spans(from, now),
                  marks: past,
                  from: from,
                  to: now,
                  profileColorOf: profileColorOf,
                  profileNameOf: profileNameOf,
                  compact: kompakt,
                  // Wochentag, Monatsname, Jahr — nicht „06.08.26". Wer nach
                  // Monaten wieder vorn ist, soll nicht drei Zahlen deuten
                  // müssen, um zu wissen, wann er gelandet ist. Der Wochentag
                  // stand vorher in der Zeile, die diese Karte ersetzt; ohne
                  // ihn wäre der Umbau ein Rückschritt für alle, die nur einen
                  // Tag verloren haben.
                  //
                  // Auf der niedrigen Karte werden Wochentag und Monat
                  // abgekürzt, nicht weggelassen: „Fr., 8. Aug. 2026" hält
                  // dieselbe Zusage wie „Freitag, 8. August 2026", nur auf
                  // halber Breite. Zu Ziffern wird es nie.
                  nowLabel: kompakt
                      ? DateFormat.yMMMEd(locale).format(now)
                      : DateFormat.yMMMMEEEEd(locale).format(now),
                  nowTimeLabel:
                      '${DateFormat.Hm(locale).format(now)} · '
                      '${timePhaseOf(l10n, now.hour)}',
                  placeLabel: _place,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _Strand(
                  fromTop: false,
                  spans: const [],
                  marks: upcoming,
                  from: now,
                  to: horizon,
                  profileColorOf: profileColorOf,
                  profileNameOf: profileNameOf,
                  upcomingLabel: nextLabel,
                  onUpcomingTap: onNextTap,
                ),
              ),
            ],
          ),
        ),
      );

      // Der Standorthinweis steht unter der Karte, nicht darin.
      //
      // Er lag als `Positioned(bottom: 0)` im selben Stapel wie der Kopf. Bei
      // großer Systemschrift wird sein Erklärungstext mehrzeilig, wächst nach
      // oben und deckt Datum, Uhrzeit und Ort zu — genau die Angaben, für die
      // diese Karte da ist. Ein Stapel wirft dabei keinen Overflow; in den
      // Logs vom 10. August 2026 war deshalb nichts zu sehen, am Gerät alles.
      return _mitHinweis(context, l10n, stapel, hinweis: false);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: getIt<GpsManager>().hasGpsPermission,
      builder: (context, erlaubt, _) => karte(erlaubt: erlaubt),
    );
  }

  /// Setzt den Hinweis unter die Fläche und macht das Ganze antippbar.
  ///
  /// Der Standorthinweis steht unter der Karte, nicht darin. Er lag als
  /// `Positioned(bottom: 0)` im selben Stapel wie der Kopf. Bei großer
  /// Systemschrift wird sein Erklärungstext mehrzeilig, wächst nach oben und
  /// deckt Datum, Uhrzeit und Ort zu — genau die Angaben, für die diese Karte
  /// da ist. Ein Stapel wirft dabei keinen Overflow; in den Logs vom
  /// 10. August 2026 war deshalb nichts zu sehen, am Gerät alles.
  Widget _mitHinweis(
    BuildContext context,
    AppLocalizations l10n,
    Widget flaeche, {
    bool hinweis = true,
  }) {
    final map = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        flaeche,
        if (hinweis)
          const _LocationNotice(key: TimeMap.standortHinweisSchluessel),
      ],
    );

    if (onTap == null) return map;
    return Semantics(
      button: true,
      label: l10n.timeMapSemantics,
      child: GestureDetector(onTap: onTap, child: map),
    );
  }
}

/// Baut sein Kind einmal pro Minute neu — im Takt der Uhr, nicht der Widgets.
///
/// Nur die Anzeige tickt: Die Daten der Karte kommen weiter vom Aufbau durch
/// den Aufrufer. Eine Minute ist die Auflösung, in der die Zeitkarte spricht;
/// öfter neu zu bauen zeigte nichts Neues.
class _EveryMinute extends StatefulWidget {
  const _EveryMinute({required this.builder});

  final WidgetBuilder builder;

  @override
  State<_EveryMinute> createState() => _EveryMinuteState();
}

class _EveryMinuteState extends State<_EveryMinute> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

/// Ein Abschnitt des Vergangenheitsstrangs: von wann bis wann war wer vorn.
///
/// `profileId == null` heißt: nicht aufgeschrieben.
class _Span {
  const _Span({required this.from, required this.to, this.profileId});

  final DateTime from;
  final DateTime to;
  final String? profileId;
}

/// Ein Zeitstrang am Kartenrand.
///
/// Oben die Vergangenheit, unten die Zukunft. Beide laufen von links nach
/// rechts durch die Zeit und treffen sich am Jetzt — an dem Rand, der zur
/// Karte zeigt. Die Karte dazwischen ist die Gegenwart.
///
/// Der Balken trägt, die Marken bestätigen (Regel 5): Wer nichts liest,
/// sieht an den Farbanteilen trotzdem, wer den Tag getragen hat und ob noch
/// etwas ansteht.
class _Strand extends StatelessWidget {
  const _Strand({
    required this.fromTop,
    required this.spans,
    required this.marks,
    required this.from,
    required this.to,
    required this.profileColorOf,
    required this.profileNameOf,
    this.nowLabel,
    this.nowTimeLabel,
    this.placeLabel,
    this.upcomingLabel,
    this.onUpcomingTap,
    this.compact = false,
    super.key,
  });

  /// Das nächste anstehende Ereignis als lesbare Zeile, statt nur als Kerbe.
  final String? upcomingLabel;

  /// Führt zum Ereignis selbst. `null`, wenn es keinen Schirm dafür gibt.
  final VoidCallback? onUpcomingTap;

  /// Datum und Uhrzeit am Jetzt-Ende des Strangs.
  ///
  /// Steht rechts, weil rechts das Jetzt ist. Und es steht vollständig da —
  /// Tag, Monat, Jahr —, nicht nur die Uhrzeit: Es kommt vor, dass ein
  /// Anteil erst nach Monaten wieder vorn ist. Für den ist die Uhrzeit die
  /// unwichtigste und das Jahr die wichtigste Angabe auf dem Schirm.
  final String? nowLabel;

  /// Uhrzeit und Tagesphase, in einer eigenen Zeile unter dem Datum.
  ///
  /// Getrennt vom Datum, weil beides zusammen in einer Zeile nicht überlebt:
  /// Bei 1,5-facher Systemschrift kürzte die Ellipse ausgerechnet die
  /// Zeitangabe weg — die Angabe, für die die Zeile da ist. Zwei kurze Zeilen
  /// halten, wo eine lange bricht.
  ///
  /// Die Phase steht als Wort dabei, weil 6:00 und 18:00 auf einer Uhr
  /// verwechselbar sind und beim Hochkommen genau das die Frage ist.
  final String? nowTimeLabel;

  /// Der Ort, an dem man gerade ist — als Wort. `null`, wenn unbekannt.
  final String? placeLabel;

  /// Ob der Kopf auf eine niedrige Karte gesetzt wird.
  ///
  /// Der Kopf war absolut gemessen und die Karte nicht: Bei 260 dp nahmen
  /// Datum, Uhrzeit und Ort ein Viertel ein, bei 150 dp fast die Hälfte —
  /// dann blieb von der Karte, für die die Fläche da ist, ein Streifen.
  ///
  /// Gekürzt wird die Schrift, nicht der Inhalt. Alle drei Zeilen bleiben:
  /// Wer nach Monaten wieder vorn ist, braucht das Jahr; wer an einem
  /// fremden Ort hochkommt, den Ort; und 6:00 gegen 18:00 ist die Frage,
  /// für die die Zeitzeile existiert.
  final bool compact;

  /// Oben heißt: Balken am äußeren Rand, Marken zur Karte hin.
  final bool fromTop;

  final List<_Span> spans;
  final List<TimelineEvent> marks;
  final DateTime from;
  final DateTime to;
  final Color Function(String profileId)? profileColorOf;
  final String? Function(String profileId) profileNameOf;

  static const double barHeight = 10;

  /// Durchmesser einer Kerbe auf dem Strang.
  static const double notchSize = 16;

  double _fraction(DateTime at) {
    final total = to.difference(from).inMilliseconds;
    if (total <= 0) return 0;
    return (at.difference(from).inMilliseconds / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final bar = SizedBox(
      height: barHeight,
      child: spans.isEmpty
          // Die Zukunft hat keine Belegung — dort war noch niemand vorn. Sie
          // bekommt eine ruhige Bahn, auf der die Termine sitzen.
          ? ColoredBox(color: Colors.white.withValues(alpha: 0.22))
          : Row(
              children: [
                for (final span in spans)
                  Expanded(
                    flex: span.to
                        .difference(span.from)
                        .inMilliseconds
                        .clamp(1, 1 << 30),
                    child: ColoredBox(
                      color: span.profileId == null
                          ? Colors.white.withValues(alpha: 0.22)
                          : (profileColorOf?.call(span.profileId!) ??
                                Colors.white),
                    ),
                  ),
              ],
            ),
    );

    // Ereignisse sitzen als Kerben AUF dem Strang, mittig auf dem Balken —
    // wie Perlen auf einer Schnur, nicht als eigene Reihe daneben. Der
    // Balken ist die Zeit, die Kerbe der Punkt darin; getrennt gezeichnet
    // musste das Auge beides erst wieder zusammenführen.
    //
    // Beschriftet sind sie weiterhin nicht: In einem Fenster von
    // vierundzwanzig Stunden liegen die Ereignisse eines Vormittags alle im
    // selben Prozent der Breite, drei Beschriftungen übereinander sind
    // unlesbarer als gar keine. Das nächste Ereignis bekommt seine eigene
    // Zeile; für alles andere sagt die Kerbe „hier war etwas" und der Tipp
    // auf den Strang den Rest.
    final rail = SizedBox(
      height: notchSize,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: (notchSize - barHeight) / 2,
                height: barHeight,
                child: bar,
              ),
              for (final event in marks)
                Positioned(
                  left:
                      (_fraction(event.timestamp) * constraints.maxWidth -
                              notchSize / 2)
                          .clamp(
                            0.0,
                            math.max(0.0, constraints.maxWidth - notchSize),
                          ),
                  top: 0,
                  child: Container(
                    width: notchSize,
                    height: notchSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      timelineSymbol(event),
                      size: 9,
                      color: Colors.black87,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
          end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0),
          ],
          stops: const [0, 0.6, 1],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: fromTop
            ? [if (nowLabel != null) _nowLabelRow(), rail]
            : [if (upcomingLabel != null) _upcomingLabelRow(), rail],
      ),
    );
  }

  /// Die Zeile zum nächsten Ereignis, links — dort, wo unten das Jetzt liegt
  /// und damit auch das, was als Nächstes kommt.
  ///
  /// Eine eigene dunkle Fassung statt Vertrauen auf den Verlauf: Die Zeile
  /// liegt am oberen Ende des Verlaufs, wo er schon fast durchsichtig ist,
  /// und muss trotzdem auf jeder Kachel lesbar sein.
  Widget _upcomingLabelRow() {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              upcomingLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (onUpcomingTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: Colors.white70),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
      child: Row(
        children: [
          Flexible(
            child: onUpcomingTap == null
                ? pill
                : GestureDetector(onTap: onUpcomingTap, child: pill),
          ),
        ],
      ),
    );
  }

  Widget _nowLabelRow() {
    final labelSize = compact ? 12.0 : 15.0;
    final placeSize = compact ? 11.0 : 13.0;
    return Padding(
      padding: compact
          ? const EdgeInsets.fromLTRB(10, 4, 10, 2)
          : const EdgeInsets.fromLTRB(10, 6, 10, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nowLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (nowTimeLabel != null)
            Text(
              nowTimeLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          // Der Ort als Wort, unter Tag und Uhrzeit.
          //
          // Die Karte zeigt, wo man ist — aber nur, wenn Kacheln da sind. Wer
          // an einem fremden Ort hochkommt, ist mit einiger Sicherheit in
          // einer Gegend, die noch nie geladen wurde; ohne Netz bleibt die
          // Fläche dann grau. Die Adresse steht ohnehin in jedem
          // Positionseintrag, rückwärts geokodiert und lokal gespeichert.
          // Sie hier zu zeigen kostet nichts und trägt allein.
          if (placeLabel != null)
            Text(
              placeLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: placeSize,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
        ],
      ),
    );
  }
}

/// Der Hinweis am unteren Kartenrand, wenn der Standort fehlt.
///
/// Er steht dort, wo sonst die Zukunft laeuft — an der Kante, die zur Karte
/// zeigt, also direkt an dem, was ohne Standort leer bleibt.
///
/// Er sagt beides in einem Satz: dass die Karte den Standort braucht, und
/// dass er das Geraet nicht verlaesst. Die zweite Haelfte ist keine
/// Beruhigung, sie ist der Grund. Wer eine App fuer Gesundheitsdaten nach
/// dem Standort fragt, schuldet die Antwort, wohin er geht — und hier lautet
/// sie: nirgendwohin.
class _LocationNotice extends StatelessWidget {
  const _LocationNotice({super.key});

  Future<void> _ask() async {
    final gps = getIt<GpsManager>();
    // `askIfDenied: true`, weil hier jemand auf „Erlauben" getippt hat — der
    // einzige Ort in dieser Karte, an dem gefragt werden darf. Ohne das Flag
    // fragte der Knopf gar nicht: `getUserPosition` schweigt bei fehlender
    // Berechtigung und gibt null zurück, und der Griff landete direkt in den
    // Systemeinstellungen — ein Umweg, den der Knopf nicht ankündigt.
    //
    // Kommt danach immer noch keine Position, hat das System dauerhaft
    // abgelehnt; dann ist die Systemeinstellung tatsächlich der einzige Weg.
    final position = await gps.getUserPosition(askIfDenied: true);
    if (position == null && !gps.hasGpsPermission.value) {
      await gps.openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                // Ohne Deckel wächst die Zeile ins Unendliche und schiebt den
                // Knopf aus dem Bild. Mit Deckel bricht sie um.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width - 80,
                  ),
                  child: Text(
                    l10n.mapLocationNeeded,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            // Der Knopf trägt seine Farbe selbst.
            //
            // Symbol und Text daneben stehen fest auf Weiß, weil dieses Band
            // seinen eigenen schwarzen Verlauf mitbringt und nicht weiß, was
            // unter ihm liegt. Der Knopf tat das als Einziges nicht und nahm
            // `colorScheme.primary` von dort, wo er gerade eingebaut war: auf
            // der Profilauswahl violett, am Anker hellblau — derselbe Satz in
            // zwei Farben, am 11. August 2026 am Gerät nebeneinander zu
            // sehen. Farbe soll hier ohnehin nichts rufen (Richtlinie 4): Eine
            // Berechtigungsfrage ist nie das, was im schlechtesten Zustand
            // gefunden werden muss.
            //
            // Das Symbol kommt dazu, weil ein Wort allein keine Handlung
            // zeigt (Richtlinie 5) — und weil ohne Farbunterschied sonst gar
            // nichts mehr sagt, dass hier etwas anzutippen ist.
            TextButton.icon(
              onPressed: _ask,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: const Icon(Icons.my_location, size: 18),
              label: Text(l10n.mapLocationAllow),
            ),
          ],
        ),
      ),
    );
  }
}
