import 'dart:async';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/feedback/feedback_screen.dart';
import 'package:dis_app/modules/release_notes/release_notes_screen.dart';
import 'package:dis_app/services/release_notes_gate.dart';
import 'package:dis_app/widgets/hintergrund_ohne_fokus.dart';
import 'package:dis_app/widgets/work_surface_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vom Neuerungs-Schirm zum Formular: Der Schirm schließt seine Route und
/// legt im selben Zug die nächste darauf. Am A14 (3.0.25, Release) endete
/// dieser Weg im Fehlerschirm „Null check operator used on a null value".
void main() {
  // Der echte Weg, ohne `onOpenFeedback`: `FeedbackScreen` ist Inhalt für
  // einen WorkSurfaceScaffold und bringt kein Material mit. Nackt geschoben,
  // meldet der Debug-Bau „No Material widget found"; im Release fehlt die
  // Prüfung, und ListTile stürzt mit „Null check operator" ab — seit 3.0.21.
  testWidgets('der echte Weg zum Formular trägt einen Rahmen', (tester) async {
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

    unawaited(
      schluessel.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => ReleaseNotesScreen(
            gate: ReleaseNotesGate.inMemory(
              currentVersion: '3.0.25',
              seenVersion: '3.0.24',
            ),
            onDismissed: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('release_notes_feedback')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(FeedbackScreen), findsOneWidget);
    expect(find.byType(WorkSurfaceScaffold), findsOneWidget);
    expect(find.byType(ReleaseNotesScreen), findsNothing);
  });

  for (final mitThema in [false, true]) {
    testWidgets('„Sag uns, was fehlt" öffnet die Folgeseite '
        '(${mitThema ? 'mit' : 'ohne'} HintergrundOhneFokus)', (tester) async {
      final schluessel = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: schluessel,
          theme: mitThema
              ? ThemeData(pageTransitionsTheme: HintergrundOhneFokus.theme)
              : null,
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Text('Hauptschirm')),
        ),
      );
      final navigator = schluessel.currentState!;

      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => ReleaseNotesScreen(
              gate: ReleaseNotesGate.inMemory(
                currentVersion: '3.0.25',
                seenVersion: '3.0.24',
              ),
              onDismissed: () {},
              onOpenFeedback: () => navigator.push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: Text('Formular')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('release_notes_feedback')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Formular'), findsOneWidget);
      expect(find.byType(ReleaseNotesScreen), findsNothing);
    });
  }
}
