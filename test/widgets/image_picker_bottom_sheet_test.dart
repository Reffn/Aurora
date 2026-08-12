import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/widgets/image_picker/image_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Das Blatt wählt, das Formular handelt.
///
/// Am 8. August 2026 kam auf dem S24 kein einziges Bild aus Kamera oder
/// Galerie an: Das Blatt schloss sich per `Navigator.pop` und rief den Handler
/// danach mit seinem **eigenen**, damit toten Context auf. Der Handler prüfte
/// `context.mounted`, fand ihn tot und stieg aus — ohne Fehler, ohne Meldung,
/// ohne Bild.
///
/// Dieser Test hält den Weg fest, der das verhindert: Nach der Wahl ist das
/// Blatt zu, und der Context des Aufrufers lebt noch. Die Systemauswahl selbst
/// braucht der Test dafür nicht.
void main() {
  /// Merkt sich, was `choose` geliefert hat und ob der aufrufende Context die
  /// Auswahl überlebt hat.
  late ImagePickerChoice? gewaehlt;
  late bool contextLebtDanach;

  Widget flaeche({bool showDoodleOption = false}) {
    gewaehlt = null;
    contextLebtDanach = false;
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (formularContext) => ElevatedButton(
            onPressed: () async {
              gewaehlt = await ImagePickerBottomSheet.choose(
                formularContext,
                showDoodleOption: showDoodleOption,
              );
              contextLebtDanach = formularContext.mounted;
            },
            child: const Text('Bild wählen'),
          ),
        ),
      ),
    );
  }

  Future<void> blattOeffnen(WidgetTester tester) async {
    await tester.tap(find.text('Bild wählen'));
    await tester.pumpAndSettle();
  }

  testWidgets('Galerie: Wahl kommt zurück, der Aufrufer lebt noch', (
    tester,
  ) async {
    await tester.pumpWidget(flaeche());
    await blattOeffnen(tester);

    await tester.tap(find.byIcon(Icons.photo_library));
    await tester.pumpAndSettle();

    expect(gewaehlt, ImagePickerChoice.gallery);
    expect(
      contextLebtDanach,
      isTrue,
      reason: 'Mit einem toten Context verschwindet das Bild lautlos',
    );
    expect(
      find.byIcon(Icons.photo_library),
      findsNothing,
      reason: 'Das Blatt muss zu sein, bevor die Systemauswahl aufgeht',
    );
  });

  testWidgets('Kamera: dieselbe Zusage', (tester) async {
    await tester.pumpWidget(flaeche());
    await blattOeffnen(tester);

    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    expect(gewaehlt, ImagePickerChoice.camera);
    expect(contextLebtDanach, isTrue);
  });

  testWidgets('Tier-Avatar und Malen tragen ihre eigene Wahl', (tester) async {
    await tester.pumpWidget(flaeche(showDoodleOption: true));
    await blattOeffnen(tester);
    await tester.tap(find.byIcon(Icons.pets));
    await tester.pumpAndSettle();
    expect(gewaehlt, ImagePickerChoice.animal);

    await blattOeffnen(tester);
    await tester.tap(find.byIcon(Icons.brush));
    await tester.pumpAndSettle();
    expect(gewaehlt, ImagePickerChoice.doodle);
  });

  testWidgets('weggewischt heißt null, nicht irgendeine Wahl', (tester) async {
    await tester.pumpWidget(flaeche());
    await blattOeffnen(tester);

    // Tippen neben das Blatt schließt es, ohne zu wählen.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(gewaehlt, isNull);
    expect(contextLebtDanach, isTrue);
  });

  testWidgets('ohne Malen-Option steht die Zeile nicht da', (tester) async {
    await tester.pumpWidget(flaeche());
    await blattOeffnen(tester);

    expect(find.byIcon(Icons.brush), findsNothing);
  });
}
