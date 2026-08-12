import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/time_phase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Die Tagesphase ist die Antwort auf „wann bin ich" — nicht „wie spät".
///
/// Geprüft werden die Grenzen, weil dort die Verwechslung sitzt, gegen die
/// das Wort überhaupt existiert: 6:00 und 18:00 sehen auf einer Uhr gleich
/// aus, „morgens" und „abends" nicht.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('de'));
  });

  test('trennt Morgen und Abend, die auf der Uhr verwechselbar sind', () {
    expect(timePhaseOf(l10n, 6), l10n.timePhaseMorning);
    expect(timePhaseOf(l10n, 18), l10n.timePhaseEvening);
    expect(timePhaseOf(l10n, 6), isNot(timePhaseOf(l10n, 18)));
  });

  test('deckt jede Stunde des Tages ab', () {
    for (var hour = 0; hour < 24; hour++) {
      expect(timePhaseOf(l10n, hour), isNotEmpty, reason: 'Stunde $hour');
    }
  });

  test('hält die Grenzen der fünf Phasen', () {
    expect(timePhaseOf(l10n, 4), l10n.timePhaseNight);
    expect(timePhaseOf(l10n, 5), l10n.timePhaseMorning);
    expect(timePhaseOf(l10n, 10), l10n.timePhaseMorning);
    expect(timePhaseOf(l10n, 11), l10n.timePhaseMidday);
    expect(timePhaseOf(l10n, 13), l10n.timePhaseMidday);
    expect(timePhaseOf(l10n, 14), l10n.timePhaseAfternoon);
    expect(timePhaseOf(l10n, 17), l10n.timePhaseAfternoon);
    expect(timePhaseOf(l10n, 18), l10n.timePhaseEvening);
    expect(timePhaseOf(l10n, 22), l10n.timePhaseEvening);
    expect(timePhaseOf(l10n, 23), l10n.timePhaseNight);
  });
}
