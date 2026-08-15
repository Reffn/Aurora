import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_localizations_de.dart';
import 'package:dis_app/l10n/app_localizations_en.dart';
import 'package:dis_app/l10n/app_localizations_fr.dart';
import 'package:dis_app/models/feedback_category.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bis zum 11. August 2026 lieferte ein einziges Feld beides: die Beschriftung
/// auf der Schaltfläche und die Kategorie in der Übertragung. Es stand fest auf
/// Englisch — „Bug Report" auch auf einer deutschen Oberfläche.
void main() {
  final deutsch = AppLocalizationsDe();
  final englisch = AppLocalizationsEn();
  final franzoesisch = AppLocalizationsFr();

  group('Der Wert für die Leitung', () {
    test('ist in jeder Sprache derselbe', () {
      for (final kategorie in FeedbackCategory.values) {
        expect(
          kategorie.wireName,
          isNot(contains(' ')),
          reason: 'Ein Leitungswert ist eine Kennung, kein Satz.',
        );
      }

      expect(
        FeedbackCategory.values.map((k) => k.wireName).toList(),
        ['bug_report', 'feature_request', 'general'],
      );
    });

    test('ist von keiner Übersetzung abhängig', () {
      // Es gibt keinen Weg, `wireName` eine Sprache mitzugeben — und genau
      // das ist die Zusicherung. Der Test hält fest, dass sie bestehen
      // bleibt, falls jemand den Wert wieder aus der Anzeige ableiten will.
      for (final kategorie in FeedbackCategory.values) {
        expect(kategorie.wireName, isNot(kategorie.label(deutsch)));
        expect(kategorie.wireName, isNot(kategorie.label(englisch)));
      }
    });
  });

  group('Die Beschriftung', () {
    test('folgt der Sprache der Oberfläche', () {
      const kategorie = FeedbackCategory.bugReport;

      expect(kategorie.label(deutsch), 'Fehler melden');
      expect(kategorie.label(englisch), 'Report a problem');
      expect(kategorie.label(franzoesisch), 'Signaler un problème');
    });

    test('steht auf einer deutschen Oberfläche nirgends auf Englisch', () {
      const englischeFachwoerter = ['Bug', 'Report', 'Feature', 'Request'];

      for (final kategorie in FeedbackCategory.values) {
        final beschriftung = kategorie.label(deutsch);
        for (final wort in englischeFachwoerter) {
          expect(
            beschriftung,
            isNot(contains(wort)),
            reason: 'Fachwörter aus einer Fremdsprache sind für diese '
                'Zielgruppe ausgeschlossen (W3C COGA).',
          );
        }
      }
    });

    test('ist in jeder Sprache für jede Kategorie gesetzt', () {
      final sprachen = <AppLocalizations>[deutsch, englisch, franzoesisch];

      for (final sprache in sprachen) {
        final beschriftungen =
            FeedbackCategory.values.map((k) => k.label(sprache)).toList();

        expect(beschriftungen.every((b) => b.trim().isNotEmpty), isTrue);
        expect(
          beschriftungen.toSet().length,
          FeedbackCategory.values.length,
          reason: 'Zwei Wahlmöglichkeiten mit derselben Beschriftung wären '
              'keine Wahl.',
        );
      }
    });
  });
}
