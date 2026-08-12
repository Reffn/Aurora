// „Nicht mehr anzeigen" lag auf „Willkommen bei".
//
// Der Ausgang war mit `Positioned` über den Inhalt gelegt. Auf der ersten
// Onboarding-Seite steht eine Überschrift weit oben, also überschnitten sich
// beide; ab Seite zwei fiel es nicht auf. Der Fehler lag im Rahmen, nicht auf
// der Seite — deshalb prüft dieser Test den Rahmen.

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/onboarding/widgets/dismissable_onboarding_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpWrapper(
    WidgetTester tester, {
    bool showDismissButton = true,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DismissableOnboardingWrapper(
            onDismiss: () {},
            showDismissButton: showDismissButton,
            child: const Column(
              children: [
                Text('Willkommen bei'),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  group('DismissableOnboardingWrapper', () {
    testWidgets('der Ausgang überdeckt die Überschrift nicht', (tester) async {
      await pumpWrapper(tester);

      final ausgang = tester.getRect(find.text('Nicht mehr anzeigen'));
      final ueberschrift = tester.getRect(find.text('Willkommen bei'));

      expect(ausgang.overlaps(ueberschrift), isFalse);
      // Und zwar, weil er darüber steht — nicht, weil er zufällig
      // danebenpasst.
      expect(ausgang.bottom, lessThanOrEqualTo(ueberschrift.top));
    });

    testWidgets('auf einem schmalen Schirm ebenfalls nicht', (tester) async {
      // Der Befund entstand am Gerät, nicht auf einer Testfläche von
      // 800 mal 600.
      tester.view
        ..physicalSize = const Size(1080, 2340) // Galaxy S24
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await pumpWrapper(tester);

      expect(
        tester
            .getRect(find.text('Nicht mehr anzeigen'))
            .overlaps(tester.getRect(find.text('Willkommen bei'))),
        isFalse,
      );
    });

    testWidgets('ohne Ausgang bleibt der Inhalt allein stehen', (tester) async {
      await pumpWrapper(tester, showDismissButton: false);

      expect(find.text('Nicht mehr anzeigen'), findsNothing);
      expect(find.text('Willkommen bei'), findsOneWidget);
    });
  });
}
