import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/data/grounding_images.dart';
import 'package:dis_app/modules/grounding/exercise_player_screen.dart';
import 'package:dis_app/modules/grounding/widgets/breath_pacer.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_done_sheet.dart';
import 'package:dis_app/modules/grounding/widgets/step_view.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:dis_app/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../../helpers/temp_hive.dart';

/// Die Atemübung als durchgehender Takt.
///
/// Bis 3.0.24 war sie eine Schrittfolge: Der Ring füllte sich und blieb
/// stehen, weiter ging es nur per Tipp — mitten im Atemzug. Geführt wurde
/// genau ein Atemzug. Jetzt läuft ein Kreis fünf Runden lang ohne Tippen:
/// 4 s einatmen (er wächst), 2 s halten (er steht), 6 s ausatmen (er
/// schrumpft). Die Zeit kommt aus der Testzone (`tester.pump(Duration)`),
/// es wird nie wirklich gewartet.
void main() {
  late AppLocalizations l10n;
  late Box<dynamic> settings;
  late Box<PendingTelemetryEvent> queue;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('de'));
  });

  setUp(() async {
    await openTempBox<dynamic>('hive_init_atem');
    settings = await Hive.openBox<dynamic>(
      'settings_atem',
      bytes: Uint8List(0),
    );
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(PendingTelemetryEventAdapter());
    }
    queue = await Hive.openBox<PendingTelemetryEvent>(
      'queue_atem',
      bytes: Uint8List(0),
    );
    final consent = TelemetryConsent.fromBox(settings);
    await consent.grant();
    await getIt.reset();
    getIt.registerSingleton<TelemetryRecorder>(
      TelemetryRecorder(
        consent: consent,
        queue: queue,
        appVersion: '3.0.25',
        now: () => DateTime(2026, 10, 30, 9),
        random: Random(1),
      ),
    );
  });

  tearDown(() async {
    await getIt.reset();
    await settings.close();
    await queue.close();
  });

  List<String> gemeldet() => [for (final e in queue.values) e.eventName];

  /// Die Übung als Route über einer Startfläche, damit Zurück sie wirklich
  /// verlässt.
  Future<void> oeffnen(
    WidgetTester tester, {
    bool ohneBewegung = false,
  }) async {
    // Den Schirm abbauen, solange Recorder und Box noch stehen. Sonst meldet
    // ein fehlgeschlagener Test sein `dispose` erst später — in die Box des
    // nächsten, der dann ebenfalls rot wird.
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, kind) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: ohneBewegung),
          child: kind!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ExercisePlayerScreen(
                    exercise: GroundingExercises.breath,
                  ),
                ),
              ),
              child: const Text('öffnen'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('öffnen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Lässt die Zeit in ganzen Sekunden laufen, damit jeder Phasenwechsel
  /// seinen eigenen Frame bekommt.
  Future<void> sekunden(WidgetTester tester, int n) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  }

  Size kreis(WidgetTester tester) =>
      tester.getSize(find.byKey(const ValueKey('atem-kreis')));

  int runde(WidgetTester tester) => tester
      .widget<ProgressDots>(
        find.descendant(
          of: find.byType(BreathPacer),
          matching: find.byType(ProgressDots),
        ),
      )
      .active;

  /// Verlässt die Übung über den Pfeil und wartet, bis die Route ganz weg
  /// ist — der Takt läuft während des Hinausgleitens noch weiter.
  Future<void> zurueck(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('grounding-back')));
    await tester.pumpAndSettle();
    expect(find.text('öffnen'), findsOneWidget);
  }

  group('Takt', () {
    testWidgets(
      'läuft ohne Tippen: einatmen, halten, ausatmen, nächste Runde',
      (tester) async {
        await oeffnen(tester);

        expect(find.byType(BreathPacer), findsOneWidget);
        expect(find.text(l10n.groundingBreathStep1), findsOneWidget);
        expect(runde(tester), 1);

        await sekunden(tester, 4);
        expect(find.text(l10n.groundingBreathStep2), findsOneWidget);

        await sekunden(tester, 2);
        expect(find.text(l10n.groundingBreathStep3), findsOneWidget);

        await sekunden(tester, 6);
        expect(find.text(l10n.groundingBreathStep1), findsOneWidget);
        expect(runde(tester), 2);
      },
    );

    testWidgets('fünf Runden zeigen fünf Punkte, danach der Abschluss', (
      tester,
    ) async {
      await oeffnen(tester);
      final punkte = tester.widget<ProgressDots>(
        find.descendant(
          of: find.byType(BreathPacer),
          matching: find.byType(ProgressDots),
        ),
      );
      expect(punkte.total, 5);

      await sekunden(tester, 59);
      expect(find.byType(ExerciseDoneSheet), findsNothing);
      expect(runde(tester), 5);

      await sekunden(tester, 1);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ExerciseDoneSheet), findsOneWidget);
    });

    testWidgets('der Kreis wächst beim Einatmen, steht beim Halten, '
        'schrumpft beim Ausatmen', (tester) async {
      await oeffnen(tester);
      final start = kreis(tester).width;

      await sekunden(tester, 4);
      final eingeatmet = kreis(tester).width;
      expect(eingeatmet, greaterThan(start));

      // Mitten im Halten. (Die Uhr läuft seit dem ersten Frame der Route,
      // also 400 ms vor diesen Sekunden.)
      await sekunden(tester, 1);
      expect(kreis(tester).width, closeTo(eingeatmet, 0.5));

      await sekunden(tester, 6);
      expect(kreis(tester).width, lessThan(eingeatmet));
    });

    testWidgets('ohne Bewegung steht der Kreis, der Takt läuft weiter', (
      tester,
    ) async {
      await oeffnen(tester, ohneBewegung: true);
      final start = kreis(tester).width;

      await sekunden(tester, 4);
      expect(kreis(tester).width, start);
      expect(find.text(l10n.groundingBreathStep2), findsOneWidget);

      await sekunden(tester, 2);
      expect(kreis(tester).width, start);
      expect(find.text(l10n.groundingBreathStep3), findsOneWidget);
    });

    testWidgets('„Fertig“ steht von Anfang an da und führt zum Abschluss', (
      tester,
    ) async {
      await oeffnen(tester);

      final fertig = find.byKey(const ValueKey('grounding-breath-finish'));
      expect(fertig, findsOneWidget);
      expect(
        find.descendant(of: fertig, matching: find.text(l10n.actionDone)),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('grounding-back')), findsOneWidget);

      await tester.tap(fertig);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ExerciseDoneSheet), findsOneWidget);
    });

    testWidgets('der Kreis zeigt das Bild über die eine Bildauflösung', (
      tester,
    ) async {
      await oeffnen(tester);

      final bild = find.descendant(
        of: find.byType(BreathPacer),
        matching: find.byType(GroundingBildView),
      );
      expect(bild, findsOneWidget);
      final gezeigt = tester.widget<GroundingBildView>(bild).bild;
      final erwartet = GroundingImages.bildFuer('breath_in');
      expect(gezeigt, isA<GroundingBildSymbol>());
      expect(
        (gezeigt! as GroundingBildSymbol).icon,
        (erwartet! as GroundingBildSymbol).icon,
      );
    });
  });

  // Der Takt läuft nur, solange man ihn sieht. Im Hintergrund — App
  // gewechselt, Bildschirm aus — oder unter einer Route, die ihn verdeckt
  // (die Profilauswahl nach Abwesenheit), steht er und läuft beim
  // Zurückkommen dort weiter, wo er stand. Vorher lief ein Timer weiter:
  // Nach 60 s stand man auf dem Abschluss, und `uebung_beendet_breath` war
  // gemeldet, ohne dass jemand geatmet hatte.
  group('Lebenszyklus', () {
    testWidgets('im Hintergrund steht der Takt und läuft danach weiter', (
      tester,
    ) async {
      await oeffnen(tester);
      await sekunden(tester, 3);
      final vorher = kreis(tester).width;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await sekunden(tester, 70);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(find.byType(ExerciseDoneSheet), findsNothing);
      expect(gemeldet(), isEmpty);
      expect(runde(tester), 1);
      expect(find.text(l10n.groundingBreathStep1), findsOneWidget);
      expect(kreis(tester).width, closeTo(vorher, 1));

      // Die eine Sekunde, die vom Einatmen noch fehlte.
      await sekunden(tester, 1);
      expect(find.text(l10n.groundingBreathStep2), findsOneWidget);
    });

    testWidgets('unter einer verdeckenden Route steht der Takt', (
      tester,
    ) async {
      await oeffnen(tester);
      await sekunden(tester, 3);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Auswahl')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await sekunden(tester, 70);
      expect(gemeldet(), isEmpty);

      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ExerciseDoneSheet), findsNothing);
      expect(gemeldet(), isEmpty);
      expect(runde(tester), 1);
    });
  });

  // Definition: `uebung_beendet_breath`, wenn beim Verlassen oder Beenden
  // mindestens eine volle Runde durchlaufen ist; `uebung_abgebrochen_breath`,
  // wenn vorher verlassen wird. Je Öffnen höchstens ein Ereignis.
  group('Telemetrie', () {
    testWidgets('vor der ersten vollen Runde verlassen: abgebrochen', (
      tester,
    ) async {
      await oeffnen(tester);
      await sekunden(tester, 11);
      await zurueck(tester);

      expect(gemeldet(), ['uebung_abgebrochen_breath']);
    });

    testWidgets('nach einer vollen Runde verlassen: beendet', (tester) async {
      await oeffnen(tester);
      await sekunden(tester, 12);
      await zurueck(tester);

      expect(gemeldet(), [
        TelemetryEventName.fromWireName(
          'uebung_beendet_breath',
        )!.wireName,
      ]);
    });

    testWidgets('durchgelaufen, nochmal, verlassen: genau ein Ereignis', (
      tester,
    ) async {
      await oeffnen(tester);
      await sekunden(tester, 60);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ExerciseDoneSheet), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('grounding-done-again')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BreathPacer), findsOneWidget);
      await sekunden(tester, 3);
      await zurueck(tester);

      expect(gemeldet(), ['uebung_beendet_breath']);
    });

    testWidgets('„Fertig“ vor der ersten Runde: genau ein Abbruch', (
      tester,
    ) async {
      await oeffnen(tester);
      await sekunden(tester, 3);
      await tester.tap(find.byKey(const ValueKey('grounding-breath-finish')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byKey(const ValueKey('grounding-done-back')));
      await tester.pumpAndSettle();

      expect(find.text('öffnen'), findsOneWidget);
      expect(gemeldet(), ['uebung_abgebrochen_breath']);
    });
  });
}
