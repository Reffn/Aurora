import 'dart:async';

import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/location_events.dart';
import 'package:dis_app/core/events/profile_events.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:dis_app/services/geocoding_service.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/tracking_boot_notice.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

/// Service für GPS-Tracking und Timeline-Funktionalität
///
/// **Features:**
/// - Periodisches GPS-Tracking (alle 2-3 Minuten)
/// - Profil-Wechsel Events aufzeichnen
/// - Auto-Cleanup alter Daten (30 Tage)
/// - Tracking kann aktiviert/deaktiviert werden
class LocationTrackingService {
  LocationTrackingService({
    required this.locationHistoryBox,
    required this.switchEventsBox,
    required this.settingsBox,
    required this.eventBus,
    required this.geocodingService,
    required this.gpsManager,
  }) {
    // Initialisierung
    _initialize();
  }

  final Box<LocationHistoryEntry> locationHistoryBox;
  final Box<ProfileSwitchEvent> switchEventsBox;
  final Box<dynamic> settingsBox;
  final EventBus eventBus;
  final GeocodingService geocodingService;
  final GpsManager gpsManager;

  /// Läuft die Aufzeichnung gerade?
  ///
  /// **Nicht** zu verwechseln mit dem Wunsch, der in [_wunschSchluessel] liegt.
  /// Der Wunsch überlebt den Neustart; dieser Wert kippt, sobald der
  /// Positionsstrom abbricht. Genau diese Verwechslung hat die Aufzeichnung
  /// stillgelegt: Die Einstellungen lasen den Wunsch, fanden ihn auf `true` und
  /// starteten deshalb nicht — während nichts lief. Der frühere Name
  /// `isTrackingEnabled` lud dazu ein.
  final ValueNotifier<bool> _isTrackingRunning = ValueNotifier(false);
  ValueListenable<bool> get isTrackingRunning => _isTrackingRunning;

  /// GPS-Berechtigung erteilt?
  final ValueNotifier<bool> _hasLocationPermission = ValueNotifier(false);
  ValueListenable<bool> get hasLocationPermission => _hasLocationPermission;

  /// Letztes GPS-Update
  final ValueNotifier<DateTime?> _lastUpdate = ValueNotifier(null);
  ValueListenable<DateTime?> get lastUpdate => _lastUpdate;

  /// Der Positionsstrom, an dem auf Android der Vordergrunddienst hängt.
  ///
  /// Hier stand ein `Timer.periodic`. Der lief nur, solange der App-Prozess
  /// lebte — und starb mit ihm, sobald Android aufräumte oder jemand die App
  /// wegwischte. Die Einstellungen versprachen trotzdem dauerhafte Erfassung
  /// „auch im Hintergrund". Wer nach einer Dissoziation wissen wollte, wo er
  /// war, fand ein Loch und erfuhr nie, warum.
  StreamSubscription<LatLng>? _positionSubscription;

  /// StreamSubscription für Profil-Wechsel Events
  StreamSubscription<ActiveProfileChangedEvent>? _profileSwitchSubscription;

  /// StreamSubscription für GPS-Permission Events
  StreamSubscription<LocationPermissionGrantedEvent>?
  _permissionGrantedSubscription;
  StreamSubscription<LocationPermissionDeniedEvent>?
  _permissionDeniedSubscription;

  /// ID des aktuell aktiven Profils
  String? _currentProfileId;

  /// Letzte gespeicherte Position (für Distanz-Check)
  LatLng? _lastPosition;

  /// Tracking-Intervall (2-3 Minuten)
  static const _trackingInterval = Duration(minutes: 2, seconds: 30);

  /// Daten-Retention (30 Tage)
  static const _dataRetentionDays = 30;

  /// Mindest-Distanz für neue Position (in Metern)
  static const _minDistanceMeters = 50.0;

  /// Wo der Wunsch liegt — „ich möchte, dass aufgezeichnet wird".
  ///
  /// Privat, und die Lint `no_raw_tracking_flag` hält es so. Der Schlüssel war
  /// vorher an vier Stellen als Zeichenkette ausgeschrieben, eine davon
  /// außerhalb dieses Dienstes. Genau die las den Wunsch und hielt ihn für den
  /// Laufzustand.
  static const _wunschSchluessel = 'gps_tracking_enabled';

