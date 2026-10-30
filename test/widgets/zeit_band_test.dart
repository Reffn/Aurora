import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/profile/profile_selection_screen.dart';
import 'package:dis_app/utils/time_phase.dart';
import 'package:dis_app/widgets/time_map.dart';
import 'package:dis_app/widgets/zeit_band.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../modules/profile/profile_selection_test_setup.dart';
import '../support/text_scale_harness.dart';

/// Datum und Tageszeit stehen seit 3.0.25 als breites Band direkt unter der
/// Kopfzeile mit „Aurora“ — nicht mehr in der Zeitkarte. Am Gerät wirkten
/// sie dort deplatziert: eine Uhr über Kartenkacheln.
void main() {
  Widget app(Widget kind, {Locale locale = const Locale('de')}) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Column(children: [kind])),
  );

  group('ZeitBand', () {
    testWidgets('zeigt Wochentag und Datum ausgeschrieben, Uhrzeit und Phase', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(ZeitBand(jetzt: () => DateTime(2026, 10, 29, 21, 48))),
      );

      expect(find.text('Donnerstag, 29. Oktober 2026'), findsOneWidget);
      expect(find.text('21:48 · abends'), findsOneWidget);
    });

    testWidgets('spricht die Sprache der App', (tester) async {
      await tester.pumpWidget(
        app(
          ZeitBand(jetzt: () => DateTime(2026, 10, 29, 7, 5)),
          locale: const Locale('en'),
        ),
      );

      expect(find.text('Thursday, October 29, 2026'), findsOneWidget);
      expect(find.text('07:05 · morning'), findsOneWidget);
    });

    testWidgets('liegt über die volle Breite', (tester) async {
      await tester.pumpWidget(
        app(ZeitBand(jetzt: () => DateTime(2026, 10, 29, 21, 48))),
      );

      final breite = tester.getSize(find.byType(ZeitBand)).width;
      expect(
        breite,
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      );
    });

    // Die Profilauswahl rechnet ihr Kartenbudget mit dieser Höhe. Sie muss
    // die gezeichnete treffen — bei einer Zeile, bei zwei, bei großer
    // Schrift. Für die Uhrzeit rechnet sie mit der breitesten Tagesphase,
    // darf also höher sein, nie niedriger.
    for (final (breite, skala, wann) in [
      (800.0, 1.0, DateTime(2026, 10, 29, 21, 48)),
      (450.0, 1.0, DateTime(2026, 9, 30, 21, 48)),
      (384.0, 1.0, DateTime(2026, 9, 30, 15, 5)),
      (384.0, 1.5, DateTime(2026, 5, 6, 7, 5)),
      (384.0, 2.0, DateTime(2026, 9, 30, 12, 0)),
    ]) {
      testWidgets('die gerechnete Höhe trifft die gezeichnete '
          '(${breite.round()} dp, $skala, $wann)', (tester) async {
        late double gerechnet;
        await pumpScaled(
          tester,
          Builder(
            builder: (context) {
              gerechnet = ZeitBand.hoeheFuer(
                context,
                breite: breite,
                jetzt: () => wann,
              );
              return Column(children: [ZeitBand(jetzt: () => wann)]);
            },
          ),
          scale: skala,
          deviceSize: Size(breite * 2.5, 2000),
          pixelRatio: 2.5,
          settle: false,
        );

        final gezeichnet = tester.getSize(find.byType(ZeitBand)).height;
        expect(gerechnet, greaterThanOrEqualTo(gezeichnet - 0.5));
        // Höchstens eine Zeile mehr, und das nur, wenn eine breitere Phase
        // umbrechen würde.
        expect(gerechnet, lessThanOrEqualTo(gezeichnet + 16 * skala * 1.5 + 2));
      });
    }

    testWidgets('liest sich als eine Angabe', (tester) async {
      final semantik = tester.ensureSemantics();
      await tester.pumpWidget(
        app(ZeitBand(jetzt: () => DateTime(2026, 10, 29, 21, 48))),
      );

      expect(
        find.bySemanticsLabel(
          RegExp('Donnerstag, 29. Oktober 2026.*21:48 · abends', dotAll: true),
        ),
        findsOneWidget,
      );
      semantik.dispose();
    });

    testWidgets('bei 200 % Schrift wirft es keinen Überlauf', (tester) async {
      await pumpScaled(
        tester,
        Column(
          children: [ZeitBand(jetzt: () => DateTime(2026, 9, 30, 21, 48))],
        ),
        scale: 2,
        deviceSize: geraetA14.size,
        pixelRatio: geraetA14.ratio,
        settle: false,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('21:48 · abends'), findsOneWidget);
    });
  });

  group('Zeitkarte', () {
    testWidgets('trägt Datum und Uhrzeit nicht mehr selbst', (tester) async {
      await profilAufbau(mitStandortrecht: false);
      final jetzt = DateTime.now();
      await pumpScaled(
        tester,
        TimeMap(
          track: const [],
          switchEvents: const [],
          pastEvents: const [],
          upcomingEvents: const [],
          profileNameOf: (_) => null,
          height: 200,
        ),
        settle: false,
      );
      tester.takeException();

      final l10n = await AppLocalizations.delegate.load(const Locale('de'));
      final karte = find.byType(TimeMap);
      for (final text in [
        DateFormat.yMMMEd('de').format(jetzt),
        DateFormat.yMMMMEEEEd('de').format(jetzt),
      ]) {
        expect(
          find.descendant(of: karte, matching: find.text(text)),
          findsNothing,
          reason: text,
        );
      }
      expect(
        find.descendant(
          of: karte,
          matching: find.textContaining(timePhaseOf(l10n, jetzt.hour)),
        ),
        findsNothing,
      );
    });
  });

  group('Profilauswahl', () {
    // Ein langes Datum bricht auf Telefonbreite zweizeilig um. Bis zur
    // Abnahme von 3.0.25 rechnete das Kartenbudget mit einer festen Zeile
    // (42 dp); die zweite Zeile ging der Wahl ab, und die Namen rutschten
    // unter die Kante der Wahlfläche.
    //
    // Geprüft über mehrere Schirmhöhen: Wo die Karte reichlich Platz hat,
    // schluckt sie den Fehler; sichtbar wird er erst, wenn das Budget knapp
    // ist und die Karte genau den Rest bekommt.
    for (final breite in [450.0, 384.0]) {
      for (final hoehe in [720.0, 760.0, 800.0, 840.0, 880.0, 1003.0]) {
        final geraet = (size: Size(breite * 2.5, hoehe * 2.5), ratio: 2.5);
        testWidgets('ein langes Datum drückt die Namen nicht unter die Kante '
            '(${breite.round()} × ${hoehe.round()} dp)', (tester) async {
          await profilAufbau(mitTageshinweis: true);
          await pumpScaled(
            tester,
            ProfileSelectionScreen(jetzt: () => DateTime(2026, 9, 30, 21, 48)),
            deviceSize: geraet.size,
            pixelRatio: geraet.ratio,
            settle: false,
          );
          tester.takeException();

          expect(
            tester.getSize(find.byType(ZeitBand)).height,
            greaterThan(45),
            reason:
                'Das Datum soll hier zweizeilig stehen, sonst prüft der '
                'Test nichts.',
          );
          for (final text in ['Lina', 'Neues Profil']) {
            final finder = find.text(text);
            final flaeche = find
                .ancestor(of: finder, matching: find.byType(Scrollable))
                .first;
            expect(
              tester.getRect(finder).bottom,
              lessThanOrEqualTo(tester.getRect(flaeche).bottom + 0.5),
              reason: '„$text“ liegt unter der Kante der Wahlfläche.',
            );
          }
        });
      }
    }

    testWidgets('das Band steht unter „Aurora“ und über der Karte', (
      tester,
    ) async {
      await profilAufbau(mitStandortrecht: false);
      await pumpScaled(
        tester,
        const ProfileSelectionScreen(),
        deviceSize: geraetA14.size,
        pixelRatio: geraetA14.ratio,
        settle: false,
      );
      tester.takeException();

      final band = find.byType(ZeitBand);
      expect(band, findsOneWidget);
      final wortmarke = find.text('Aurora');
      expect(
        tester.getRect(band).top,
        greaterThanOrEqualTo(tester.getRect(wortmarke).bottom),
      );
      expect(
        tester.getRect(band).bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(TimeMap)).top),
      );
    });
  });
}
