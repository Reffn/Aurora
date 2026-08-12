import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Der Ladebildschirm: was er sagt, und wie lange er den Start aufhält.
///
/// Bis zum 11. August 2026 stand seine Überschrift hart auf Deutsch — sie kam
/// aus einer Tabelle mit vierundvierzig Übersetzungen, und der Code griff
/// darin fest auf `['de']`. Wer Aurora auf Spanisch stellte, las „Aurora
/// lädt" über spanischen Sätzen. Der übersetzte Text lag längst in allen fünf
/// Sprachdateien und wurde nie benutzt.
///
/// Dieselbe Tabelle lieferte darunter acht Sprachen unter der Überschrift
/// „Sprachen, die Aurora spricht" — Chinesisch, Arabisch, Japanisch,
/// Russisch. Aurora spricht fünf.
///
/// Und der Start wartete feste drei Sekunden auf eine Entscheidung, die
/// niemand traf: das Zeitfenster für den Notfall-Reset. Jetzt trägt das
/// Tippen die Frist.
void main() {
  Future<({List<bool> freigaben})> zeigeSplash(
    WidgetTester tester, {
    String sprache = 'de',
  }) async {
    final freigaben = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(sprache),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(
          onHold: () {},
          onRelease: ({required bool wipe}) => freigaben.add(wipe),
        ),
      ),
    );
    await tester.pump();
    return (freigaben: freigaben,);
  }

  Future<void> tippeAufsLogo(WidgetTester tester) async {
    await tester.tap(find.byType(Image));
    await tester.pump();
  }

  testWidgets('die Überschrift folgt der Sprache', (tester) async {
    for (final sprache in ['de', 'en', 'es', 'fr', 'it']) {
      await zeigeSplash(tester, sprache: sprache);

      expect(
        find.text(lookupAppLocalizations(Locale(sprache)).splashLoading),
        findsOneWidget,
        reason: 'Der Ladebildschirm steht auf $sprache und sagt es nicht.',
      );
    }
  });

  testWidgets('auf Spanisch steht dort kein deutsches Wort', (tester) async {
    await zeigeSplash(tester, sprache: 'es');

    expect(
      find.text(lookupAppLocalizations(const Locale('de')).splashLoading),
      findsNothing,
      reason: 'Die deutsche Überschrift steht in einer spanischen App.',
    );
  });

  testWidgets('keine Liste fremder Schriftsysteme', (tester) async {
    await zeigeSplash(tester);

    // Stichproben aus der gelöschten Tabelle. Sie standen unter „Sprachen,
    // die Aurora spricht", obwohl Aurora sie nicht spricht.
    for (final fremd in [
      '正在加载 Aurora',
      'تحميل أورورا',
      'オーロラを読み込んでいます',
      'Загрузка Авроры',
    ]) {
      expect(
        find.text(fremd),
        findsNothing,
        reason: 'Die Sprachliste ist zurück: $fremd',
      );
    }
  });

  testWidgets('ohne Tippen hält er den Start nicht auf', (tester) async {
    var gehalten = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(
          onHold: () => gehalten = true,
          onRelease: ({required bool wipe}) {},
        ),
      ),
    );
    await tester.pump();

    // Deutlich länger als das alte feste Fenster von drei Sekunden.
    await tester.pump(const Duration(seconds: 10));

    expect(
      gehalten,
      isFalse,
      reason: 'Der Start wartet, obwohl niemand getippt hat.',
    );
  });

  testWidgets('der erste Tap hält den Start an', (tester) async {
    var gehalten = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(
          onHold: () => gehalten = true,
          onRelease: ({required bool wipe}) {},
        ),
      ),
    );
    await tester.pump();

    await tippeAufsLogo(tester);
    expect(gehalten, isTrue);

    // Und er gibt wieder frei, wenn niemand weitertippt.
    await tester.pump(SplashScreen.tippfenster);
  });

  testWidgets('wer aufhört zu tippen, gibt den Start frei', (tester) async {
    final ergebnis = await zeigeSplash(tester);

    await tippeAufsLogo(tester);
    expect(ergebnis.freigaben, isEmpty, reason: 'Zu früh freigegeben.');

    await tester.pump(SplashScreen.tippfenster);

    expect(
      ergebnis.freigaben,
      [false],
      reason: 'Nach dem Tippfenster muss der Start weiterlaufen — ohne Reset.',
    );
  });

  testWidgets('jeder Tap verlängert die Frist', (tester) async {
    final ergebnis = await zeigeSplash(tester);

    // Vier Taps, jeder kurz vor Ablauf der Frist. Nach der alten Bauart wäre
    // das Fenster längst zu gewesen: Es hing am Öffnen des Bildschirms, nicht
    // am Tippen.
    for (var i = 0; i < 4; i++) {
      await tippeAufsLogo(tester);
      await tester.pump(SplashScreen.tippfenster - const Duration(seconds: 1));
      expect(ergebnis.freigaben, isEmpty, reason: 'Frist lief bei Tap $i ab.');
    }

    await tester.pump(SplashScreen.tippfenster);
    expect(ergebnis.freigaben, [false]);
  });

  testWidgets('der Zähler erscheint erst ab dem zweiten Tap', (tester) async {
    await zeigeSplash(tester);

    expect(
      find.byKey(SplashScreen.zaehlerSchluessel),
      findsNothing,
      reason: 'Ein versehentlicher Tap verrät den Löschweg.',
    );

    await tippeAufsLogo(tester);
    expect(find.byKey(SplashScreen.zaehlerSchluessel), findsNothing);

    await tippeAufsLogo(tester);
    expect(
      find.byKey(SplashScreen.zaehlerSchluessel),
      findsOneWidget,
      reason: 'Wer den Weg absichtlich geht, tippt sonst ins Leere.',
    );

    await tester.pump(SplashScreen.tippfenster);
  });
}
