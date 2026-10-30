import 'dart:math';
import 'dart:typed_data';

import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/pending_telemetry_event.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/modules/onboarding/pre_onboarding_screen.dart';
import 'package:dis_app/services/release_notes_gate.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/temp_hive.dart';

/// Was die Vorstellung vor dem ersten Profil tun muss, egal wie viele Seiten
/// sie hat.
///
/// Die Tests blättern nicht nach Seitenzahl, sondern tippen den einen Knopf,
/// bis die Vorstellung abgeschlossen ist. So gelten sie für die fünf Seiten
/// bis 3.0.24 und für die eine ab 3.0.25 gleichermaßen — sie wurden gegen
/// die alte Fassung geschrieben und grün gesehen, bevor sie umgebaut wurde.
void main() {
  late Box<dynamic> settings;
  late Box<PendingTelemetryEvent> queue;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('de'));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Im Arbeitsspeicher: Echte Datei-Ein-/Ausgabe kommt in der Testzone von
    // `testWidgets` nicht zurück. Derselbe Name wie in der App — der Schirm
    // öffnet `settings` selbst und bekommt so diese Box.
    await openTempBox<dynamic>('hive_init_onb');
    settings = await Hive.openBox<dynamic>('settings', bytes: Uint8List(0));
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(PendingTelemetryEventAdapter());
    }
    queue = await Hive.openBox<PendingTelemetryEvent>(
      'telemetry_queue_onb',
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

  /// Lässt Seitenwechsel und Schreibvorgänge durchlaufen.
  Future<void> schreibenLassen(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> zeigen(WidgetTester tester) async {
    // Hoch genug, dass keine Seite überläuft — die Testschrift ist breiter
    // als jede echte.
    tester.view
      ..physicalSize = const Size(1200, 2400)
      ..devicePixelRatio = 1.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const PreOnboardingScreen(),
          ),
        ),
      ),
    );
    await schreibenLassen(tester);
  }

  /// Wählt Deutsch und tippt den Hauptknopf, bis die Vorstellung vorbei ist.
  Future<int> durchgehen(WidgetTester tester) async {
    await tester.tap(find.text('Deutsch'));
    await schreibenLassen(tester);

    var tipps = 0;
    while (settings.get('pre_onboarding_dismissed') != true && tipps < 10) {
      await tester.tap(find.byType(ElevatedButton));
      tipps++;
      await schreibenLassen(tester);
    }
    return tipps;
  }

  testWidgets('Beginn wird beim Öffnen gemeldet', (tester) async {
    await zeigen(tester);

    expect(gemeldet(), [TelemetryEventName.onboardingBegonnen.wireName]);
  });

  testWidgets('durchgegangen: Ende gemeldet, Fassung als gesehen gemerkt', (
    tester,
  ) async {
    await zeigen(tester);
    await durchgehen(tester);

    expect(settings.get('pre_onboarding_dismissed'), isTrue);
    // Ohne diesen Merker sähe jede Neuinstallation „Was sich geändert hat“.
    expect(settings.get(ReleaseNotesGate.storageKey), '3.0.25');
    expect(gemeldet(), [
      TelemetryEventName.onboardingBegonnen.wireName,
      TelemetryEventName.onboardingBeendet.wireName,
    ]);
  });

  testWidgets('„Nicht mehr anzeigen“ auf der ersten Seite ist ein Abbruch', (
    tester,
  ) async {
    await zeigen(tester);
    await tester.tap(find.text(l10n.onboardingDismiss));
    await schreibenLassen(tester);

    expect(settings.get('pre_onboarding_dismissed'), isTrue);
    expect(settings.get(ReleaseNotesGate.storageKey), '3.0.25');
    expect(gemeldet(), [
      TelemetryEventName.onboardingBegonnen.wireName,
      TelemetryEventName.onboardingAbgebrochenWillkommen.wireName,
    ]);
  });
}
