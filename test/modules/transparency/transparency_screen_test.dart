import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/transmission_log_entry.dart';
import 'package:dis_app/modules/transparency/transparency_screen.dart';
import 'package:dis_app/services/telemetry_consent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Diese Tests bauen das echte [TransparencyList] auf — dasselbe Widget, das
/// [TransparencyScreen] einsetzt. Eine frühere Fassung stellte die Liste in
/// der Testdatei nach; sie wäre grün geblieben, während der Bildschirm den
/// Text kürzt oder gar nichts anzeigt.
///
/// Das Protokoll kommt hier aus dem Speicher statt aus Hive: Echte
/// Datei-Ein-/Ausgabe blockiert in einem Widget-Test.
void main() {
  late List<TransmissionLogEntry> log;

  setUp(() => log = []);

  TransmissionLogEntry entry({
    String id = 'eintrag-1',
    String payloadText = 'Irgendein Text',
    TransmissionStatus status = TransmissionStatus.sent,
    TransmissionChannel channel = TransmissionChannel.feedback,
    String? errorMessage,
  }) {
    return TransmissionLogEntry(
      id: id,
      timestamp: DateTime(2026, 8, 5, 3, 14),
      channel: channel,
      payloadText: payloadText,
      status: status,
      errorMessage: errorMessage,
    );
  }

  Future<void> pumpList(WidgetTester tester, {TelemetryConsent? consent}) async {
    await tester.pumpWidget(
      MaterialApp(
        // Der Bildschirm holt seine Texte aus AppLocalizations. Ohne diese
        // drei Zeilen findet er keine und der Test bleibt beim Aufbauen
        // stehen, statt etwas zu pruefen.
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TransparencyList(
            readLog: () => List.of(log),
            eraseEntry: (id) async => log.removeWhere((e) => e.id == id),
            consent: consent,
            clearTelemetryQueue: () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('TransparencyList', () {
    testWidgets('sagt es, wenn noch nichts gesendet wurde', (tester) async {
      await pumpList(tester);

      // Der leere Zustand steht jetzt pro Kanal statt einmal für den ganzen
      // Bildschirm: Der Widerrufsschalter der Telemetrie wäre sonst genau
      // dann unerreichbar, wenn noch nichts gesendet wurde.
      expect(find.text('Es wurde noch nichts gesendet.'), findsNWidgets(2));
    });

    testWidgets('zeigt den gesendeten Text vollständig und im Wortlaut',
        (tester) async {
      const langerText = 'Kategorie: Fehler\n\n'
          'Beim Öffnen des Tagebuchs stürzt die App ab, sobald ein Eintrag '
          'ein Bild enthält. Das passiert seit dem letzten Update und jedes '
          'Mal, nicht nur manchmal.';

      log.add(entry(payloadText: langerText));
      await pumpList(tester);

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Wortlaut heißt: dieselbe Zeichenkette, ungekürzt. Ein "…" hier wäre
      // ein Bruch der Zusage aus CLAUDE.md.
      expect(find.text(langerText), findsOneWidget);
    });

    testWidgets('macht einen Fehlschlag samt Grund sichtbar', (tester) async {
      log.add(
        entry(
          status: TransmissionStatus.failed,
          errorMessage: 'Der Server hat die Nachricht abgelehnt.',
        ),
      );
      await pumpList(tester);

      // Eine Liste, die nur Erfolge zeigt, wäre wieder die Lüge, gegen die
      // dieser Umbau gebaut wurde.
      expect(
        find.textContaining('Der Server hat die Nachricht abgelehnt.'),
        findsOneWidget,
      );
    });

    testWidgets('nennt einen wartenden Versand nicht angekommen',
        (tester) async {
      log.add(entry(status: TransmissionStatus.pending));
      await pumpList(tester);

      expect(find.text('Wartet auf Verbindung'), findsOneWidget);
      expect(find.text('Angekommen'), findsNothing);
    });

    testWidgets('löscht erst nach Rückfrage', (tester) async {
      log.add(entry(payloadText: 'Dieser Eintrag bleibt'));
      await pumpList(tester);

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Eintrag löschen?'), findsOneWidget);

      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(log, hasLength(1));
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('löscht nach Bestätigung wirklich', (tester) async {
      log.add(entry(payloadText: 'Dieser Eintrag geht'));
      await pumpList(tester);

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();

      expect(log, isEmpty);
      expect(find.text('Es wurde noch nichts gesendet.'), findsNWidgets(2));
    });
  });

  group('TransparencyList und die zwei Kanäle', () {
    late TelemetryConsent consent;

    // Im Arbeitsspeicher statt in Hive, aus demselben Grund wie oben.
    setUp(() => consent = TelemetryConsent.inMemory());

    testWidgets('trennt Feedback und Telemetrie in eigene Gruppen',
        (tester) async {
      log
        ..add(entry(id: 'a'))
        ..add(entry(id: 'b', channel: TransmissionChannel.telemetry));
      await pumpList(tester);

      expect(find.text('Feedback'), findsOneWidget);
      expect(find.text('Telemetrie'), findsOneWidget);
    });

    testWidgets('zeigt ein Telemetrie-Ereignis im Klartext', (tester) async {
      log.add(
        entry(
          id: 'b',
          channel: TransmissionChannel.telemetry,
          payloadText: 'Ereignis: bereich_geoeffnet_chat\n'
              'Tag: 2026-08-05\n'
              'App-Version: 3.2.0',
        ),
      );
      await pumpList(tester);

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('bereich_geoeffnet_chat'),
        findsOneWidget,
      );
    });

    testWidgets('der Schalter steht auch bei leerem Protokoll bereit',
        (tester) async {
      await pumpList(tester, consent: consent);

      expect(find.byKey(const Key('telemetry_toggle')), findsOneWidget);
    });

    testWidgets('sagt, dass Gesendetes nicht zurückgeholt werden kann',
        (tester) async {
      await pumpList(tester, consent: consent);

      expect(
        find.textContaining('nicht zurückgeholt werden'),
        findsOneWidget,
      );
    });

    testWidgets('Einschalten erteilt die Einwilligung', (tester) async {
      await pumpList(tester, consent: consent);

      await tester.tap(find.byKey(const Key('telemetry_toggle')));
      await tester.pumpAndSettle();

      expect(consent.allowsRecording, isTrue);
    });

    testWidgets('Ausschalten widerruft sie', (tester) async {
      await consent.grant();
      await pumpList(tester, consent: consent);

      await tester.tap(find.byKey(const Key('telemetry_toggle')));
      await tester.pumpAndSettle();

      expect(consent.allowsRecording, isFalse);
      expect(consent.state, TelemetryConsentState.abgelehnt);
    });
  });
}
