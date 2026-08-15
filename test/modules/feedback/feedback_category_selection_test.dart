import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_localizations_de.dart';
import 'package:dis_app/models/feedback_category.dart';
import 'package:dis_app/modules/feedback/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Die Kategorie-Auswahl im Feedback-Formular.
///
/// Diese Prüfung entstand, weil die Auswahl von `RadioListTile.groupValue`
/// auf einen `RadioGroup`-Vorfahren umgestellt wurde. Der Umbau verlagert die
/// Auswahl-Mechanik aus dem einzelnen Feld in den Vorfahren — geht dabei
/// etwas schief, übersetzt der Code trotzdem sauber, und es fällt erst auf,
/// wenn Tippen nichts mehr auswählt.
///
/// Das Feedback-Formular ist der einzige Weg, auf dem Rückmeldung das Gerät
/// verlässt. Eine stumme Regression hier bliebe lange unbemerkt.
void main() {
  Future<void> zeigeFormular(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('de'),
        // Scaffold, weil der Screen keins mitbringt: In der App sitzt er als
        // Tab-Inhalt in der Arbeitsfläche, die das Material stellt.
        home: Scaffold(body: FeedbackScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Wo die Auswahl steckt, hängt vom Muster ab: entweder im
  /// `RadioGroup`-Vorfahren oder noch im `groupValue` der einzelnen Kachel.
  /// Diese Prüfung gilt dem Verhalten, nicht dem Muster — deshalb beide Wege.
  /// So bleibt sie gültig, egal welche der beiden Fassungen im Code steht.
  FeedbackCategory? gewaehlteKategorie(WidgetTester tester) {
    final gruppe = find.byType(RadioGroup<FeedbackCategory>);
    if (gruppe.evaluate().isNotEmpty) {
      return tester.widget<RadioGroup<FeedbackCategory>>(gruppe).groupValue;
    }
    final kacheln = tester.widgetList<RadioListTile<FeedbackCategory>>(
      find.byType(RadioListTile<FeedbackCategory>),
    );
    // ignore: deprecated_member_use
    return kacheln.first.groupValue;
  }

  testWidgets('alle drei Kategorien stehen zur Wahl', (tester) async {
    await zeigeFormular(tester);

    expect(
      find.byType(RadioListTile<FeedbackCategory>),
      findsNWidgets(FeedbackCategory.values.length),
    );
  });

  testWidgets('zu Beginn ist „Allgemeines Feedback" gewählt', (tester) async {
    await zeigeFormular(tester);

    expect(gewaehlteKategorie(tester), FeedbackCategory.generalFeedback);
  });

  testWidgets('ein Tippen wechselt die Auswahl', (tester) async {
    await zeigeFormular(tester);

    await tester.tap(find.text(FeedbackCategory.bugReport.label(AppLocalizationsDe())));
    await tester.pumpAndSettle();

    expect(gewaehlteKategorie(tester), FeedbackCategory.bugReport);
  });

  testWidgets('die Auswahl bleibt bei einer, nicht bei zweien', (tester) async {
    await zeigeFormular(tester);

    await tester.tap(find.text(FeedbackCategory.bugReport.label(AppLocalizationsDe())));
    await tester.pumpAndSettle();
    await tester.tap(find.text(FeedbackCategory.featureRequest.label(AppLocalizationsDe())));
    await tester.pumpAndSettle();

    expect(gewaehlteKategorie(tester), FeedbackCategory.featureRequest);
  });
}
