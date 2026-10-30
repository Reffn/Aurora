import 'dart:async';

import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/profile_events.dart';
import 'package:hive_ce/hive.dart';

/// Merker in der settings-Box: Die Einrichtung wurde schon gemeldet.
const String einrichtungGemeldetKey = 'einrichtung_gemeldet';

/// Meldet „Einrichtung abgeschlossen“ — einmal je Installation.
///
/// Bis zum 13.08.2026 war das der größte blinde Fleck: Onboarding-Abbrüche
/// wurden seitengenau gezählt, und danach kam nichts mehr. Wer beim ersten
/// Profil aufgab, hinterließ keine Spur.
///
/// Angehängt wird am EventBus, nicht an `DataEntry` oder `ProfileService`:
/// Beide sollen nichts von Telemetrie wissen.
///
/// **Einmal, nicht je Profil.** Firestore setzt `createTime` serverseitig;
/// drei Eingänge derselben Minute wären lesbar als „dieses System hat drei
/// Anteile“. Der Merker wird deshalb VOR dem Melden gesetzt: Bricht der
/// Versand ab, bleibt die Meldung aus — eine doppelte wäre schlimmer als
/// eine fehlende.
///
/// Stand bis 3.0.24 inline in `setupDeferredDependencies`, das kein Test
/// aufrufen kann. Herausgelöst, damit die Zusage einen Test hat — der kurze
/// Einstieg ab 3.0.25 hängt an genau diesem Ereignis.
StreamSubscription<ProfileCreatedEvent> meldeEinrichtungEinmal({
  required EventBus eventBus,
  required Box<dynamic> settingsBox,
  required Future<void> Function() melde,
}) {
  return eventBus.on<ProfileCreatedEvent>().listen((_) async {
    if (settingsBox.get(einrichtungGemeldetKey) == true) return;

    await settingsBox.put(einrichtungGemeldetKey, true);
    await melde();
  });
}
