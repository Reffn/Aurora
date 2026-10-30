import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/chat/widgets/chat_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Die Tastatur kommt nicht ungefragt wieder.
///
/// Am S24 gesehen (06.10.2026): Tastatur mit „Zurück" geschlossen, dann eine
/// Sprachnachricht aufgenommen oder ein Bild angesehen — beim Schließen sprang
/// die Tastatur wieder auf, und der nächste Tipp landete als Buchstabe im Feld.
/// Der Fokus war geblieben, und jede Überlagerung gibt ihn beim Schließen
/// zurück.
void main() {
  Future<void> zeigeEingabe(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(
          body: ChatInputField(
            onSendMessage: (_) {},
            profileColor: const Color(0xFF3366CC),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool feldHatFokus(WidgetTester tester) {
    final feld = tester.widget<EditableText>(find.byType(EditableText));
    return feld.focusNode.hasPrimaryFocus;
  }

  testWidgets('Tastatur zu heißt: das Feld gibt den Fokus ab', (tester) async {
    addTearDown(tester.view.resetViewInsets);
    await zeigeEingabe(tester);

    await tester.tap(find.byType(TextField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 800);
    await tester.pump();
    expect(feldHatFokus(tester), isTrue);

    // Die Zurück-Taste schließt nur die Tastatur.
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();

    expect(feldHatFokus(tester), isFalse);
  });

  testWidgets('solange die Tastatur offen ist, bleibt der Fokus', (
    tester,
  ) async {
    addTearDown(tester.view.resetViewInsets);
    await zeigeEingabe(tester);

    await tester.tap(find.byType(TextField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 800);
    await tester.pump();
    // Wechsel zwischen Buchstaben und Emojis ändert die Höhe, schließt aber
    // nicht.
    tester.view.viewInsets = const FakeViewPadding(bottom: 1000);
    await tester.pump();

    expect(feldHatFokus(tester), isTrue);
  });
}
