import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/feedback/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Verweis auf „Was Aurora sendet" steht auf der Fläche, die sendet.
///
/// Diese Prüfung entstand nach einem Rückfall: Der Verweis war schon einmal
/// da und ging beim Portieren auf einen anderen Zweig lautlos verloren. Er
/// hing an keinem Test, also fiel nichts auf — bis er am 11. August 2026 am
/// Gerät wieder fehlte.
///
/// Sie prüft die Zusage, nicht die Verdrahtung: Wer hier gerade etwas wegschickt
/// und darüber freiwillig seine E-Mail-Adresse einträgt, muss von dieser Fläche
/// aus nachlesen können, was das Gerät verlässt — ohne den Umweg über die
/// Einstellungen zu kennen.
void main() {
  testWidgets('der Feedback-Schirm führt zu „Was Aurora sendet"',
      (tester) async {
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

    final l10n = lookupAppLocalizations(const Locale('de'));
    final verweis = find.widgetWithText(
      TextButton,
      l10n.settingsWhatAuroraSends,
    );

    // Der Verweis steht unter den beiden Knöpfen, also am Ende einer langen
    // Fläche. `scrollUntilVisible` sucht ihn, statt ihn nur dann zu finden,
    // wenn er zufällig ins Bild passt.
    await tester.scrollUntilVisible(
      verweis,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      verweis,
      findsOneWidget,
      reason: 'Die Fläche, die sendet, nennt den Weg zum Protokoll nicht.',
    );
  });
}
