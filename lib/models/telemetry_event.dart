/// Die Whitelist der Ereignisse, die Aurora senden darf.
///
/// Die `wireName`-Werte sind stabile Schluessel, keine Beschriftungen. Sie
/// werden bewusst nicht aus `tab.tabItem.label` abgeleitet: Anzeigetexte
/// aendern sich, und eine Umbenennung wuerde sonst jede Zeitreihe zerreissen.
///
/// Dieselbe Liste steht in `firestore.rules`. Ein Test vergleicht beide —
/// was hier dazukommt und dort fehlt, wird vom Server abgewiesen.
enum TelemetryEventName {
  // Onboarding. Der Abbruch ist ein eigenes Ereignis, damit nie eine
  // Schrittfolge das Geraet verlaesst.
  onboardingBegonnen('onboarding_begonnen'),
  onboardingBeendet('onboarding_beendet'),
  onboardingAbgebrochenWillkommen('onboarding_abgebrochen_willkommen'),
  onboardingAbgebrochenPrivacy('onboarding_abgebrochen_privacy'),
  onboardingAbgebrochenFeatures('onboarding_abgebrochen_features'),
  onboardingAbgebrochenProfile('onboarding_abgebrochen_profile'),
  onboardingAbgebrochenLosGehts('onboarding_abgebrochen_los_gehts'),

  // Anker-Bereiche. Gezaehlt wird ausschliesslich das Oeffnen — auch bei
  // Halt, Notfall und Hilfe. Was innerhalb dieser Bereiche geschieht,
  // erzeugt nie ein Ereignis.
  bereichGeoeffnetHalt('bereich_geoeffnet_halt'),
  bereichGeoeffnetNotfall('bereich_geoeffnet_notfall'),
  bereichGeoeffnetHilfe('bereich_geoeffnet_hilfe'),
  bereichGeoeffnetChat('bereich_geoeffnet_chat'),
  bereichGeoeffnetKalender('bereich_geoeffnet_kalender'),
  bereichGeoeffnetMedikamente('bereich_geoeffnet_medikamente'),
  bereichGeoeffnetTagebuch('bereich_geoeffnet_tagebuch'),
  bereichGeoeffnetKontakte('bereich_geoeffnet_kontakte'),
  bereichGeoeffnetFinder('bereich_geoeffnet_finder'),
  bereichGeoeffnetSpiele('bereich_geoeffnet_spiele'),
  bereichGeoeffnetZeitachse('bereich_geoeffnet_zeitachse'),
  bereichGeoeffnetFeedback('bereich_geoeffnet_feedback'),

  // Uebungen. Abschluss gegen Abbruch misst nicht, ob es geholfen hat,
  // sondern ob es tragbar war. Nach Wirkung wird nicht gefragt.
  uebungBeendetOrientation('uebung_beendet_orientation'),
  uebungBeendetSenses('uebung_beendet_senses'),
  uebungBeendetBody('uebung_beendet_body'),
  uebungBeendetContainer('uebung_beendet_container'),
  uebungBeendetBreath('uebung_beendet_breath'),
  uebungAbgebrochenOrientation('uebung_abgebrochen_orientation'),
  uebungAbgebrochenSenses('uebung_abgebrochen_senses'),
  uebungAbgebrochenBody('uebung_abgebrochen_body'),
  uebungAbgebrochenContainer('uebung_abgebrochen_container'),
  uebungAbgebrochenBreath('uebung_abgebrochen_breath'),

  // Fehler. Nur der Name — Details bleiben lokal und verlassen das Geraet
  // ausschliesslich ueber den Feedback-Kanal, wenn die Nutzerin sie
  // ausdruecklich mitschickt.
  fehlerSpeichern('fehler_speichern'),
  fehlerAnhang('fehler_anhang'),
  fehlerGpsTimeout('fehler_gps_timeout'),

  // Ob die App traegt — nicht, was jemand mit ihr tut.
  //
  // Die Linie zwischen diesen vier und dem, was bewusst fehlt: Gemessen wird
  // die **Funktionsfaehigkeit**, nie das **Verhalten**. Dass eine Erinnerung
  // geplant wurde, sagt etwas ueber den Reminder-Pfad; dass jemand einen
  // Tagebucheintrag geschrieben hat, sagt etwas ueber einen Menschen. Nur das
  // Erste steht hier.
  //
  // Dieselbe Linie erklaert, warum es die Uebungen oben schon gibt: Abschluss
  // gegen Abbruch misst Tragbarkeit, nicht Wirkung.

