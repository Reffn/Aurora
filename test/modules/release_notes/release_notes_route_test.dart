import 'dart:async';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/release_notes/release_notes_screen.dart';
import 'package:dis_app/services/release_notes_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Schirm als Route — der Fall, der am Gerät hängen blieb.
///
/// Startet die App auf der Profilauswahl, entstehen nach der Wahl zwei
/// `MainScreen`: einer aus dem Wechsel von `home`, einer aus dem
/// `pushReplacement` der Auswahl. Beide öffneten den Schirm, und der erste
/// wurde sofort verworfen. Sein Rückruf schloss nichts mehr — „Weiter" vermerkte
/// die Fassung und blieb stehen, bis die App beendet wurde (3.0.22, Emulator).
void main() {
  late ReleaseNotesGate gate;

  setUp(() {
    gate = ReleaseNotesGate.inMemory(
      currentVersion: '3.0.23',
      seenVersion: '3.0.22',
    );
    ReleaseNotesScreen.vergissOffeneRoute();
  });

  Future<NavigatorState> pumpApp(WidgetTester tester) async {
    final schluessel = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: schluessel,
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Text('Hauptschirm')),
      ),
    );
    return schluessel.currentState!;
  }

  Future<void> weiter(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('release_notes_continue')));
    await tester.pumpAndSettle();
  }

  testWidgets('schließt sich selbst, auch wenn der Öffnende fort ist', (
    tester,
  ) async {
    final navigator = await pumpApp(tester);

    // Der Rückruf tut nichts — so wie der eines verworfenen MainScreen,
    // dessen `mounted` längst false ist.
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ReleaseNotesScreen(gate: gate, onDismissed: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ReleaseNotesScreen), findsOneWidget);

    await weiter(tester);

    expect(find.byType(ReleaseNotesScreen), findsNothing);
    expect(find.text('Hauptschirm'), findsOneWidget);
  });

  testWidgets('zweimal angefordert, einmal gezeigt', (tester) async {
    final navigator = await pumpApp(tester);

    unawaited(ReleaseNotesScreen.zeigen(navigator, gate: gate));
    unawaited(ReleaseNotesScreen.zeigen(navigator, gate: gate));
    await tester.pumpAndSettle();

    expect(find.byType(ReleaseNotesScreen), findsOneWidget);

    await weiter(tester);

    expect(find.byType(ReleaseNotesScreen), findsNothing);
    expect(find.text('Hauptschirm'), findsOneWidget);
  });

  testWidgets('verdeckt angefordert: der alte geht, der neue liegt oben', (
    tester,
  ) async {
    final navigator = await pumpApp(tester);

    unawaited(ReleaseNotesScreen.zeigen(navigator, gate: gate));
    await tester.pumpAndSettle();

    // Der zweite MainScreen legt sich darüber — so kam der verdeckte Schirm
    // zustande, den keiner mehr erreicht.
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Zweiter Hauptschirm')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(ReleaseNotesScreen.zeigen(navigator, gate: gate));
    await tester.pumpAndSettle();

    expect(
      find.byType(ReleaseNotesScreen, skipOffstage: false),
      findsOneWidget,
    );

    await weiter(tester);

    expect(
      find.byType(ReleaseNotesScreen, skipOffstage: false),
      findsNothing,
    );
    expect(find.text('Zweiter Hauptschirm'), findsOneWidget);
  });
}