  /// Initialisierung
  Future<void> _initialize() async {
    logger.info(
      LogCategory.service,
      'LocationTrackingService initialisiert',
    );

    // Der GPS-Manager ist die einzige Quelle. Hier stand eine Kopie seines
    // Wertes — gelesen in dem Moment, in dem er noch bei
    // Geolocator.checkPermission() wartete. Am Gerät lagen fünf Millisekunden
    // dazwischen: Dieser Dienst merkte sich `false`, der Manager stellte kurz
    // darauf `true` fest und sagte es niemandem, weil sein Ereignis nur bei
    // einer Änderung feuert. Danach zeigte die Notfallkarte den Hinweis
    // „Standort verweigert" über einer Karte, die die Position hatte.
    gpsManager.hasGpsPermission.addListener(_onGpsPermissionChanged);
    _hasLocationPermission.value = gpsManager.hasGpsPermission.value;
    logger.info(
      LogCategory.service,
      'GPS-Permission Status: ${_hasLocationPermission.value}',
    );

    // Profil-Wechsel Events hören
    _profileSwitchSubscription = eventBus
        .on<ActiveProfileChangedEvent>()
        .listen(_onProfileChanged);

    // GPS-Permission Events hören (reaktiv!)
    _permissionGrantedSubscription = eventBus
        .on<LocationPermissionGrantedEvent>()
        .listen(_onPermissionGranted);
    _permissionDeniedSubscription = eventBus
        .on<LocationPermissionDeniedEvent>()
        .listen(_onPermissionDenied);

    // Cleanup alte Daten beim Start
    await _cleanupOldData();

    await _autoStartIfWanted();
  }

  /// Zieht den Berechtigungsstatus des GPS-Managers nach.
  ///
  /// Kommt die Berechtigung später als dieser Dienst, holt der Auto-Start das
  /// nach. Vorher hing er an einem Wert, der zu diesem Zeitpunkt noch nicht
  /// feststand — und blieb deshalb aus.
  void _onGpsPermissionChanged() {
    final hasPermission = gpsManager.hasGpsPermission.value;
    if (_hasLocationPermission.value == hasPermission) return;

    _hasLocationPermission.value = hasPermission;
    logger.info(
      LogCategory.service,
      'GPS-Permission Status geändert',
      data: {'hasPermission': hasPermission},
    );

    if (hasPermission) {
      unawaited(_autoStartIfWanted());
    }
  }

  /// Startet das Tracking, wenn es gewünscht und erlaubt ist.
  Future<void> _autoStartIfWanted() async {
    if (_isTrackingRunning.value) return;

    final savedTrackingEnabled =
        settingsBox.get(_wunschSchluessel, defaultValue: false) as bool;
    final globalTrackingEnabled =
        settingsBox.get('global_tracking_always_on', defaultValue: false)
            as bool;

    if (!(savedTrackingEnabled || globalTrackingEnabled) ||
        !_hasLocationPermission.value) {
      logger.info(
        LogCategory.service,
        'GPS-Tracking bleibt pausiert',
        data: {
          'savedStatus': savedTrackingEnabled,
          'globalTracking': globalTrackingEnabled,
          'hasPermission': _hasLocationPermission.value,
        },
      );
      return;
    }

    logger.info(
      LogCategory.service,
      globalTrackingEnabled
          ? '🔄 Auto-Start GPS-Tracking (Globales Tracking aktiviert)'
          : '🔄 Auto-Start GPS-Tracking (letzter gespeicherter Status: aktiviert)',
    );

    try {
      await startTracking();
    } catch (e) {
      logger.error(
        LogCategory.service,
        'Fehler beim Auto-Start des GPS-Trackings',
        data: {'error': e.toString()},
      );
    }
  }

  /// Dispose (Cleanup)
  Future<void> dispose() async {
    await _stopTracking();
    gpsManager.hasGpsPermission.removeListener(_onGpsPermissionChanged);
    await _profileSwitchSubscription?.cancel();
    await _permissionGrantedSubscription?.cancel();
    await _permissionDeniedSubscription?.cancel();
    _isTrackingRunning.dispose();
    _hasLocationPermission.dispose();
    _lastUpdate.dispose();
  }

