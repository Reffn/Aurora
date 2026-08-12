import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:dis_app/widgets/time_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/text_scale_harness.dart';

/// Dummy Box fuer Tests. Implementiert nicht das echte Box-Interface,
/// aber hat genug um nicht abzustürzen wenn GpsManager sie übergeben bekommt.
/// Sie werden nicht gelesen oder geschrieben, nur als Konstruktor-Parameter
/// an GpsManager übergeben.
class _DummyBox<T> implements Box<T> {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Alle Methoden-Aufrufe ignorieren. Kein echter Zugriff auf die Box.
    return null;
  }
}

/// Dummy MapService fuer Tests. OverviewMap braucht das, um zu existieren,
/// aber der echte MapService ist kompliziert zu initialisieren (Flutter Map,
/// Tile-Provider, etc.). Dieser Dummy hat genug um nicht abzustürzen.
class _DummyMapService implements MapService {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

/// Dummy DataEntry fuer Tests. OverviewMap braucht das in initState.
class _DummyDataEntry implements DataEntry {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

/// Dummy LocationTrackingService fuer Tests. OverviewMap braucht das.
class _DummyLocationTrackingService implements LocationTrackingService {
  /// hasLocationPermission muss ein ValueListenable<bool> sein.
  /// OverviewMap liest diese Property in build().
  final ValueNotifier<bool> _hasLocationPermission = ValueNotifier(false);

