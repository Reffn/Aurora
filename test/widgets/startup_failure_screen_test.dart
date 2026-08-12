import 'package:dis_app/core/delete_all_data.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/widgets/startup_failure_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ein gescheiterter Start braucht Worte und Wege, kein stehendes Logo.
void main() {
  Widget umgeben(Widget kind) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: kind,
      );

  testWidgets('nennt den Grund und bietet genau zwei Wege', (tester) async {
    await tester.pumpWidget(
      umgeben(StartupFailureScreen(onRetry: () async {})),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('de'));
    expect(find.text(l10n.startupFailedTitle), findsOneWidget);
    expect(find.text(l10n.startupRetry), findsOneWidget);
    expect(find.text(l10n.startupDeleteAll), findsOneWidget);
  });

  testWidgets('Wiederholen ruft den Neustart', (tester) async {
    var versuche = 0;
    await tester.pumpWidget(
      umgeben(StartupFailureScreen(onRetry: () async => versuche++)),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('de'));
    await tester.tap(find.text(l10n.startupRetry));
    await tester.pumpAndSettle();

    expect(versuche, 1);
  });

  testWidgets('während eines Versuchs bleibt der Knopf still', (tester) async {
    // Zweimal tippen darf keine zwei Startläufe erzeugen — auf einer Fläche,
    // die jemand unter Druck bedient, ist der Doppeltipp der Normalfall.
    var versuche = 0;
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));
    await tester.pumpWidget(
      umgeben(
        StartupFailureScreen(
          onRetry: () async {
            versuche++;
            await Future<void>.delayed(const Duration(milliseconds: 50));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.startupRetry));
    await tester.pump();
    await tester.tap(find.text(l10n.startupRetry), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(versuche, 1);
  });

  testWidgets('unvollstaendiges Loeschen startet nicht still neu',
      (tester) async {
    // Wer „Alle Daten löschen" antippt, trifft eine Entscheidung über
    // Gesundheitsdaten. Bleiben Schritte übrig und die Fläche startet trotzdem
    // neu, sieht der Mensch einen geglückten Start über verbliebenen Daten —
    // eine Lüge an der Stelle, an der sie am meisten wehtut.
    var neustarts = 0;
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));
    await tester.pumpWidget(
      umgeben(
        StartupFailureScreen(
          onRetry: () async => neustarts++,
          deleteAllData: () async => const DeleteAllResult(['reminders']),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.startupDeleteAll));
    await tester.pumpAndSettle();

    expect(neustarts, 0, reason: 'ein Teilerfolg ist kein Erfolg');
    expect(find.text(l10n.startupDeleteIncomplete), findsOneWidget);
  });

  testWidgets('vollstaendiges Loeschen startet neu', (tester) async {
    var neustarts = 0;
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));
    await tester.pumpWidget(
      umgeben(
        StartupFailureScreen(
          onRetry: () async => neustarts++,
          deleteAllData: () async => const DeleteAllResult([]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.startupDeleteAll));
    await tester.pumpAndSettle();

    expect(neustarts, 1);
    expect(find.text(l10n.startupDeleteIncomplete), findsNothing);
  });
}
