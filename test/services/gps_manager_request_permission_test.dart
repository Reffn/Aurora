import 'dart:async';

import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_ce/hive.dart';

/// „Freigeben“ in den Einstellungen fragt nur nach dem Recht.
///
/// Vorher lief es über `getUserPosition(askIfDenied: true)`. Das holte nach
/// dem Ja auch eine Position, bis zu zehn Sekunden lang, und ein
/// gescheiterter Abruf meldete `fehler_gps_timeout`: einen Fehler, den
/// niemand erlebt hatte. Und solange der Abruf lief, blieb der
/// Tracking-Schalter gesperrt, obwohl die Zeile schon „Freigegeben“ sagte.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _System system;
  late GpsManager gps;
  late GeolocatorPlatform vorher;

  setUp(() async {
    vorher = GeolocatorPlatform.instance;
    system = _System();
    GeolocatorPlatform.instance = system;
    gps = GpsManager(
      eventBus: EventBus(),
      contactsBox: _LeereBox<Contact>(),
      finderItemsBox: _LeereBox<FinderItem>(),
    );
    // Der Konstruktor sieht asynchron nach; das soll durch sein.
    await pumpEventQueue();
  });

  tearDown(() {
    gps.dispose();
    GeolocatorPlatform.instance = vorher;
  });

  test('fragt nur nach dem Recht und setzt beide Zustände', () async {
    system.antwort = LocationPermission.whileInUse;
    expect(gps.hasGpsPermission.value, isFalse);
    expect(gps.hasTrackingPermission, isFalse);

    final ergebnis = await gps.requestPermission();

    expect(ergebnis, LocationPermission.whileInUse);
    expect(gps.hasGpsPermission.value, isTrue);
    expect(gps.permissionStatus.value, LocationPermission.whileInUse);
    // Daran hängt der Tracking-Schalter.
    expect(gps.hasTrackingPermission, isTrue);
    expect(system.anfragen, 1);
    expect(system.positionsabrufe, 0, reason: 'kein Positionsabruf');
  });

  test('„dauerhaft abgelehnt“ kommt als Zustand an', () async {
    system.antwort = LocationPermission.deniedForever;

    final ergebnis = await gps.requestPermission();

    expect(ergebnis, LocationPermission.deniedForever);
    expect(gps.hasGpsPermission.value, isFalse);
    expect(gps.permissionStatus.value, LocationPermission.deniedForever);
    expect(system.positionsabrufe, 0);
  });

  test('ein Doppeltipp fragt das System nur einmal', () async {
    // geolocator wirft, wenn eine zweite Anfrage kommt, solange die erste
    // offen ist.
    system.antwort = LocationPermission.whileInUse;
    final offen = Completer<void>();
    system.warteAuf = offen.future;

    final erste = gps.requestPermission();
    final zweite = gps.requestPermission();
    offen.complete();

    expect(await erste, LocationPermission.whileInUse);
    expect(await zweite, LocationPermission.whileInUse);
    expect(system.anfragen, 1);

    // Danach darf wieder gefragt werden.
    system.warteAuf = null;
    await gps.requestPermission();
    expect(system.anfragen, 2);
  });
}

/// Das Betriebssystem, so weit der GpsManager es sieht.
class _System extends GeolocatorPlatform {
  LocationPermission antwort = LocationPermission.denied;
  Future<void>? warteAuf;
  int anfragen = 0;
  int positionsabrufe = 0;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.denied;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> requestPermission() async {
    anfragen++;
    final halt = warteAuf;
    if (halt != null) await halt;
    return antwort;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    positionsabrufe++;
    throw TimeoutException('kein Fix im Test');
  }
}

class _LeereBox<T> implements Box<T> {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