  @override
  ValueListenable<bool> get hasLocationPermission => _hasLocationPermission;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Andere Methoden ignorieren.
    return null;
  }
}

void main() {
  setUp(() async {
    // SharedPreferences-Channel mockieren. Das verhindert, dass MapService.openBoxes()
    // einen MissingPluginException wirft, wenn es SharedPreferences.getInstance() aufruft.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // GetIt zurücksetzen, um alte Registrierungen zu löschen.
    await getIt.reset();

    // GpsManager in getIt registrieren. Der echte GpsManager braucht
    // EventBus und Hive-Boxen, und ruft _initialize() auf.
    //
    // Stattdessen benutzen wir einen Test-spezifischen Subclass, der
    // _initialize() überschreibt (kein Op in Tests).
    // TimeMap.build() liest nur hasGpsPermission, das startet auf false.
    //
    // Die Boxen sind schwierig zu mocken (Hive braucht Init), also benutzen
    // wir Hive.box() direkt und hoffen, dass sie nicht gelesen werden.
    // Wenn Hive nicht initialisiert ist, werden sie als leere Boxen
    // gegeben (in-memory).
    final eventBus = EventBus();

    // Für die Boxen verwenden wir einen Workaround: Wir erstellen sie
    // als leere dynamische Objekte. Sie werden nicht gelesen, nur
    // an GpsManager übergeben. Das ist nicht ideal, aber minimales Setup.
    //
    // Dart-Trick: Wir erstellen ein anon. Objekt mit Reflection,
    // das Boxen "aussieht", aber alles ignoriert.
    final mockContactsBox = _DummyBox<Contact>();
    final mockFinderItemsBox = _DummyBox<FinderItem>();

    final gpsManager = _TestGpsManager(
      eventBus: eventBus,
      contactsBox: mockContactsBox,
      finderItemsBox: mockFinderItemsBox,
    );

    getIt.registerSingleton<GpsManager>(gpsManager);

    // Weitere Services registrieren, die OverviewMap braucht.
    // Der echte Implementations sind kompliziert zu initialisieren,
    // also benutzen wir Dummies mit noSuchMethod.
    getIt.registerSingleton<MapService>(_DummyMapService());
    getIt.registerSingleton<DataEntry>(_DummyDataEntry());
    getIt.registerSingleton<LocationTrackingService>(
      _DummyLocationTrackingService(),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  // Der Test nutzt das echte TimeMap Widget. Die Karte wird ohne Dienste gebaut:
  // Reine Anzeigelogik, keine Hive-Boxen. Die fake GpsManager mit hasGpsPermission=false
  // sorgt dafuér, dass der Standorthinweis unter der Karte sichtbar wird.
  //
  // Die Zusicherung: Bei allen Schriftgroessen und Geraetgroessen darf sich der
  // Kopfstrang (Datum, Uhrzeit, Ort oben in der Karte) nicht mit dem Standorthinweis
  // (unten unter der Karte, bei keinen Rechten) ueberlagern. Die alte Implementierung
  // hatte den Hinweis INSIDE den Stack als Positioned(bottom:0), wo er bei großer
  // Schrift nach oben wuchs und die Kopfzeile verdeckte.

  for (final geraet in [geraetA14, geraetS24]) {
    for (final skala in [1.0, 1.5, 2.0]) {
      testWidgets(
        'Kopf und Standortbitte ueberlagern sich nicht — ${geraet == geraetA14 ? "A14" : "S24"} bei $skala',
        (tester) async {
          // Das echte TimeMap Widget. Leere Listen fuer Tracks/Events, weil wir
          // nur die Ueberlapprung testen, nicht den Inhalt.
          //
          // height: 200 dp — die Realitaet. profile_selection_screen.dart clamped
          // die Kartenhöhe auf [150, 260] dp. Diese Tests muessen im echten Fenster
          // laufen, nicht mit artifiziellem Oversize (400 dp), der den Fehler verdeckt.
          // OverviewMap kann bei 200 dp und großen Schriftskalen Layout-Overflows haben,
          // die nicht mit TimeMap/Standorthinweis zu tun haben. Der schmale catch
          // der try-Anweisung ignoriert diese, nicht aber Overlap-Ausfaelle.
          final karte = TimeMap(
            track: const [],
            switchEvents: const [],
            pastEvents: const [],
            upcomingEvents: const [],
            profileNameOf: (_) => null,
            height: 200,
          );

          tester.view.physicalSize = geraet.size;
          tester.view.devicePixelRatio = geraet.ratio;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('de'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, kern) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(skala)),
                child: kern!,
              ),
              home: Scaffold(body: karte),
            ),
          );

          // pump() statt pumpAndSettle(), weil die Karte kontinuierliche Updates hat
          // (GPS, Map, etc.) die nie vollstaendig "settle" würden. Nach einem Frame
          // ist das Layout stabil genug zum Testen.
          await tester.pump();

          // OverviewMap laeuft bei kleiner Karte und grosser Schrift selbst ueber.
          // Das ist ein eigener Befund (siehe Ledger), nicht der, den dieser Test
          // bewacht — er wird hier bewusst entgegengenommen und benannt, damit die
          // Ueberlagerungsprobe darunter trotzdem greift. Jeder andere Fehler
          // bricht den Test.
          final fehler = tester.takeException();
          if (fehler != null) {
            expect(
              fehler.toString(),
              contains('overflowed'),
              reason: 'Unerwarteter Fehler beim Aufbau: $fehler',
            );
          }

          // Verifizierung: Der Kopfstrang (oben in der Karte) und der Standorthinweis
          // (unten ausserhalb der Karte) duerfen sich nicht ueberlagern.
          expectNoOverlap(
            tester,
            find.byKey(TimeMap.kopfSchluessel),
            find.byKey(TimeMap.standortHinweisSchluessel),
          );
        },
      );
    }
  }

