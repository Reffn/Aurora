import 'package:dis_app/models/hotline.dart';
import 'package:flutter_test/flutter_test.dart';

/// Was unter einer 24/7-Überschrift stehen darf.
///
/// Die Hilfefläche überschrieb bis zum 10. August ihre ganze Liste mit
/// „24/7 Notfall-Hotlines" und „jederzeit erreichbar". Das stimmte für die
/// Telefonseelsorge — nicht für „Nummer gegen Kummer" (Mo–Sa 14–20 Uhr),
/// nicht für das Info-Telefon Depression und nicht für den Krisenchat.
///
/// In einer Krise ist ein erfolgloser Anruf keine neutrale Sackgasse: Die
/// Person kann daraus schließen, Hilfe sei gerade grundsätzlich nicht
/// erreichbar. Diese Prüfung hält die Zusage an das fest, was der Anbieter
/// tatsächlich sagt.
void main() {
  final angebote = germanEmergencyHotlines();

  Hotline mitNamen(String teil) =>
      angebote.firstWhere((h) => h.name.contains(teil));

  test('Unter „rund um die Uhr" steht nur, wer das selbst zusagt', () {
    final durchgehend =
        angebote.where((h) => h.isRoundTheClock).map((h) => h.name).toList();

    // Telefonseelsorge: „Sie können uns Tag und Nacht anrufen" — alle drei
    // Nummern, auch die 116 123, die bisher fehlte.
    // Krisenchat: „24/7 Krisenberatung für junge Menschen".
    expect(durchgehend, hasLength(4));
    expect(
      durchgehend.where((n) => n.contains('Telefonseelsorge')),
      hasLength(3),
    );
    expect(durchgehend, contains('Krisenchat'));
  });

  test('Zeitlich begrenzt sind genau die beiden Telefonangebote', () {
    final begrenzt =
        angebote.where((h) => !h.isRoundTheClock).map((h) => h.name).toList();

    expect(begrenzt, hasLength(2));
    expect(begrenzt.any((n) => n.contains('Kummer')), isTrue);
    expect(begrenzt.any((n) => n.contains('Depression')), isTrue);
  });

  test('Wer nicht durchgehend erreichbar ist, nennt seine Zeiten oder Grenze',
      () {
    for (final angebot in angebote.where((h) => !h.isRoundTheClock)) {
      final sagtEtwas =
          (angebot.hours != null && angebot.hours!.isNotEmpty) ||
              angebot.description.isNotEmpty;
      expect(
        sagtEtwas,
        isTrue,
        reason:
            '${angebot.name} steht nicht unter der 24/7-Überschrift und muss '
            'deshalb auf der Karte sagen, wann oder für wen es gilt.',
      );
    }
  });

  test('Kein durchgehendes Angebot trägt eine Zeitangabe', () {
    for (final angebot in angebote.where((h) => h.isRoundTheClock)) {
      expect(
        angebot.hours,
        isNull,
        reason: '${angebot.name} ist immer erreichbar — eine Zeitangabe wäre '
            'eine Einschränkung, die es nicht gibt.',
      );
    }
  });

  test('Die geprüften Zeiten stehen so da wie beim Anbieter', () {
    // Geprüft am 10.08.2026 auf nummergegenkummer.de: „montags bis samstags
    // von 14 Uhr bis 20 Uhr".
    expect(mitNamen('Kummer').hours, 'Mo–Sa 14–20 Uhr');

    // Geprüft am 10.08.2026 auf deutsche-depressionshilfe.de: „Mo, Di, Do:
    // 13:00 – 17:00 Uhr / Mi, Fr: 08:30 – 12:30 Uhr". Die früher genannten
    // Abendzeiten „Di+Do 19-21" gibt es nicht mehr.
    expect(
      mitNamen('Depression').hours,
      'Mo, Di, Do 13–17 Uhr · Mi, Fr 8:30–12:30 Uhr',
    );
  });

  test('Der Krisenchat nennt seine Altersgrenze auf der Karte', () {
    final chat = mitNamen('Krisenchat');

    // Er ist rund um die Uhr erreichbar, aber nicht für jeden. Die Gruppe
    // ordnet nach Erreichbarkeit — wer nicht gemeint ist, muss es trotzdem
    // sehen, bevor er schreibt.
    expect(chat.isRoundTheClock, isTrue);
    expect(chat.description, contains('25'));
  });

  test('Jedes Angebot nennt Quelle und Prüfdatum', () {
    for (final angebot in angebote) {
      expect(
        angebot.source,
        startsWith('https://'),
        reason: '${angebot.name} braucht die Seite des Anbieters als Beleg.',
      );
      expect(angebot.verifiedOn, hotlineAngabenGeprueftAm);
    }
  });

  test('Die Liste wird bei jedem Aufruf neu gebaut', () {
    // Sonst behielte sie die Sprache des ersten Zugriffs: Die Beschreibungen
    // kommen aus AppTexts.current, und eine `final`-Liste auf oberster Ebene
    // wird genau einmal ausgewertet.
    expect(identical(germanEmergencyHotlines(), angebote), isFalse);
  });
}