  /// Startet GPS-Tracking
  ///
  /// [askForPermission] entscheidet, ob der Systemdialog erscheinen darf.
  /// Ohne ihn scheitert der Start bei fehlender Berechtigung stumm — genau
  /// das passierte beim Satellitensymbol in der Kopfzeile: Es meldete
  /// „Berechtigung verweigert", ohne je gefragt zu haben, und ließ keinen
  /// Weg offen, das zu ändern.
  Future<void> startTracking({bool askForPermission = false}) async {
    if (_isTrackingRunning.value) {
      logger.info(LogCategory.service, 'Tracking bereits aktiv');
      return;
    }

    final position = await gpsManager.getUserPosition(
      askIfDenied: askForPermission,
    );
    final hasPermission = position != null;
    _hasLocationPermission.value = hasPermission; // Update permission state

    if (!hasPermission) {
      logger.warning(
        LogCategory.service,
        'GPS-Permission verweigert oder Position nicht verfügbar',
      );
      throw Exception('GPS-Permission nicht erteilt');
    }

    logger.info(LogCategory.service, 'Starte GPS-Tracking');

    // Der Wunsch, nicht der Laufzustand: Diese Zeile sagt „aufzeichnen", und
    // sie bleibt stehen, auch wenn der Strom später abbricht. Sonst wäre nach
    // einer Störung das Wiederanlaufen beim nächsten Start unmöglich.
    await settingsBox.put(_wunschSchluessel, true);

    // Die erste Position sofort, ohne auf den Takt zu warten.
    await _recordPosition(position);

    final l10n = AppTexts.current;

    // Derselbe Wunsch, aber an einem Ort, den ein Broadcast-Empfänger lesen
    // kann. Nach einem Geräteneustart läuft die Aufzeichnung nicht von allein
    // an — der Dienst dürfte aus dem Hintergrund gar nicht messen. Statt still
    // auszufallen, steht dann eine Meldung da. Siehe [TrackingBootNotice].
    unawaited(
      TrackingBootNotice.merken(
        titel: l10n.trackingPausedTitle,
        text: l10n.trackingPausedBody,
      ),
    );
    _positionSubscription = gpsManager
        .positionStream(
          notificationTitle: l10n.locationTrackingNotificationTitle,
          notificationText: l10n.locationTrackingNotificationBody,
          // Ausgeschrieben, obwohl es gerade dem Standard des Pakets
          // entspricht: Ändert das Paket seinen Standard, ändert sich sonst
          // lautlos, wie oft Aurora aufzeichnet. Das ist die eine Zahl, die
          // darüber entscheidet, ob „wo war ich?" nach einem Blackout eine
          // Antwort hat.
          // ignore: avoid_redundant_argument_values
          interval: _trackingInterval,
          distanceFilterMeters: _minDistanceMeters.round(),
        )
        .listen(
          _recordPosition,
          onError: (Object error, StackTrace stackTrace) {
            // GPS abgeschaltet, Berechtigung entzogen, Dienst gestorben:
            // Der Laufzustand kippt, der Wunsch bleibt. Beim nächsten Start
            // versucht Aurora es wieder — hier den Wunsch mit zu löschen
            // hieße, die Aufzeichnung still und dauerhaft aufzugeben.
            logger.error(
              LogCategory.service,
              'GPS-Strom abgebrochen — Aufzeichnung pausiert',
              data: {'error': error.toString()},
              stackTrace: stackTrace,
            );
            _isTrackingRunning.value = false;
            unawaited(_cancelStream());
          },
        );

    // Erst jetzt läuft es. Die Zeile stand vorher weiter oben, vor dem
    // Schreiben des Wunsches und vor dem Strom — warf eine der Zeilen
    // dazwischen, meldete die Oberfläche „aktiv" ohne jedes Abonnement. Und
    // weil die Einstellungen seit demselben Umbau den Laufzustand fragen,
    // hätten sie danach den Neustart verweigert: dieselbe Verwechslung wie
    // vorher, nur andersherum.
    _isTrackingRunning.value = true;
  }

