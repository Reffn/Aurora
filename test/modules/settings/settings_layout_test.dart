import 'dart:async';
import 'dart:io';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/permissions/permissions_manager_screen.dart';
import 'package:dis_app/modules/settings/sections/about_section.dart';
import 'package:dis_app/modules/settings/sections/debug_section.dart';
import 'package:dis_app/modules/settings/sections/location_section.dart';
import 'package:dis_app/modules/settings/sections/notifications_section.dart';
import 'package:dis_app/modules/settings/settings_screen.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/navigation_service.dart';
import 'package:dis_app/services/notification_service.dart';
import 'package:dis_app/services/password_reset_service.dart';
import 'package:dis_app/services/tile_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_ce/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Die Einstellungen in fünf ruhigen Gruppen: Zustand und höchstens eine
/// Handlung je Zeile, Erklärungen hinter ⓘ, Kartenspeicher und Diagnose auf
/// eigenen Seiten.
///
/// Befund zum Scroll-Stopp am Gerät (offen seit 13.08.2026: am A14 endete
/// das Scrollen beim Kartencache, „Zeitformat“ und „Sprache“ blieben unten
/// angeschnitten, vierzehn adb-Wische bewegten nichts):
///
/// Die Liste bleibt nicht hängen, sie erreicht ihr Ende. Dieses Ende lag
/// unter der Navigationsleiste. Die App läuft randlos
/// (`main.dart`, `SystemUiMode.edgeToEdge`, Leiste durchsichtig); der Scaffold
/// reicht die Leiste als `MediaQuery.padding.bottom` an den Körper durch.
/// Eine `ListView` ohne `padding` legt dieses Polster selbst an. Der Schirm
/// gab aber `EdgeInsets.all(8)` mit, und damit fiel es weg. Gemessen in
/// A14-Maßen (411 x 917 dp, Leiste 48 dp): Scrollweg voll ausgeschöpft
/// (`pixels == maxScrollExtent`), die Zeile „Sprache“ endet bei 901 dp, die
/// Leiste beginnt bei 869 dp. Am Ende hängen also 32 dp der letzten Zeile
/// unter der Leiste, und jeder weitere Wisch bewegt zu Recht nichts. Der Test
/// „die letzte Zeile endet über der Navigationsleiste“ war vor dem Umbau rot.
///
/// Verworfen: `settingsItems.clear()` im Builder baute nicht bei jedem Bild
/// neu. Nach dem Einschwingen ist kein Bild mehr angefordert, die
/// `ListView`-Instanz bleibt über vierzig Wische dieselbe, und ein Neuaufbau
/// über die Einstellungsbox lässt die Position stehen (letzter Test).
/// `PageStorageKey`, verschachtelte Scrollables, `shrinkWrap` und
/// `NeverScrollableScrollPhysics` gibt es im Schirm nicht.
///
/// Offen: Ob adb-Wische am Gerät anders wirken als ein Finger, kann ein
/// Widgettest nicht zeigen. Das klärt erst ein Wisch von Hand am Gerät.
void main() {
  late AppLocalizations l10n;
  late Directory tempDir;
  late _Einstellungen dataEntry;
  late _Gps gps;
  late _Kacheln kacheln;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('de'));
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('einstellungen_');
    Hive.init(tempDir.path);
    await getIt.reset();
    PackageInfo.setMockInitialValues(
      appName: 'Aurora',
      packageName: 'app.aurora',
      version: '3.0.31',
      buildNumber: '31',
      buildSignature: '',
    );
    dataEntry = _Einstellungen(
      settingsBox: await Hive.openBox<dynamic>('settings'),
      profilesBox: await Hive.openBox<Profile>('profiles'),
    );
    gps = _Gps();
    kacheln = _Kacheln();
    getIt
      ..registerSingleton<DataEntry>(dataEntry)
      ..registerSingleton<NavigationService>(_Navigation())
      ..registerSingleton<TileCacheManager>(kacheln)
      ..registerSingleton<GpsManager>(gps)
      ..registerSingleton<LocationTrackingService>(_Aufzeichnung())
      ..registerSingleton<NotificationService>(_Meldungen())
      ..registerSingleton<PasswordResetService>(_Reset());
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } on FileSystemException {
      // Windows hält Hive-Dateien gelegentlich noch kurz fest.
    }
  });

  /// Feste Schritte statt `pumpAndSettle`: Die Liste läuft mit gestaffelten
  /// Einblendungen.
  Future<void> warte(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> zeigen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    );
    await warte(tester);
  }

  /// Breit und hoch genug, dass jede Zeile ohne Scrollen gebaut ist und die
  /// Testschrift nirgends überläuft.
  void alles(WidgetTester tester) {
    tester.view.physicalSize = const Size(2400, 24000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  /// Galaxy A14: 1080 x 2408 px bei 2,625 px/dp, Statusleiste 24 dp,
  /// Drei-Tasten-Leiste 48 dp. Die App läuft randlos (`main.dart`,
  /// `SystemUiMode.edgeToEdge`), also kommen beide Leisten als Polster an.
  void a14(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2408);
    tester.view.devicePixelRatio = 2.625;
    tester.view.padding = const FakeViewPadding(top: 63, bottom: 126);
    tester.view.viewPadding = const FakeViewPadding(top: 63, bottom: 126);
    addTearDown(tester.view.reset);
  }

  /// Bei 411 dp Breite läuft die Testschrift über, weil dort jedes Zeichen
  /// so breit wie hoch ist. Am Gerät passt die Zeile; der Überlauf sagt hier
  /// nichts. Alles andere bleibt ein Fehler.
  Future<void> ohneTestschriftUeberlauf(Future<void> Function() body) async {
    final vorher = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      vorher?.call(details);
    };
    try {
      await body();
    } finally {
      FlutterError.onError = vorher;
    }
  }

  ScrollPosition position(WidgetTester tester) => tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      )
      .position;

  Future<void> bisZumEnde(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.fling(find.byType(ListView), const Offset(0, -500), 3000);
      for (var k = 0; k < 10; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  }

  /// Die drei Handlungen, von denen die Zeile „Standort“ höchstens eine
  /// zeigt.
  List<String> standortHandlungen() => [
    l10n.settingsLocationActionAllow,
    l10n.settingsLocationActionTurnOn,
    l10n.settingsLocationActionOpenAndroid,
  ];

  Switch trackingSchalter(WidgetTester tester) => tester.widget<Switch>(
    find.descendant(
      of: find.ancestor(
        of: find.text(l10n.settingsTrackingAlwaysOn),
        matching: find.byType(ListTile),
      ),
      matching: find.byType(Switch),
    ),
  );

  void nurDieseHandlung(String? erwartet) {
    for (final handlung in standortHandlungen()) {
      expect(
        find.text(handlung),
        handlung == erwartet ? findsOneWidget : findsNothing,
        reason: handlung,
      );
    }
  }

  testWidgets('Abschnitte in fester Reihenfolge', (tester) async {
    alles(tester);
    await zeigen(tester);

    // Überschriften und je Gruppe ihre Zeilen. Debug gibt es nur in
    // Entwicklungsbauten, Tests laufen als solche; dort steht er am Ende.
    final reihenfolge = [
      l10n.settingsSectionPersonal,
      l10n.settingsLanguage,
      l10n.settingsTimeFormat,
      l10n.settingsSectionNotifications,
      l10n.settingsDiscreetRemindersTitle,
      l10n.settingsSendTestNotification,
      l10n.settingsSectionMaps,
      l10n.settingsLocationTitle,
      l10n.settingsTrackingAlwaysOn,
      l10n.settingsOfflineMapsTitle,
      l10n.settingsSectionManagement,
      l10n.partsAndRightsTitle,
      l10n.settingsSectionAbout,
      l10n.settingsWhatAuroraSends,
      l10n.settingsPrivacy,
      l10n.settingsImpressum,
      l10n.settingsDiagnosticsTitle,
      l10n.settingsAppVersion,
      l10n.settingsSectionDebug,
      l10n.settingsDeleteAllData,
    ];
    for (final text in reihenfolge) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    final hoehen = [
      for (final text in reihenfolge) tester.getTopLeft(find.text(text)).dy,
    ];
    for (var i = 1; i < hoehen.length; i++) {
      expect(
        hoehen[i],
        greaterThan(hoehen[i - 1]),
        reason: '${reihenfolge[i]} steht unter ${reihenfolge[i - 1]}',
      );
    }
    // Die Fassung kommt erst nach dem ersten Bild an.
    expect(find.text('3.0.31+31'), findsOneWidget);

    // Was eine eigene Seite bekommen hat, steht nicht mehr hier.
    for (final text in [
      l10n.settingsCacheStorage,
      l10n.settingsCacheLimitLabel,
      l10n.settingsClearCache,
      l10n.settingsDebugLog,
      l10n.settingsQueue,
    ]) {
      expect(find.text(text), findsNothing, reason: text);
    }
  });

  testWidgets('keine Erklärtexte auf dem Hauptschirm', (tester) async {
    alles(tester);
    await zeigen(tester);

    for (final text in [
      l10n.settingsWhatIsAlwaysOn,
      l10n.settingsHowNotificationsWork,
      l10n.settingsAdminTrackingExplanation,
      l10n.settingsTrackingNotice,
      l10n.settingsLocationStaysOffline,
      l10n.settingsNotificationsBullet1,
      l10n.settingsNotificationsSubtitle,
      l10n.settingsHowToEnableLocation,
    ]) {
      expect(find.text(text), findsNothing, reason: text);
    }
    // „Anteile & Rechte“ ist eine Zeile ohne erklärende Unterzeile.
    final anteile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text(l10n.partsAndRightsTitle),
        matching: find.byType(ListTile),
      ),
    );
    expect(anteile.subtitle, isNull);
  });

  testWidgets('ⓘ zeigt die Erklärung', (tester) async {
    alles(tester);
    await zeigen(tester);

    final info = find.byTooltip(l10n.settingsInfoTooltip);
    expect(info, findsNWidgets(2), reason: 'Benachrichtigungen und Tracking');

    // Oben: Benachrichtigungen.
    await tester.tap(info.first);
    await warte(tester);
    for (final text in [
      l10n.settingsHowNotificationsWork,
      l10n.settingsNotificationsBullet1,
      l10n.settingsNotifAsNeeded,
      l10n.settingsNotificationsBullet3,
      l10n.settingsNotifWorksClosed,
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }

    // Der Knopf zum Schließen ist sichtbar, nicht nur das Wischen (Regel 8).
    await tester.tap(find.text(l10n.settingsUnderstood));
    await warte(tester);
    expect(find.text(l10n.settingsHowNotificationsWork), findsNothing);

    // Unten: Tracking dauerhaft an.
    await tester.tap(info.last);
    await warte(tester);
    for (final text in [
      l10n.settingsWhatIsAlwaysOn,
      l10n.settingsAdminTrackingExplanation,
      l10n.settingsPositionAlways,
      l10n.settingsGlobalTrackingBullet2,
      l10n.settingsOverridesProfiles,
      l10n.settingsAllProfilesTracked,
      l10n.settingsTrackingNotice,
      l10n.settingsLocationStaysOffline,
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('Diagnose enthält die Warteschlange', (tester) async {
    alles(tester);
    await zeigen(tester);

    await tester.tap(find.text(l10n.settingsDiagnosticsTitle));
    await warte(tester);

    expect(find.text(l10n.settingsDebugLog), findsOneWidget);
    expect(find.text(l10n.settingsQueue), findsOneWidget);
    expect(find.text(l10n.settingsScheduledNotifications), findsOneWidget);
    // Der Fake meldet drei vorgemerkte Erinnerungen.
    expect(find.text(l10n.settingsCountValue(3)), findsOneWidget);
  });

  testWidgets('Karten offline: Speicher, Grenze, Leeren', (tester) async {
    alles(tester);
    await zeigen(tester);

    await tester.tap(find.text(l10n.settingsOfflineMapsTitle));
    await warte(tester);

    for (final text in [
      l10n.settingsCacheStorage,
      l10n.settingsCacheLimitLabel,
      l10n.settingsClearCache,
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    // Nicht mehr: „Karten vorab laden“, das nur „kommt bald“ sagte. Eine
    // Handlung, die nur scheitern kann, wird nicht angeboten.
    expect(find.byType(Card), findsNWidgets(3));
  });

  testWidgets('Karten offline: nach dem Leeren stimmen die Zahlen', (
    tester,
  ) async {
    alles(tester);
    await zeigen(tester);
    await tester.tap(find.text(l10n.settingsOfflineMapsTitle));
    await warte(tester);
    expect(
      find.text(l10n.settingsTilesCount('120', '500', '4.321')),
      findsOneWidget,
    );

    await tester.tap(find.text(l10n.settingsClearCache));
    await warte(tester);
    await tester.tap(
      find.widgetWithText(FilledButton, l10n.settingsClearCache),
    );
    await warte(tester);

    expect(kacheln.geleert, isTrue);
    expect(find.text(l10n.settingsTilesCount('0', '500', '0')), findsOneWidget);

    // Die Bestätigung blendet sich nach drei Sekunden selbst aus.
    await tester.pump(const Duration(seconds: 4));
  });

  group('Standort: Zustand und genau eine Handlung', () {
    testWidgets('freigegeben: nur der Zustand', (tester) async {
      alles(tester);
      await zeigen(tester);

      expect(find.text(l10n.settingsLocationStateAllowed), findsOneWidget);
      nurDieseHandlung(null);
    });

    testWidgets('nicht freigegeben: Freigeben fragt nur nach dem Recht', (
      tester,
    ) async {
      gps.zustand(erlaubt: false, status: LocationPermission.denied);
      alles(tester);
      await zeigen(tester);

      expect(find.text(l10n.settingsLocationStateNotAllowed), findsOneWidget);
      nurDieseHandlung(l10n.settingsLocationActionAllow);

      gps.antwortAufAnfrage = LocationPermission.whileInUse;
      await tester.tap(find.text(l10n.settingsLocationActionAllow));
      await warte(tester);

      expect(gps.aufrufe, contains('anfragen'));
      // Kein Positionsabruf: Ein gescheiterter meldete `fehler_gps_timeout`.
      expect(gps.aufrufe, isNot(contains('position')));
      expect(find.text(l10n.settingsLocationStateAllowed), findsOneWidget);
      nurDieseHandlung(null);
      // Ja gesagt: kein Blatt mit Schritten hinterher.
      expect(find.text(l10n.settingsHowToEnableLocation), findsNothing);
    });

    testWidgets('nach Freigeben ist der Tracking-Schalter sofort bedienbar', (
      tester,
    ) async {
      gps.zustand(erlaubt: false, status: LocationPermission.denied);
      alles(tester);
      await zeigen(tester);
      expect(trackingSchalter(tester).onChanged, isNull);

      gps.antwortAufAnfrage = LocationPermission.whileInUse;
      await tester.tap(find.text(l10n.settingsLocationActionAllow));
      await warte(tester);

      expect(trackingSchalter(tester).onChanged, isNotNull);
    });

    testWidgets('ein einfaches Nein lässt Freigeben stehen, ohne Blatt', (
      tester,
    ) async {
      // Das System fragt beim nächsten Mal wieder; der Knopf trägt noch.
      gps.zustand(erlaubt: false, status: LocationPermission.denied);
      alles(tester);
      await zeigen(tester);

      await tester.tap(find.text(l10n.settingsLocationActionAllow));
      await warte(tester);

      expect(gps.aufrufe, ['anfragen']);
      expect(find.text(l10n.settingsHowToEnableLocation), findsNothing);
      nurDieseHandlung(l10n.settingsLocationActionAllow);
    });

    testWidgets('fragt das System nicht mehr, zeigt Freigeben den Weg', (
      tester,
    ) async {
      gps.zustand(erlaubt: false, status: LocationPermission.denied);
      alles(tester);
      await zeigen(tester);

      gps.antwortAufAnfrage = LocationPermission.deniedForever;
      await tester.tap(find.text(l10n.settingsLocationActionAllow));
      await warte(tester);

      expect(gps.aufrufe, ['anfragen']);
      expect(find.text(l10n.settingsHowToEnableLocation), findsOneWidget);
      expect(find.text(l10n.settingsOpenAndroidSettings), findsOneWidget);
    });

    testWidgets('Ortung aus: Einschalten öffnet die Ortungseinstellungen', (
      tester,
    ) async {
      gps.isGpsServiceEnabled.value = false;
      alles(tester);
      await zeigen(tester);

      expect(find.text(l10n.settingsLocationStateOff), findsOneWidget);
      nurDieseHandlung(l10n.settingsLocationActionTurnOn);

      await tester.tap(find.text(l10n.settingsLocationActionTurnOn));
      await warte(tester);
      expect(gps.aufrufe, ['ortungsdienst']);
    });

    testWidgets('dauerhaft abgelehnt: Blatt mit den Schritten, dann Android', (
      tester,
    ) async {
      gps.zustand(erlaubt: false, status: LocationPermission.deniedForever);
      alles(tester);
      await zeigen(tester);

      expect(find.text(l10n.settingsLocationStateBlocked), findsOneWidget);
      nurDieseHandlung(l10n.settingsLocationActionOpenAndroid);

      await tester.tap(find.text(l10n.settingsLocationActionOpenAndroid));
      await warte(tester);

      for (final text in [
        l10n.settingsHowToEnableLocation,
        l10n.settingsStepOpenSettings,
        l10n.settingsStepPermissionLocation,
        l10n.settingsStepChooseWhileUsing,
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      // Noch nichts geöffnet: erst lesen, dann selbst tippen.
      expect(gps.aufrufe, isEmpty);

      await tester.tap(find.text(l10n.settingsOpenAndroidSettings));
      await warte(tester);
      expect(gps.aufrufe, ['android']);
    });
  });

  testWidgets('ohne Rechte vergeben keine Verwaltung und kein Dauer-Tracking', (
    tester,
  ) async {
    dataEntry.aktiv = Profile(
      id: 'mira',
      nameRaw: 'Mira',
      preferredColorValue: 0xFF3366CC,
      createdAt: DateTime(2026),
      permissions: [Permission.accessSettings.persistedValue],
    );
    alles(tester);
    await zeigen(tester);

    expect(find.text(l10n.settingsSectionManagement), findsNothing);
    expect(find.text(l10n.partsAndRightsTitle), findsNothing);
    expect(find.text(l10n.settingsTrackingAlwaysOn), findsNothing);
    // Nur noch das ⓘ der Benachrichtigungen.
    expect(find.byTooltip(l10n.settingsInfoTooltip), findsOneWidget);
    for (final text in [
      l10n.settingsSectionPersonal,
      l10n.settingsSectionNotifications,
      l10n.settingsSectionMaps,
      l10n.settingsLocationTitle,
      l10n.settingsOfflineMapsTitle,
      l10n.settingsSectionAbout,
      l10n.settingsWhatAuroraSends,
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  // Regel 31: „Anteile pausieren“ braucht einen Weg hinein, auch ohne
  // „Rechte vergeben“. Pausieren und Zurückholen gibt es nur in
  // „Anteile & Rechte“.
  testWidgets('nur mit Anteile pausieren: Verwaltung führt zu Anteile & '
      'Rechte', (tester) async {
    dataEntry.aktiv = Profile(
      id: 'mira',
      nameRaw: 'Mira',
      preferredColorValue: 0xFF3366CC,
      createdAt: DateTime(2026),
      permissions: [Permission.deactivateProfiles.persistedValue],
    );
    alles(tester);
    await zeigen(tester);

    expect(find.text(l10n.settingsSectionManagement), findsOneWidget);
    // Dauer-Tracking bleibt bei „Rechte vergeben“.
    expect(find.text(l10n.settingsTrackingAlwaysOn), findsNothing);

    await tester.tap(find.text(l10n.partsAndRightsTitle));
    await warte(tester);
    expect(find.byType(PermissionsManagerScreen), findsOneWidget);
  });

  testWidgets('die letzte Zeile endet über der Navigationsleiste', (
    tester,
  ) async {
    a14(tester);
    await ohneTestschriftUeberlauf(() async {
      await zeigen(tester);
      await bisZumEnde(tester);

      final pos = position(tester);
      expect(pos.pixels, pos.maxScrollExtent, reason: 'Ende erreicht');

      final media = MediaQuery.of(tester.element(find.byType(ListView)));
      expect(media.padding.bottom, 48, reason: 'Leiste kommt als Polster an');
      final sichtbarBis =
          tester.view.physicalSize.height / tester.view.devicePixelRatio -
          media.padding.bottom;
      // Welche Zeile die letzte ist, hängt vom Bau ab (in Entwicklungsbauten
      // „Alle Daten löschen“, sonst die Fassung). Gemessen wird die unterste.
      final karten = find.byType(Card);
      final unterkante = [
        for (var i = 0; i < karten.evaluate().length; i++)
          tester.getRect(karten.at(i)).bottom,
      ].reduce((a, b) => a > b ? a : b);
      expect(unterkante, lessThanOrEqualTo(sichtbarBis));
    });
  });

  testWidgets('ein Neuaufbau wirft die Scrollposition nicht zurück', (
    tester,
  ) async {
    a14(tester);
    await ohneTestschriftUeberlauf(() async {
      await zeigen(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -1500));
      await warte(tester);
      final vorher = position(tester).pixels;
      expect(vorher, greaterThan(1000));

      // Jeder Wächter und die Zeilen unter „Für dich“ hören auf die ganze
      // Einstellungsbox.
      await tester.runAsync(() => dataEntry.settingsBox.put('egal', 1));
      await warte(tester);

      expect(position(tester).pixels, vorher);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  testWidgets('Abschnitte behalten ihren Zustand außer Sicht', (tester) async {
    // Jeder Abschnitt hält seinen Zustand selbst, und die Liste baut weit
    // Entferntes ab. Ohne Keep-alive verlor ein Abschnitt dabei seinen
    // State: Ein Ablauf, der noch lief, fand `mounted == false` und zeigte
    // nie etwas, Snackbars fielen weg, Zahlen luden neu.
    a14(tester);
    await ohneTestschriftUeberlauf(() async {
      await zeigen(tester);
      final oben = tester.state(find.byType(SettingsNotificationsSection));

      await bisZumEnde(tester);

      for (final abschnitt in [
        SettingsNotificationsSection,
        SettingsLocationSection,
        SettingsAboutSection,
        SettingsDebugSection,
      ]) {
        expect(
          find.byType(abschnitt, skipOffstage: false),
          findsOneWidget,
          reason: '$abschnitt',
        );
      }
      expect(
        tester.state(
          find.byType(SettingsNotificationsSection, skipOffstage: false),
        ),
        same(oben),
      );
    });
  });
}

/// Ada ist aktiv und Admin. Die Boxen sind echt, weil der Schirm
/// `Hive.box('settings')` direkt öffnet.
class _Einstellungen implements DataEntry {
  _Einstellungen({required this.settingsBox, required this.profilesBox});

  @override
  final Box<dynamic> settingsBox;

  @override
  final Box<Profile> profilesBox;

  Profile? aktiv = Profile(
    id: 'ada',
    nameRaw: 'Ada',
    preferredColorValue: 0xFF3366CC,
    createdAt: DateTime(2026),
    isAdmin: true,
    permissions: Permission.values.map((p) => p.persistedValue).toList(),
  );

  @override
  Profile? getActiveProfile() => aktiv;

  // Was „Anteile & Rechte“ beim Aufbau fragt. Wer dort was darf, prüft
  // `parts_and_rights_test.dart`.
  @override
  List<Profile> getProfiles() => [?aktiv];

  @override
  List<Profile> getPausedProfiles() => const [];

  @override
  bool canResumeProfiles() =>
      aktiv?.hasPermission(Permission.deactivateProfiles) ?? false;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Navigation implements NavigationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Reset implements PasswordResetService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Kacheln implements TileCacheManager {
  int _groesseMB = 120;
  int _anzahl = 4321;
  bool geleert = false;

  @override
  int get maxCacheSizeMB => 500;

  @override
  Future<int> getCacheSizeMB() async => _groesseMB;

  @override
  Future<int> getTileCount() async => _anzahl;

  @override
  Future<void> clearCache() async {
    geleert = true;
    _groesseMB = 0;
    _anzahl = 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Hält den Zustand wie der echte Manager: `hasGpsPermission` und
/// `permissionStatus` getrennt. Was das System selbst hält, steht in
/// [system]; Nachsehen liefert davon, was Android verrät.
class _Gps implements GpsManager {
  @override
  final ValueNotifier<bool> hasGpsPermission = ValueNotifier(true);

  @override
  final ValueNotifier<bool> isGpsServiceEnabled = ValueNotifier(true);

  @override
  final ValueNotifier<LocationPermission> permissionStatus = ValueNotifier(
    LocationPermission.whileInUse,
  );

  /// Was das System gerade hält.
  LocationPermission system = LocationPermission.whileInUse;

  /// Was das System auf eine Anfrage antwortet.
  LocationPermission antwortAufAnfrage = LocationPermission.denied;

  /// Welche Wege nach außen benutzt wurden, in Reihenfolge.
  final aufrufe = <String>[];

  void zustand({required bool erlaubt, required LocationPermission status}) {
    hasGpsPermission.value = erlaubt;
    permissionStatus.value = status;
    system = status;
  }

  bool _erlaubt(LocationPermission p) =>
      p == LocationPermission.whileInUse || p == LocationPermission.always;

  @override
  bool get hasTrackingPermission => _erlaubt(permissionStatus.value);

  @override
  bool get hasAlwaysPermission =>
      permissionStatus.value == LocationPermission.always;

  @override
  bool get hasWhileInUsePermission =>
      permissionStatus.value == LocationPermission.whileInUse;

  @override
  Future<LocationPermission> requestPermission() async {
    aufrufe.add('anfragen');
    system = antwortAufAnfrage;
    permissionStatus.value = system;
    hasGpsPermission.value = _erlaubt(system);
    return system;
  }

  /// Wie der echte Manager: Nach dem Ja wird eine Position geholt, und das
  /// dauert. Hier endet es nie, so wie ein Abruf ohne Fix bis zur Grenze.
  @override
  Future<LatLng?> getUserPosition({
    bool forceRefresh = false,
    bool askIfDenied = false,
  }) {
    if (askIfDenied) {
      aufrufe.add('position');
      system = antwortAufAnfrage;
      hasGpsPermission.value = _erlaubt(system);
    }
    return Completer<LatLng?>().future;
  }

  @override
  Future<bool> refreshAndCheckTrackingPermission() async {
    // Wie Android: `checkPermission` kennt kein „dauerhaft“.
    final gesehen = system == LocationPermission.deniedForever
        ? LocationPermission.denied
        : system;
    permissionStatus.value = gesehen;
    hasGpsPermission.value = _erlaubt(gesehen);
    return hasTrackingPermission;
  }

  @override
  Future<bool> openAppSettings() async {
    aufrufe.add('android');
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    aufrufe.add('ortungsdienst');
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Aufzeichnung implements LocationTrackingService {
  @override
  final ValueNotifier<bool> isTrackingRunning = ValueNotifier(false);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Meldungen implements NotificationService {
  @override
  bool get discreetReminders => false;

  @override
  Future<int> countScheduledReminders() async => 3;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
