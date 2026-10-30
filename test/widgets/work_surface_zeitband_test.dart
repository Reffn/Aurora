import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/widgets/work_surface_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Das Band unter der Titelleiste folgt dem Bestand, solange die Fläche offen
/// ist.
///
/// Am A14 (3.0.26) stand nach dem Löschen eines Medikaments weiter
/// „✓ Testmittel · 08:00 ⏰ Testmittel" im Kopf — das Band wurde beim Öffnen
/// der Fläche einmal berechnet und dann nie wieder.
void main() {
  late ValueNotifier<int> quelle;
  late bool bandDa;

  setUp(() {
    quelle = ValueNotifier<int>(0);
    bandDa = true;
  });

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WorkSurfaceScaffold(
          title: 'Medikamente',
          subHeaderSource: quelle,
          subHeaderBuilder: () => bandDa ? const Text('Zeitband') : null,
          child: const Text('Inhalt'),
        ),
      ),
    );
  }

  AppBar appBar(WidgetTester tester) =>
      tester.widget<AppBar>(find.byType(AppBar));

  testWidgets('verschwindet, sobald die Quelle nichts mehr trägt', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Zeitband'), findsOneWidget);

    bandDa = false;
    quelle.value++;
    await tester.pump();

    expect(find.text('Zeitband'), findsNothing);
    // Kein leerer Streifen: Ohne Band hat die Titelleiste keinen Unterbau.
    expect(appBar(tester).bottom, isNull);
    expect(find.text('Inhalt'), findsOneWidget);
  });

  testWidgets('erscheint, sobald die Quelle etwas trägt', (tester) async {
    bandDa = false;
    await pump(tester);
    expect(appBar(tester).bottom, isNull);

    bandDa = true;
    quelle.value++;
    await tester.pump();

    expect(find.text('Zeitband'), findsOneWidget);
    expect(appBar(tester).bottom, isNotNull);
  });
}
