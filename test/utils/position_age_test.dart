import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/position_age.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatPositionAge', () {
    test('ganz frisch heißt gerade eben', () {
      expect(formatPositionAge(const Duration(seconds: 40)), 'gerade eben');
      expect(formatPositionAge(Duration.zero), 'gerade eben');
    });

    test('innerhalb einer Stunde in Minuten', () {
      expect(formatPositionAge(const Duration(minutes: 7)), 'vor 7 Minuten');
      expect(formatPositionAge(const Duration(minutes: 59)), 'vor 59 Minuten');
    });

    test('darüber in Stunden, Einzahl ausgeschrieben', () {
      expect(formatPositionAge(const Duration(minutes: 60)), 'vor einer Stunde');
      expect(formatPositionAge(const Duration(hours: 5)), 'vor 5 Stunden');
    });

    // Der Grund für die Feinheit: „vor einer Stunde" galt von sechzig bis
    // hundertneunzehn Minuten. Wer nach zwei Stunden Zeitverlust hochkommt und
    // wissen will, wie lange er weg war, bekam eine halbe Stunde Unschärfe.
    test('bis sechs Stunden zurück stehen die Minuten dabei', () {
      expect(formatPositionAge(const Duration(minutes: 90)), 'vor 1 Std 30 Min');
      expect(
        formatPositionAge(const Duration(hours: 3, minutes: 20)),
        'vor 3 Std 20 Min',
      );
    });

    test('die Minuten werden auf fünf gerundet', () {
      // Eine Messung im Zwei-Minuten-Takt trägt keine Minutengenauigkeit.
      expect(formatPositionAge(const Duration(minutes: 97)), 'vor 1 Std 35 Min');
      expect(formatPositionAge(const Duration(minutes: 93)), 'vor 1 Std 35 Min');
    });

    test('auf der vollen Stunde bleibt es bei der Stunde allein', () {
      expect(formatPositionAge(const Duration(minutes: 60)), 'vor einer Stunde');
      expect(formatPositionAge(const Duration(minutes: 62)), 'vor einer Stunde');
      // Aufgerundet auf sechzig Minuten heißt: eine Stunde weiter.
      expect(formatPositionAge(const Duration(minutes: 118)), 'vor 2 Stunden');
    });

    test('ab sechs Stunden wieder grob in Stunden', () {
      expect(
        formatPositionAge(const Duration(hours: 6, minutes: 20)),
        'vor 6 Stunden',
      );
    });

    test('ab einem Tag in Tagen', () {
      expect(formatPositionAge(const Duration(hours: 24)), 'von gestern');
      expect(formatPositionAge(const Duration(days: 3)), 'vor 3 Tagen');
    });

    // Der Fall, um den es geht: Auf der Notfallkarte stand eine gespeicherte
    // Position ohne jeden Hinweis auf ihr Alter. Eine Position von vorletzter
    // Woche, die aussieht wie der aktuelle Standort, führt Helfende in die
    // Irre — schlimmer als eine Karte, die nichts zeigt.
    test('auch sehr alte Positionen bekommen eine klare Angabe', () {
      expect(formatPositionAge(const Duration(days: 12)), 'vor 12 Tagen');
    });
  });

  group('mapLastKnownPosition traegt formatPositionAge ohne Dopplung', () {
    testWidgets('deutsch', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox();
          }),
        ),
      );

      final gestern = l10n.mapLastKnownPosition(
        formatPositionAge(const Duration(hours: 24)),
      );
      final minuten = l10n.mapLastKnownPosition(
        formatPositionAge(const Duration(minutes: 7)),
      );

      expect(gestern, isNot(contains('von von')));
      expect(minuten, isNot(contains('von vor')));
      expect(gestern, contains('von gestern'));
      expect(minuten, contains('vor 7 Minuten'));
    });
  });
}