  /// Beendet den Strom und damit auf Android den Vordergrunddienst.
  ///
  /// Getrennt von [_stopTracking], weil es zwei verschiedene Dinge sind: Hier
  /// hört die Aufzeichnung auf zu laufen, dort hört jemand auf, sie zu wollen.
  Future<void> _cancelStream() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastPosition = null;
  }

  /// Stoppt GPS-Tracking, weil jemand es so will.
  Future<void> _stopTracking() async {
    logger.info(LogCategory.service, 'Stoppe GPS-Tracking');
    _isTrackingRunning.value = false;

    // Hier darf der Wunsch mit weg — es war eine Entscheidung.
    await settingsBox.put(_wunschSchluessel, false);
    await TrackingBootNotice.vergessen();

    await _cancelStream();
  }

  /// Toggle Tracking An/Aus
  /// [askForPermission] gehört zu einer Handlung der Nutzerin: Wer den
  /// Schalter drückt, will gefragt werden. Der Auto-Start beim App-Start
  /// fragt nicht — dort wäre der Systemdialog ungebeten.
  Future<void> toggleTracking({bool askForPermission = false}) async {
    if (_isTrackingRunning.value) {
      await _stopTracking();
    } else {
      await startTracking(askForPermission: askForPermission);
    }
  }

  /// Zeichnet eine Position auf (nur wenn Bewegung >50m).
  ///
  /// Die Position kommt jetzt von außen — aus dem Strom des
  /// Vordergrunddienstes oder als erste Messung beim Start. Vorher holte
  /// diese Methode sie selbst; das ging nur, solange sie von einem Timer im
  /// App-Prozess gerufen wurde.
  Future<void> _recordPosition(LatLng newPosition) async {
    if (_currentProfileId == null) {
      logger.warning(
        LogCategory.service,
        'Kein aktives Profil - Skip Location Recording',
      );
      return;
    }

    try {
      // Zweite Schranke neben dem `distanceFilter` des Systems: Der ist je
      // nach Hersteller großzügig, und GPS-Rauschen im Stand hat schon
      // Wege erfunden, die niemand gegangen ist.
      if (_lastPosition != null) {
        final distance = const Distance().as(
          LengthUnit.Meter,
          _lastPosition!,
          newPosition,
        );

        if (distance < _minDistanceMeters) {
          logger.info(
            LogCategory.service,
            'Position unverändert (${distance.toStringAsFixed(1)}m) - Skip',
          );
          return;
        }

        logger.info(
          LogCategory.service,
          'Bewegung erkannt: ${distance.toStringAsFixed(1)}m',
        );
      }

      // Reverse Geocoding: Adresse abrufen (optional, kann fehlschlagen)
      String? address;
      try {
        address = await geocodingService.reverseGeocode(newPosition);
        if (address != null) {
          logger.info(
            LogCategory.service,
            'Adresse aufgelöst: $address',
          );
        }
      } catch (e) {
        logger.warning(
          LogCategory.service,
          'Reverse Geocoding fehlgeschlagen (OK, netzwerkabhängig)',
          data: {'error': e.toString()},
        );
        // Adresse bleibt null - das ist OK
      }

      final entry = LocationHistoryEntry(
        id: const Uuid().v4(),
        profileId: _currentProfileId!,
        latitude: newPosition.latitude,
        longitude: newPosition.longitude,
        timestamp: DateTime.now(),
        address: address,
      );

      await locationHistoryBox.put(entry.id, entry);
      _lastPosition = newPosition; // Cache für nächsten Check
      _lastUpdate.value = DateTime.now();

      logger.info(
        LogCategory.service,
        'GPS-Position aufgezeichnet',
        data: {
          'profileId': _currentProfileId,
          'lat': newPosition.latitude.toStringAsFixed(4),
          'lng': newPosition.longitude.toStringAsFixed(4),
          'hasAddress': address != null,
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Fehler beim Aufzeichnen der GPS-Position',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Handler für Profil-Wechsel Events
  Future<void> _onProfileChanged(ActiveProfileChangedEvent event) async {
    final previousProfileId = _currentProfileId;
    _currentProfileId = event.profile.id;

    // Tracking nur wenn aktiviert
    if (!_isTrackingRunning.value) {
      logger.info(
        LogCategory.service,
        'Profil-Wechsel erkannt, aber Tracking ist deaktiviert',
      );
      return;
    }

    try {
      // Aktuelle GPS-Position abrufen (optional)
      final location = await gpsManager.getUserPosition();

      final switchEvent = ProfileSwitchEvent(
        id: const Uuid().v4(),
        fromProfileId: previousProfileId,
        toProfileId: event.profile.id,
        timestamp: DateTime.now(),
        latitude: location?.latitude,
        longitude: location?.longitude,
      );

      await switchEventsBox.put(switchEvent.id, switchEvent);

      logger.info(
        LogCategory.service,
        'Profil-Wechsel aufgezeichnet',
        data: {
          'from': previousProfileId ?? 'App-Start',
          'to': event.profile.id,
          'hasLocation': location != null,
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Fehler beim Aufzeichnen des Profil-Wechsels',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Event Handler: GPS-Permission wurde erteilt
  Future<void> _onPermissionGranted(
    LocationPermissionGrantedEvent event,
  ) async {
    logger.info(
      LogCategory.service,
      '✅ GPS-Permission GRANTED Event empfangen',
    );
    _hasLocationPermission.value = true;

    // Auto-Start Tracking (wenn nicht schon aktiv)
    if (!_isTrackingRunning.value) {
      logger.info(
        LogCategory.service,
        '🚀 Auto-Start GPS-Tracking (Permission wurde erteilt)',
      );
      try {
        await startTracking();
      } catch (e) {
        logger.error(
          LogCategory.service,
          'Fehler beim Auto-Start des GPS-Trackings',
          data: {'error': e.toString()},
        );
      }
    }
  }

  /// Event Handler: GPS-Permission wurde verweigert
  void _onPermissionDenied(LocationPermissionDeniedEvent event) {
    logger.info(
      LogCategory.service,
      '❌ GPS-Permission DENIED Event empfangen - Footer wird aktualisiert',
    );
    _hasLocationPermission.value = false;
  }

  /// Holt Location-History für einen Zeitraum
  List<LocationHistoryEntry> getHistory({
    required DateTime start,
    required DateTime end,
    String? profileId,
  }) {
    final entries = locationHistoryBox.values.where((entry) {
      final inTimeRange =
          entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
      final matchesProfile = profileId == null || entry.profileId == profileId;
      return inTimeRange && matchesProfile;
    }).toList();

    // Sortiere chronologisch
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }

  /// Holt Switch-Events für einen Zeitraum
  List<ProfileSwitchEvent> getSwitchEvents({
    required DateTime start,
    required DateTime end,
  }) {
    final events = switchEventsBox.values.where((event) {
      return event.timestamp.isAfter(start) && event.timestamp.isBefore(end);
    }).toList();

    // Sortiere chronologisch
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return events;
  }

  /// Holt die letzte bekannte Position aus dem Cache
  ///
  /// Gibt die neuste LocationHistoryEntry zurück, sortiert nach Timestamp.
  /// Nützlich für Maps die die aktuelle Position anzeigen wollen ohne Live-GPS.
  ///
  /// Returns null wenn keine History vorhanden ist.
  LocationHistoryEntry? getLastKnownPosition({String? profileId}) {
    if (locationHistoryBox.isEmpty) return null;

    var entries = locationHistoryBox.values.toList();

    // Filtere nach Profil wenn angegeben
    if (profileId != null) {
      entries = entries.where((e) => e.profileId == profileId).toList();
    }

    if (entries.isEmpty) return null;

    // Sortiere nach Timestamp (neueste zuerst)
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.first;
  }

  /// Cleanup: Löscht Daten älter als X Tage
  Future<void> _cleanupOldData() async {
    logger.info(
      LogCategory.service,
      'Starte Auto-Cleanup (älter als $_dataRetentionDays Tage)',
    );

    var deletedLocations = 0;
    var deletedSwitches = 0;

    // LocationHistory cleanup
    final locationKeys = locationHistoryBox.keys.toList();
    for (final key in locationKeys) {
      final entry = locationHistoryBox.get(key);
      if (entry != null && entry.isOlderThan(_dataRetentionDays)) {
        await locationHistoryBox.delete(key);
        deletedLocations++;
      }
    }

    // SwitchEvents cleanup
    final switchKeys = switchEventsBox.keys.toList();
    for (final key in switchKeys) {
      final event = switchEventsBox.get(key);
      if (event != null && event.isOlderThan(_dataRetentionDays)) {
        await switchEventsBox.delete(key);
        deletedSwitches++;
      }
    }

    logger.info(
      LogCategory.service,
      'Auto-Cleanup abgeschlossen',
      data: {
        'deletedLocations': deletedLocations,
        'deletedSwitches': deletedSwitches,
      },
    );
  }

  /// Manuelles Cleanup (für Settings-Screen)
  Future<void> clearAllData() async {
    logger.warning(
      LogCategory.service,
      'Lösche ALLE Tracking-Daten',
    );

    await locationHistoryBox.clear();
    await switchEventsBox.clear();
    _lastUpdate.value = null;
  }
}
