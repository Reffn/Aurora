import 'dart:io';

import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:dis_app/services/geocoding_service.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';

/// Ein Zeitlimit beim ersten Positionsabruf ist keine fehlende Erlaubnis.
///
/// Drinnen läuft der Abruf (zehn Sekunden, hohe Genauigkeit) regelmäßig ins
/// Zeitlimit. Bis zum 29.10.2026 schloss `startTracking` daraus „keine
/// Erlaubnis", startete nicht und überschrieb den Spiegel der Erlaubnis mit
/// `false` — auch beim automatischen Wiederanlauf nach dem App-Start. Die
/// Aufzeichnung für „wo war ich?" blieb dann still aus.
void main() {
  late Directory ordner;

  setUp(() async {
    ordner = await Directory.systemTemp.createTemp('tracking_start');
    Hive.init(ordner.path);
  });

  tearDown(() async {
    await Hive.close();
    await ordner.delete(recursive: true);
  });

  Future<LocationTrackingService> baue(_GpsOhneFix gps) async =>
      LocationTrackingService(
        locationHistoryBox: await Hive.openBox<LocationHistoryEntry>('verlauf'),
        switchEventsBox: await Hive.openBox<ProfileSwitchEvent>('wechsel'),
        settingsBox: await Hive.openBox<dynamic>('einstellungen'),
        eventBus: EventBus(),
        geocodingService: _OhneGeocoding(),
        gpsManager: gps,
      );

  test('Zeitlimit beim ersten Abruf: die Aufzeichnung startet trotzdem',
      () async {
    final dienst = await baue(_GpsOhneFix(erlaubt: true));

    await dienst.startTracking();

    expect(dienst.isTrackingRunning.value, isTrue);
    expect(
      dienst.hasLocationPermission.value,
      isTrue,
      reason: 'die Erlaubnis kommt vom GpsManager, nicht vom Positionsfix',
    );
  });

  test('Mit Position startet es, auch wenn die Zustaende veraltet sind',
      () async {
    // Ein Treffer im Zwischenspeicher überspringt die Prüfung im GpsManager.
    // Die Position selbst beweist Erlaubnis und eingeschalteten Standort.
    final dienst = await baue(
      _GpsOhneFix(
        erlaubt: false,
        standortAn: false,
        position: const LatLng(52.52, 13.405),
      ),
    );

    await dienst.startTracking();

    expect(dienst.isTrackingRunning.value, isTrue);
  });

  test('Ohne Erlaubnis startet nichts', () async {
    final dienst = await baue(_GpsOhneFix(erlaubt: false));

    await expectLater(dienst.startTracking(), throwsException);

    expect(dienst.isTrackingRunning.value, isFalse);
  });

  test('Standort am Geraet ausgeschaltet: startet nicht', () async {
    final dienst = await baue(
      _GpsOhneFix(erlaubt: true, standortAn: false),
    );

    await expectLater(dienst.startTracking(), throwsException);

    expect(dienst.isTrackingRunning.value, isFalse);
  });
}

/// Ein GpsManager, der standardmäßig keine Position liefert — wie drinnen am
/// Gerät. Mit [position] spielt er einen Treffer im Zwischenspeicher.
class _GpsOhneFix implements GpsManager {
  _GpsOhneFix({required bool erlaubt, bool standortAn = true, this.position})
    : hasGpsPermission = ValueNotifier(erlaubt),
      isGpsServiceEnabled = ValueNotifier(standortAn);

  final LatLng? position;

  @override
  final ValueNotifier<bool> hasGpsPermission;

  @override
  final ValueNotifier<bool> isGpsServiceEnabled;

  @override
  Future<LatLng?> getUserPosition({
    bool askIfDenied = false,
    bool forceRefresh = false,
  }) async => position;

  @override
  Stream<LatLng> positionStream({
    required String notificationTitle,
    required String notificationText,
    Duration interval = const Duration(minutes: 2, seconds: 30),
    int distanceFilterMeters = 50,
  }) => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _OhneGeocoding implements GeocodingService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