  // Die groesste Luecke bis zum 13.08.2026: Onboarding-Abbrueche wurden
  // seitengenau gezaehlt, der Schritt danach gar nicht. Wer beim ersten Profil
  // aufgab, war unsichtbar.
  //
  // **Einmal je Installation, lokal entprellt.** Ein Ereignis je angelegtem
  // Profil waere etwas anderes: Firestore setzt `createTime` serverseitig,
  // drei Eingaenge derselben Minute liessen sich als „dieses System hat drei
  // Anteile" lesen. Genau diese Zaehlung schliesst die Zusage aus.
  einrichtungAbgeschlossen('einrichtung_abgeschlossen'),

  // Der Bereich mit der laengsten Fehlergeschichte hatte keine Telemetrie:
  // fehlende Empfaenger, von R8 verworfene Signaturen, Kennungen ohne
  // Zeitpunkt — jedes Mal fielen Erinnerungen lautlos aus. Geplant heisst
  // hier: an das System uebergeben, nicht ausgeloest.
  erinnerungGeplant('erinnerung_geplant'),

  // Wer Benachrichtigungen ablehnt, hat eine Medikamenten-App ohne
  // Erinnerungen. Das ist ein plausibler Loeschgrund und ohne dieses Ereignis
  // nicht erkennbar. Nur diese eine Berechtigung — Kamera, Mikrofon und Ort
  // abzulehnen ist eine Vorliebe, keine kaputte Funktion.
  berechtigungVerweigertBenachrichtigungen(
    'berechtigung_verweigert_benachrichtigungen',
  ),

  // Wiederoeffnen, nicht Kaltstart. Der Name sagt, was gemessen wird: Der
  // Lebenszyklus-Beobachter sieht die Rueckkehr aus dem Hintergrund. „App
  // geoeffnet" waere gelogen — davor liegen Einwilligung, Profilwahl und der
  // Neuerungs-Schirm.
  appFortgesetzt('app_fortgesetzt');

  const TelemetryEventName(this.wireName);

  final String wireName;

  /// Loest einen gespeicherten Schluessel zurueck in seinen Enum-Wert.
  ///
  /// Gibt `null` zurueck, wenn diese Version den Namen nicht kennt — etwa bei
  /// einem Eintrag aus einer aelteren Warteschlange. Dann wird nichts
  /// gesendet statt etwas Falsches.
  static TelemetryEventName? fromWireName(String wireName) {
    for (final candidate in values) {
      if (candidate.wireName == wireName) return candidate;
    }
    return null;
  }
}

/// Was bei der Telemetrie das Geraet verlaesst.
///
/// Drei Felder, mehr nicht: kein Zaehler, kein Wert, keine Kennung. Standort-
/// und Identifikatorfelder sind hier strukturell nicht vorgesehen — das
/// Schema ist die Stelle, an der die Kanaltrennung durchgesetzt und getestet
/// wird.
class TelemetryEvent {
  const TelemetryEvent({
    required this.name,
    required this.at,
    required this.appVersion,
  });

  final TelemetryEventName name;

  /// Nur der Tag daraus wird gesendet. Mit Sekundengenauigkeit liessen sich
  /// Ereignisse desselben Geraets ueber Zeitnaehe wieder zu einer Sitzung
  /// zusammensetzen — die Uhr taete dann die Verkettung, die das Schema
  /// verweigert.
  final DateTime at;

  final String appVersion;

  String get day => formatDay(at);

  static String formatDay(DateTime moment) {
    final month = moment.month.toString().padLeft(2, '0');
    final day = moment.day.toString().padLeft(2, '0');
    return '${moment.year}-$month-$day';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'event': name.wireName,
      'day': day,
      'appVersion': appVersion,
    };
  }

  /// Woertliche Darstellung fuer das Uebertragungsprotokoll.
  /// Muss exakt das zeigen, was gesendet wird.
  String toPlainText() {
    return 'Ereignis: ${name.wireName}\n'
        'Tag: $day\n'
        'App-Version: $appVersion';
  }
}
