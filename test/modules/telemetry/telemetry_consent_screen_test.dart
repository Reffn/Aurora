import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/telemetry/telemetry_consent_screen.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Die Einwilligung liegt hier im Arbeitsspeicher statt in Hive: Echte
/// Datei-Ein-/Ausgabe blockiert in einem Widget-Test — derselbe Grund, aus dem
/// das Übertragungsprotokoll seine Leser als Funktionen entgegennimmt.
void main() {
  late TelemetryConsent consent;

  setUp(() {
    consent = TelemetryConsent.inMemory();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    VoidCallback? onDecided,
    String? appVersion,
    DateTime? today,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        // Der Bildschirm holt seine Texte aus AppLocalizations. Ohne diese
        // drei Zeilen findet er keine und der Test bleibt beim Aufbauen
        // stehen, statt etwas zu pruefen.
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TelemetryConsentScreen(
          consent: consent,
          onDecided: onDecided ?? () {},
          appVersion: appVersion,
          today: today,
        ),
      ),
    );
  }

  group('TelemetryConsentScreen', () {
    testWidgets('zeigt beide Knoepfe in gleicher Groesse', (tester) async {
      await pumpScreen(tester);

      final ja = tester.getSize(find.byKey(const Key('telemetry_yes')));
      final nein = tester.getSize(find.byKey(const Key('telemetry_no')));

      expect(ja, nein);
    });

    testWidgets('Knoepfe erfuellen die Mindesthoehe der Richtlinie',
        (tester) async {
      await pumpScreen(tester);

      // Richtlinie 6: 110 dp, weil WCAG 2.2 ausdruecklich "more for
      // unsteady hands" sagt.
      expect(
        tester.getSize(find.byKey(const Key('telemetry_yes'))).height,
        greaterThanOrEqualTo(110),
      );
    });

    testWidgets('zeigt Beispielereignisse im Klartext', (tester) async {
      await pumpScreen(tester);

      expect(find.textContaining('bereich_geoeffnet_chat'), findsOneWidget);
    });

    testWidgets('nennt die Version, die auch gesendet wird', (tester) async {
      // Hier stand „3.2.0" als Text im Code, waehrend die App 3.0.16 war.
      // Ein Beispiel, das etwas anderes zeigt als der Versand, ist keine
      // Auskunft, sondern eine Behauptung.
      await pumpScreen(tester, appVersion: '9.9.9');

      expect(find.textContaining('9.9.9'), findsOneWidget);
      expect(find.textContaining('3.2.0'), findsNothing);
    });

    testWidgets('nennt den heutigen Tag, keinen festen', (tester) async {
      await pumpScreen(tester, today: DateTime(2031, 3, 7));

      expect(find.textContaining('2031-03-07'), findsOneWidget);
    });

    testWidgets('das Beispiel steht ueber den Knoepfen, ohne Scrollen',
        (tester) async {
      // Der eigentliche Befund: Beide Knoepfe waren ohne Scrollen erreichbar,
      // das Beispiel lag darunter. Man konnte zustimmen, ohne je gesehen zu
      // haben, wozu — bei Gesundheitsdaten ist das keine informierte
      // Einwilligung.
      tester.view
        ..physicalSize = const Size(1080, 2340) // Galaxy S24
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await pumpScreen(tester, appVersion: '9.9.9');

      final beispiel = find.textContaining('bereich_geoeffnet_chat');
      final knopf = find.byKey(const Key('telemetry_yes'));

      final unterkante = tester.getRect(beispiel).bottom;
      final knopfOberkante = tester.getRect(knopf).top;

      expect(unterkante, lessThanOrEqualTo(knopfOberkante));
      expect(unterkante, lessThanOrEqualTo(2340 / 3));
    });

    testWidgets('Ja speichert die Zustimmung', (tester) async {
      var entschieden = false;
      await pumpScreen(tester, onDecided: () => entschieden = true);

      await tester.tap(find.byKey(const Key('telemetry_yes')));
      await tester.pumpAndSettle();

      expect(consent.state, TelemetryConsentState.zugestimmt);
      expect(entschieden, isTrue);
    });

    testWidgets('Weiter ohne gilt als beantwortet', (tester) async {
      var entschieden = false;
      await pumpScreen(tester, onDecided: () => entschieden = true);

      await tester.tap(find.byKey(const Key('telemetry_no')));
      await tester.pumpAndSettle();

      expect(consent.state, TelemetryConsentState.abgelehnt);
      expect(consent.needsAsking, isFalse);
      expect(entschieden, isTrue);
    });
  });
}
