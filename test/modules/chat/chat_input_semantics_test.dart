import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/chat/widgets/chat_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Die Namen der drei Chat-Eingaben.
///
/// Codex hat am 10. August im Android-Semantikbaum gemessen: Plusknopf,
/// Textfeld und Sendeknopf hatten keinen Namen. Bild, Sprechen und Malen
/// waren sinnvoll benannt — ausgerechnet die drei Wege, die jeder benutzt,
/// waren es nicht.
///
/// Der Platzhalter zählt dabei nicht als Name: Er verschwindet, sobald jemand
/// tippt. Deshalb prüft der letzte Fall ausdrücklich den Zustand *mit* Text.
void main() {
  Future<void> zeigeEingabe(
    WidgetTester tester, {
    bool canSendText = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(
          body: ChatInputField(
            onSendMessage: (_) {},
            profileColor: const Color(0xFF3366CC),
            canSendText: canSendText,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Der Plusknopf sagt, was er tut', (tester) async {
    await zeigeEingabe(tester);

    expect(find.bySemanticsLabel('Weitere Medien hinzufügen'), findsOneWidget);
  });

  testWidgets('Das Eingabefeld trägt einen Namen', (tester) async {
    await zeigeEingabe(tester);

    expect(find.bySemanticsLabel('Nachricht'), findsWidgets);
  });

  testWidgets('Der Feldname bleibt, wenn der Platzhalter verschwindet',
      (tester) async {
    await zeigeEingabe(tester);

    await tester.enterText(find.byType(TextField), 'Hallo');
    await tester.pumpAndSettle();

    // Der Platzhalter trägt den Namen nicht mehr, sobald Text darin steht —
    // das Semantiklabel schon. Genau darum hängt es am Feld und nicht am
    // `hintText`.
    expect(find.bySemanticsLabel('Nachricht'), findsWidgets);
  });

  testWidgets('Der Sendeknopf sagt Name und Zustand', (tester) async {
    final handle = tester.ensureSemantics();
    await zeigeEingabe(tester);

    // `containsSemantics` statt `matchesSemantics`: Geprüft wird, was der
    // Befund verlangt — Name, Rolle, Zustand. Eine erschöpfende Zusicherung
    // über jedes Flag würde bei jeder unbeteiligten Änderung brechen.
    expect(
      tester.getSemantics(find.bySemanticsLabel('Nachricht senden')),
      containsSemantics(
        label: 'Nachricht senden',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
      reason: 'Ohne Text ist der Knopf sichtbar, aber wirkungslos.',
    );

    await tester.enterText(find.byType(TextField), 'Hallo');
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Nachricht senden')),
      containsSemantics(
        label: 'Nachricht senden',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );

    handle.dispose();
  });
}