  testWidgets('Ohne Standortfreigabe nimmt die Karte nicht die volle Höhe', (
    tester,
  ) async {
    // 280 dp ist das Maß vom Anker (main.dart). Ohne Freigabe gab es dort
    // nichts zu zeigen: keine Kacheln, keinen Weg, keine Marken. Am S24 stand
    // am 11. August 2026 eine schwarze Fläche in voller Höhe, und der Satz,
    // der sie erklärt, lag darunter hinter der Systemleiste.
    final karte = TimeMap(
      track: const [],
      switchEvents: const [],
      pastEvents: const [],
      upcomingEvents: const [],
      profileNameOf: (_) => null,
      height: 280,
    );

    tester.view.physicalSize = geraetS24.size;
    tester.view.devicePixelRatio = geraetS24.ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(alignment: Alignment.topCenter, child: karte),
        ),
      ),
    );
    await tester.pump();
    tester.takeException();

    final hoehe = rectOf(tester, find.byType(TimeMap)).height;
    expect(
      hoehe,
      lessThan(280),
      reason: 'Die Karte reserviert Kartenhöhe, obwohl sie keine Karte zeigt.',
    );

    // Schärfer als „kleiner als 280": Kopf und Band sind alles, was dieser
    // Zustand hat, und dazwischen liegt nichts.
    //
    // Die alte Grenze war zu weit. Der Kopf stand in einem 104 dp hohen
    // Kasten, obwohl er 56 braucht — die Differenz war schwarze Fläche, und
    // der Test blieb grün, weil 209 nun einmal kleiner ist als 280. Am Anker
    // fehlten genau diese Zentimeter der ersten Kachelreihe.
    final kopf = rectOf(tester, find.byKey(TimeMap.kopfSchluessel)).height;
    final band =
        rectOf(tester, find.byKey(TimeMap.standortHinweisSchluessel)).height;
    expect(
      hoehe,
      closeTo(kopf + band, 1),
      reason: 'Zwischen Kopf und Hinweis steht reservierte Kartenfläche.',
    );

    // Und die Erklärung steht mit im Bild, nicht darunter.
    expectFullyVisible(tester, find.byKey(TimeMap.standortHinweisSchluessel));
  });

  testWidgets('„Erlauben" hat überall dieselbe Farbe', (tester) async {
    // Das Band bringt seinen eigenen schwarzen Verlauf mit. Der Knopf nahm
    // trotzdem `colorScheme.primary` von dort, wo er eingebaut war — auf der
    // Profilauswahl violett, am Anker hellblau. Derselbe Satz in zwei Farben.
    for (final ton in [Colors.deepPurple, Colors.lightBlue, Colors.pink]) {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(colorSchemeSeed: ton, brightness: Brightness.dark),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: TimeMap(
                track: const [],
                switchEvents: const [],
                pastEvents: const [],
                upcomingEvents: const [],
                profileNameOf: (_) => null,
                height: 280,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      tester.takeException();

      final knopf = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Erlauben'),
      );
      expect(
        knopf.style?.foregroundColor?.resolve(<WidgetState>{}),
        Colors.white,
        reason: 'Der Knopf erbt seine Farbe vom Umgebungs-Theme ($ton).',
      );
    }
  });
}

/// Test-spezifischer GpsManager, der _initialize() überschreibt.
///
/// Der echte GpsManager ruft _initialize() auf, die in einem Test-Setup
/// kompliziert werden kann (WidgetsBinding, Permissions abfragen, etc.).
/// Diese Subclass überschreibt _initialize() zu einem No-Op, damit
/// TimeMap.build() die hasGpsPermission ValueListenable lesen kann,
/// die auf false startet (wie gewünscht für den Test).
class _TestGpsManager extends GpsManager {
  _TestGpsManager({
    required EventBus eventBus,
    required Box<Contact> contactsBox,
    required Box<FinderItem> finderItemsBox,
  }) : super(
         eventBus: eventBus,
         contactsBox: contactsBox,
         finderItemsBox: finderItemsBox,
       );

  // Hier stand ein `@override Future<void> _initialize()` mit dem Kommentar
  // „No-Op in tests". Das war nicht wahr: `_initialize` ist in `GpsManager`
  // privat, eine Unterklasse aus einer anderen Datei kann es nicht
  // überschreiben. Der Konstruktor rief weiterhin das echte auf
  // (`gps_manager.dart:37`), und der Analyzer sagte es auch
  // (`override_on_non_overriding_member`).
  //
  // Dass der Test trotzdem stimmt, liegt nicht an dieser Klasse: Im
  // Testumfeld gibt es keinen Plattformkanal, der eine Berechtigung
  // liefern könnte, also bleibt `hasGpsPermission` auf seinem Startwert
  // `false` — und genau darauf zeigt TimeMap den Standorthinweis.
  //
  // Die Klasse bleibt als benannter Ort für diese Annahme. Sollte
  // `_initialize` je ohne Kanal an ein `true` kommen, fällt der Test um,
  // statt still das Falsche zu messen.
}
