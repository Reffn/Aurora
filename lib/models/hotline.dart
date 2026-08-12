import 'package:dis_app/l10n/app_texts.dart';
import 'package:flutter/material.dart';

/// Wann ein Angebot erreichbar ist.
///
/// Der Unterschied steht hier im Modell und nicht nur im Text, weil die
/// Hilfefläche danach gruppiert. Eine flache Liste unter einer
/// 24/7-Überschrift war der Fehler, den dieser Typ ausschließt.
enum HotlineAvailability {
  /// Tag und Nacht erreichbar, ohne Ausnahme.
  roundTheClock,

  /// Nur zu bestimmten Zeiten oder für eine bestimmte Gruppe.
  limited,
}

/// Model für vordefinierte Notfall-Hotlines
class Hotline {
  const Hotline({
    required this.name,
    required this.description,
    required this.icon,
    required this.availability,
    required this.source,
    required this.verifiedOn,
    this.phone,
    this.website,
    this.hours,
  }) : assert(
         phone != null || website != null,
         'Either phone or website must be provided',
       );

  final String name;
  final String description;
  final IconData icon;
  final String? phone; // Telefonnummer zum Anrufen
  final String? website; // Website-URL (für Chat-basierte Dienste)

  /// Ob das Angebot rund um die Uhr erreichbar ist.
  final HotlineAvailability availability;

  /// Die Erreichbarkeit im Klartext, wenn sie begrenzt ist.
  ///
  /// Steht auf der Karte selbst. Wer in einer Krise anruft, soll die Zeiten
  /// sehen, bevor er wählt — ein erfolgloser Anruf ist dann keine neutrale
  /// Sackgasse, sondern kann als „Hilfe ist gerade grundsätzlich nicht
  /// erreichbar" gelesen werden.
  final String? hours;

  /// Wo die Angaben herkommen. Die Seite des Anbieters, nichts Drittes.
  final String source;

  /// Wann zuletzt an dieser Quelle nachgesehen wurde.
  ///
  /// Steht hier, damit veraltete Zeiten auffindbar sind statt unbemerkt zu
  /// bleiben. Die Zeiten des Info-Telefons standen über Monate falsch in der
  /// App, weil niemand ein Datum hatte, an dem er sie hätte messen können.
  final DateTime verifiedOn;

  /// Gibt true zurück, wenn dies eine Telefon-Hotline ist
  bool get isPhoneHotline => phone != null;

  /// Gibt true zurück, wenn dies eine Website-basierte Hotline ist
  bool get isWebsiteHotline => website != null;

  /// Ob dieses Angebot unter eine 24/7-Überschrift gehört.
  bool get isRoundTheClock => availability == HotlineAvailability.roundTheClock;
}

/// Der Tag, an dem alle Angaben unten zuletzt an der Quelle geprüft wurden.
///
/// **Wer Zeiten ändert, ändert auch dieses Datum** — und sieht vorher auf den
/// verlinkten Seiten nach, statt sie fortzuschreiben.
final DateTime hotlineAngabenGeprueftAm = DateTime(2026, 8, 10);

/// Vordefinierte Notfall-Hotlines für Deutschland.
///
/// Eine Funktion und keine Liste: Die Beschreibungen kommen aus
/// [AppTexts.current]. Eine `final`-Liste auf oberster Ebene wird einmal
/// ausgewertet und behielte danach die Sprache des ersten Zugriffs — ein
/// Sprachwechsel ginge lautlos an ihr vorbei.
List<Hotline> germanEmergencyHotlines() {
  final texte = AppTexts.current;

  return [
    // Geprüft am 10.08.2026: „Sie können uns Tag und Nacht anrufen",
    // gebührenfrei und anonym. Die dritte Nummer 116 123 stand bisher nicht
    // in Aurora, obwohl der Anbieter sie gleichrangig nennt.
    Hotline(
      name: 'Telefonseelsorge',
      phone: '0800 111 0 111',
      description: texte.hotlineAnonymousFree,
      icon: Icons.phone_in_talk,
      availability: HotlineAvailability.roundTheClock,
      source: 'https://www.telefonseelsorge.de/telefon/',
      verifiedOn: hotlineAngabenGeprueftAm,
    ),
    Hotline(
      name: 'Telefonseelsorge (alternativ)',
      phone: '0800 111 0 222',
      description: texte.hotlineAnonymousFree,
      icon: Icons.phone_in_talk,
      availability: HotlineAvailability.roundTheClock,
      source: 'https://www.telefonseelsorge.de/telefon/',
      verifiedOn: hotlineAngabenGeprueftAm,
    ),
    Hotline(
      name: 'Telefonseelsorge (116 123)',
      phone: '116 123',
      description: texte.hotlineAnonymousFree,
      icon: Icons.phone_in_talk,
      availability: HotlineAvailability.roundTheClock,
      source: 'https://www.telefonseelsorge.de/telefon/',
      verifiedOn: hotlineAngabenGeprueftAm,
    ),
    // Geprüft am 10.08.2026: „Wir beraten dich montags bis samstags von
    // 14 Uhr bis 20 Uhr am Telefon." Aurora nannte bisher gar keine Zeiten.
    Hotline(
      name: 'Nummer gegen Kummer',
      phone: '116 111',
      description: texte.hotlineForYoung,
      hours: texte.hotlineHoursNumberAgainstSorrow,
      icon: Icons.child_care,
      availability: HotlineAvailability.limited,
      source: 'https://www.nummergegenkummer.de/kinder-und-jugendberatung/',
      verifiedOn: hotlineAngabenGeprueftAm,
    ),
    // Geprüft am 10.08.2026: „Mo, Di, Do: 13:00 – 17:00 Uhr / Mi, Fr:
    // 08:30 – 12:30 Uhr". Aurora nannte „Mo-Do 13-17, Di+Do 19-21" — die
    // Abendzeiten gibt es nicht mehr, die Vormittage fehlten.
    Hotline(
      name: 'Info-Telefon Depression',
      phone: '0800 33 44 533',
      description: texte.hotlineInfoNotAcute,
      hours: texte.hotlineHoursDepressionInfo,
      icon: Icons.psychology,
      availability: HotlineAvailability.limited,
      source: 'https://www.deutsche-depressionshilfe.de/hilfe/info-telefon',
      verifiedOn: hotlineAngabenGeprueftAm,
    ),
    // Geprüft am 10.08.2026 auf der Angebotsseite: Der Anbieter überschreibt
    // seinen eigenen Abschnitt mit „24/7 Krisenberatung für junge Menschen"
    // und schreibt „Wir sind jederzeit erreichbar". Kostenfrei, vertraulich,
    // für alle unter 25.
    //
    // Die Altersgrenze steht in der Beschreibung und nicht in der Gruppe:
    // Die Gruppen ordnen nach Erreichbarkeit, die Karte nennt die Zielgruppe.
    Hotline(
      name: 'Krisenchat',
      website: 'https://krisenchat.de',
      description: texte.hotlineChatUnder25,
      icon: Icons.chat,
      availability: HotlineAvailability.roundTheClock,
      source: 'https://www.krisenchat.de/uber-uns/unser-angebot',
      verifiedOn: hotlineAngabenGeprueftAm,
    ),
  ];
}
