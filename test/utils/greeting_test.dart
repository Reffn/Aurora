import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/time_phase.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Gruß über dem Namen auf dem Anker.
///
/// Vier Grenzen, und eine davon ist keine Geschmacksfrage: Nachts darf nicht
/// verabschiedet werden. „Gute Nacht" heißt im Deutschen Abschied, und wer um
/// drei Uhr nach vorn kommt, kommt an.
void main() {
  late AppLocalizations de;
  late AppLocalizations it;
  late AppLocalizations fr;

  setUpAll(() async {
    de = await AppLocalizations.delegate.load(const Locale('de'));
    it = await AppLocalizations.delegate.load(const Locale('it'));
    fr = await AppLocalizations.delegate.load(const Locale('fr'));
  });

  // Die Tönung des Ankers hängt an derselben Stunde wie der Gruß. Liefen die
  // beiden auseinander, stünde „Guten Abend" auf einer Fläche, die noch nach
  // Mittag aussieht — und die Fläche ist das, was ohne Lesen ankommt.
  test('Tönung und Gruß wechseln zur selben Stunde', () {
    for (var hour = 0; hour < 24; hour++) {
      final gleicherGruss = greetingOf(de, hour) == greetingOf(de, hour - 1);
      final gleicheToenung = anchorTintOf(hour) == anchorTintOf(hour - 1);
      if (hour > 0) {
        expect(
          gleicheToenung,
          gleicherGruss,
          reason: 'Bei $hour Uhr wechselt nur eines von beiden.',
        );
      }
    }
  });

  test('jede Tagesphase hat ihre eigene Tönung', () {
    final toenungen = {
      anchorTintOf(7),
      anchorTintOf(13),
      anchorTintOf(20),
      anchorTintOf(2),
    };
    expect(toenungen.length, 4, reason: 'Vier Phasen, vier Farben.');
  });

  test('die vier Grenzen liegen, wo sie liegen sollen', () {
    expect(greetingOf(de, 4), de.greetingNight);
    expect(greetingOf(de, 5), de.greetingMorning);
    expect(greetingOf(de, 10), de.greetingMorning);
    expect(greetingOf(de, 11), de.greetingDay);
    expect(greetingOf(de, 17), de.greetingDay);
    expect(greetingOf(de, 18), de.greetingEvening);
    expect(greetingOf(de, 22), de.greetingEvening);
    expect(greetingOf(de, 23), de.greetingNight);
  });

  test('jede Stunde des Tages hat einen Gruß', () {
    for (var h = 0; h < 24; h++) {
      expect(greetingOf(de, h), isNotEmpty, reason: 'Stunde $h');
    }
  });

  // Diese Prüfung ist der Grund für den eigenen Schlüssel statt einer
  // Ableitung aus `timePhaseOf`: Die Tagesphase darf „nachts" sagen, der
  // Gruß darf es nicht.
  test('nachts wird nicht verabschiedet', () {
    expect(greetingOf(de, 2), isNot(contains('Gute Nacht')));
    expect(greetingOf(it, 2), isNot(contains('Buonanotte')));
    expect(greetingOf(fr, 2), isNot(contains('Bonne nuit')));
  });
}
