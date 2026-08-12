import 'dart:async';
import 'dart:io';

import 'package:dis_app/core/event_bus.dart';
import 'package:dis_app/core/events/location_events.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// GPS Manager - Zentrale autonome Position-Autorität
///
/// **Single Source of Truth für alle Location-Operationen:**
/// - User Position (mit Smart Caching)
/// - Contact/Finder Positions
/// - Distance Calculations
/// - Formatting (Coordinates, Distance)
/// - Maps Integration
/// - Autonomous Permission Management
/// - Reactive State (ValueNotifiers)
/// - Event Publishing (EventBus)
/// - Comprehensive Logging
///
/// **Die App fragt NUR nach Positionen. Alles andere passiert autonom!**
class GpsManager with WidgetsBindingObserver {
  GpsManager({
    required this.eventBus,
    required this.contactsBox,
    required this.finderItemsBox,
  }) {
    _initialize();
  }

  final EventBus eventBus;
  final Box<Contact> contactsBox;
  final Box<FinderItem> finderItemsBox;

  /// Wird gerufen, wenn ein Positionsabruf scheitert.
  ///
  /// Absichtlich ein Callback statt eines Dienstes im Konstruktor: Der
  /// GpsManager entsteht in der Dependency Injection lange vor der Telemetrie
  /// und soll nichts von ihr wissen. Wer hier zuhört, entscheidet die
  /// Verdrahtung — der GpsManager meldet nur, dass etwas schiefging.
  ///
  /// Was gemeldet wird, ist der bloße Umstand. Nie ein Fehlertext, nie ein
  /// Stacktrace und unter keinen Umständen Koordinaten.
  void Function()? onPositionFailed;

  // ===== REACTIVE STATE =====

  /// Hat die App GPS-Berechtigung?
  final ValueNotifier<bool> _hasGpsPermission = ValueNotifier(false);
  ValueListenable<bool> get hasGpsPermission => _hasGpsPermission;

  /// Detaillierter Permission-Status (für UI-Darstellung)
  final ValueNotifier<LocationPermission> _permissionStatus = ValueNotifier(
    LocationPermission.denied,
  );
  ValueListenable<LocationPermission> get permissionStatus => _permissionStatus;

  /// Hat die App "Always Allow" GPS-Berechtigung?
  bool get hasAlwaysPermission =>
      _permissionStatus.value == LocationPermission.always;

  /// Hat die App "While in Use" GPS-Berechtigung?
  bool get hasWhileInUsePermission =>
      _permissionStatus.value == LocationPermission.whileInUse;

  /// Reicht die Berechtigung für die dauerhafte Wegaufzeichnung?
  ///
  /// „Bei Nutzung erlauben" genügt. Die Aufzeichnung hängt an einem
  /// Foreground-Service vom Typ `location`, und der darf weitermessen, solange
  /// er gestartet wurde, während die App sichtbar war — auch wenn sie danach
  /// in den Hintergrund geht.
  ///
  /// Hier stand [hasAlwaysPermission]. Das war richtig, solange die
  /// Aufzeichnung an `ACCESS_BACKGROUND_LOCATION` hing. Seit dem Umbau auf den
  /// Vordergrunddienst ist die Berechtigung aus dem Manifest — und die alte
  /// Abfrage sperrte den Schalter für immer: Die Einstellungen zeigten
  /// „Nur während der Nutzung" gelb an und verlangten eine Freigabe, die es
  /// gar nicht mehr zu erteilen gibt.
  bool get hasTrackingPermission =>
      hasAlwaysPermission || hasWhileInUsePermission;

  /// Ist GPS-Service aktiviert (System-Level)?
  final ValueNotifier<bool> _isGpsServiceEnabled = ValueNotifier(false);
  ValueListenable<bool> get isGpsServiceEnabled => _isGpsServiceEnabled;

  /// Letzte bekannte User-Position (gecacht)
  final ValueNotifier<LatLng?> _userPosition = ValueNotifier(null);
  ValueListenable<LatLng?> get userPosition => _userPosition;

  /// Letztes GPS-Update
  final ValueNotifier<DateTime?> _lastGpsUpdate = ValueNotifier(null);
  ValueListenable<DateTime?> get lastGpsUpdate => _lastGpsUpdate;

  // ===== CACHING =====

  /// Cache-Gültigkeit für User-Position (30 Sekunden)
  static const _cacheValidDuration = Duration(seconds: 30);

  /// Timestamp der letzten User-Position
  DateTime? _userPositionTimestamp;

  // ===== INITIALIZATION =====

  Future<void> _initialize() async {
    logger.info(
      LogCategory.service,
      'GPS Manager: Initializing...',
    );

    // Register App Lifecycle Observer für Permission-Refresh
    WidgetsBinding.instance.addObserver(this);

    await _checkPermissionStatus();
    await _checkServiceStatus();

    logger.info(
      LogCategory.service,
      'GPS Manager: Ready',
      data: {
        'hasPermission': _hasGpsPermission.value,
        'serviceEnabled': _isGpsServiceEnabled.value,
      },
    );
  }

  /// Dispose: Cleanup
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Dispose ValueNotifiers
    _hasGpsPermission.dispose();
    _permissionStatus.dispose();
    _isGpsServiceEnabled.dispose();
    _userPosition.dispose();
    _lastGpsUpdate.dispose();

    logger.info(
      LogCategory.service,
      'GPS Manager: Disposed',
    );
  }

  /// Prüft initialen Permission-Status
  Future<void> _checkPermissionStatus() async {
    try {
      final permission = await Geolocator.checkPermission();

      // Update detailed permission status (reaktiv)
      _permissionStatus.value = permission;

      // Update boolean permission (legacy)
      _hasGpsPermission.value =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      logger.debug(
        LogCategory.service,
        'GPS Manager: Permission status updated',
        data: {
          'hasPermission': _hasGpsPermission.value,
          'detailedStatus': permission.toString(),
        },
      );
    } catch (e) {
      logger.error(
        LogCategory.service,
        'GPS Manager: Failed to check permission',
        data: {'error': e.toString()},
      );
    }
  }

  /// Prüft initialen Service-Status
  Future<void> _checkServiceStatus() async {
    try {
      _isGpsServiceEnabled.value = await Geolocator.isLocationServiceEnabled();

      logger.debug(
        LogCategory.service,
        'GPS Manager: Initial service status',
        data: {'serviceEnabled': _isGpsServiceEnabled.value},
      );
    } catch (e) {
      logger.error(
        LogCategory.service,
        'GPS Manager: Failed to check service status',
        data: {'error': e.toString()},
      );
    }
  }

  // ===== AUTONOMOUS PERMISSION MANAGEMENT =====

  /// INTERN: Stellt sicher dass Permission vorhanden ist
  ///
  /// - Prüft GPS Service Status
  /// - Prüft Permission Status
  /// - Publiziert Events
  /// - Updated Reactive State
  ///
  /// Fragt die Nutzerin **nur**, wenn [askIfDenied] gesetzt ist.
  ///
  /// Das autonome Nachfragen war der Grund, warum beim Blättern durch die
  /// Reiter immer wieder der Systemdialog aufsprang — auch im Tagebuch und in
  /// den Hilfsangeboten, die keinen Standort brauchen. Ein abgelehnter Dialog
  /// kam beim nächsten Reiter sofort wieder und blockierte die Navigation.
  ///
  /// Aurora fragt nach Standort nur dort, wo die Nutzerin eine Funktion
  /// aufruft, die ihn braucht — Karte, Entfernungen, Notfall. Nie nebenbei.
  /// Ein Strom von Positionen, der weiterläuft, wenn Aurora in den
  /// Hintergrund geht.
  ///
  /// Auf Android hängt daran ein **Vordergrunddienst**. Solange jemand
  /// zuhört, steht eine Benachrichtigung in der Leiste, und Android beendet
  /// den Prozess nicht mehr wegen Speicherdruck oder Doze.
  ///
  /// Vorher lief die Aufzeichnung an einem `Timer.periodic` im App-Prozess.
  /// Der stirbt, sobald die App weggewischt wird — die Einstellungen
  /// versprachen „funktioniert auch im Hintergrund", und niemand hatte je
  /// nachgemessen, ob das stimmt. Es stimmte nicht.
  ///
  /// Die Benachrichtigung ist dabei kein lästiges Beiwerk, sondern die
  /// Zusage in sichtbarer Form: Aufgezeichnet wird nur, solange sie steht.
  ///
  /// Titel und Text kommen von außen, damit sie in der Sprache des Anteils
  /// stehen — dieser Dienst kennt keine Oberfläche.
  Stream<LatLng> positionStream({
    required String notificationTitle,
    required String notificationText,
    Duration interval = const Duration(minutes: 2, seconds: 30),
    int distanceFilterMeters = 50,
  }) {
    final LocationSettings settings;
    if (Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
        intervalDuration: interval,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notificationTitle,
          notificationText: notificationText,
          enableWakeLock: true,
          notificationIcon: const AndroidResource(
            name: 'ic_launcher',
            defType: 'mipmap',
          ),
        ),
      );
    } else {
      // iOS bleibt beim bisherigen Verhalten. `allowBackgroundLocationUpdates`
      // ohne `UIBackgroundModes: location` in der Info.plist stürzt zur
      // Laufzeit ab; diese Runde gilt Android, und ein halbes Versprechen
      // wäre genau der Fehler, den sie behebt.
      settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      );
    }

    return Geolocator.getPositionStream(locationSettings: settings).map((p) {
      final latLng = LatLng(p.latitude, p.longitude);

      // Der Zwischenspeicher des Managers bleibt die eine Wahrheit über die
      // letzte bekannte Position — auch wenn sie aus dem Strom kommt.
      _userPosition.value = latLng;
      _userPositionTimestamp = DateTime.now();
      _lastGpsUpdate.value = DateTime.now();

      return latLng;
    });
  }

  Future<bool> _ensurePermission({bool askIfDenied = false}) async {
    // 1. Service Check
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _isGpsServiceEnabled.value = serviceEnabled;

    if (!serviceEnabled) {
      logger.warning(
        LogCategory.service,
        'GPS Manager: GPS Service deaktiviert',
      );
      return false;
    }

    // 2. Permission Check
    var permission = await Geolocator.checkPermission();

    // 3. Nachfragen nur, wenn der Aufruf von einer Nutzerhandlung ausgeht
    if (permission == LocationPermission.denied && askIfDenied) {
      logger.info(
        LogCategory.service,
        'GPS Manager: Requesting GPS permission...',
      );

      permission = await Geolocator.requestPermission();
    }

    final hasPermission =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    // 4. State & Events updaten
    final previousPermission = _hasGpsPermission.value;
    _hasGpsPermission.value = hasPermission;

    // Events nur bei Änderung publishen
    if (hasPermission && !previousPermission) {
      eventBus.publish(LocationPermissionGrantedEvent());
      logger.info(
        LogCategory.service,
        '✅ GPS Manager: Permission GRANTED',
      );
    } else if (!hasPermission && previousPermission) {
      eventBus.publish(LocationPermissionDeniedEvent());
      logger.warning(
        LogCategory.service,
        '❌ GPS Manager: Permission DENIED',
      );
    }

    return hasPermission;
  }

  // ===== USER POSITION =====

  /// PUBLIC API: User-Position abrufen
  ///
  /// **Features:**
  /// - Smart Caching (30s)
  /// - Autonomous Permission Handling
  /// - Reactive State Updates
  /// - Event Publishing
  /// - Comprehensive Logging
  ///
  /// **Die App fragt einfach nach Position - alles andere passiert autonom!**
  ///
  /// @param forceRefresh Cache ignorieren und frische Position holen
  /// @param askIfDenied Systemdialog zeigen, falls die Berechtigung fehlt.
  ///   Nur setzen, wenn der Aufruf direkt aus einer Nutzerhandlung stammt —
  ///   nicht aus einem `FutureBuilder`, der bei jedem Rebuild neu läuft.
  /// @returns GPS-Position oder null bei Fehler
  Future<LatLng?> getUserPosition({
    bool forceRefresh = false,
    bool askIfDenied = false,
  }) async {
    logger.debug(
      LogCategory.service,
      'GPS Manager: getUserPosition called',
      data: {'forceRefresh': forceRefresh},
    );

    // Cache-Check (wenn nicht force-refresh)
    if (!forceRefresh &&
        _userPosition.value != null &&
        _userPositionTimestamp != null) {
      final age = DateTime.now().difference(_userPositionTimestamp!);
      if (age < _cacheValidDuration) {
        logger.debug(
          LogCategory.service,
          'GPS Manager: Returning cached position',
          data: {'cacheAge': '${age.inSeconds}s'},
        );
        return _userPosition.value;
      } else {
        logger.debug(
          LogCategory.service,
          'GPS Manager: Cache expired',
          data: {'cacheAge': '${age.inSeconds}s'},
        );
      }
    }

    if (!await _ensurePermission(askIfDenied: askIfDenied)) {
      logger.warning(
        LogCategory.service,
        'GPS Manager: Cannot get position - no permission',
      );
      return null;
    }

    // Frische Position holen
    try {
      logger.info(
        LogCategory.service,
        'GPS Manager: Fetching fresh position...',
      );

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final latLng = LatLng(position.latitude, position.longitude);

      // Cache updaten
      _userPosition.value = latLng;
      _userPositionTimestamp = DateTime.now();
      _lastGpsUpdate.value = DateTime.now();

      logger.info(
        LogCategory.service,
        'GPS Manager: Position updated successfully',
        data: {
          'lat': position.latitude.toStringAsFixed(4),
          'lng': position.longitude.toStringAsFixed(4),
          'accuracy': '${position.accuracy.toStringAsFixed(1)}m',
          'formatted': formatCoordinates(position.latitude, position.longitude),
        },
      );

      return latLng;
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'GPS Manager: Failed to get position',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );

      onPositionFailed?.call();

      return null;
    }
  }

  // ===== CONTACT & FINDER POSITIONS =====

  /// PUBLIC API: Contact-Position abrufen
  ///
  /// @param contactId Contact ID
  /// @returns GPS-Position oder null wenn Contact nicht existiert oder keine GPS-Daten hat
  Future<LatLng?> getContactPosition(String contactId) async {
    logger.debug(
      LogCategory.service,
      'GPS Manager: getContactPosition',
      data: {'contactId': contactId},
    );

    final contact = contactsBox.get(contactId);
    if (contact == null) {
      logger.warning(
        LogCategory.service,
        'GPS Manager: Contact not found',
        data: {'contactId': contactId},
      );
      return null;
    }

    if (contact.latitude == null || contact.longitude == null) {
      logger.debug(
        LogCategory.service,
        'GPS Manager: Contact has no GPS data',
        data: {'contactId': contactId, 'name': contact.name},
      );
      return null;
    }

    final position = LatLng(contact.latitude!, contact.longitude!);

    logger.debug(
      LogCategory.service,
      'GPS Manager: Contact position resolved',
      data: {
        'contactId': contactId,
        'name': contact.name,
        'formatted': formatPosition(position),
      },
    );

    return position;
  }

  /// PUBLIC API: Finder-Position abrufen
  ///
  /// @param finderId Finder Item ID
  /// @returns GPS-Position oder null wenn Item nicht existiert oder keine GPS-Daten hat
  Future<LatLng?> getFinderPosition(String finderId) async {
    logger.debug(
      LogCategory.service,
      'GPS Manager: getFinderPosition',
      data: {'finderId': finderId},
    );

    final finder = finderItemsBox.get(finderId);
    if (finder == null) {
      logger.warning(
        LogCategory.service,
        'GPS Manager: Finder item not found',
        data: {'finderId': finderId},
      );
      return null;
    }

    if (finder.latitude == null || finder.longitude == null) {
      logger.debug(
        LogCategory.service,
        'GPS Manager: Finder has no GPS data',
        data: {'finderId': finderId, 'title': finder.title},
      );
      return null;
    }

    final position = LatLng(finder.latitude!, finder.longitude!);

    logger.debug(
      LogCategory.service,
      'GPS Manager: Finder position resolved',
      data: {
        'finderId': finderId,
        'title': finder.title,
        'formatted': formatPosition(position),
      },
    );

    return position;
  }

  /// PUBLIC API: Generische Position-Query mit EntityRef
  ///
  /// @param entity Entity-Referenz (User, Contact, Finder)
  /// @returns GPS-Position oder null
  Future<LatLng?> getPosition(EntityRef entity) async {
    switch (entity.type) {
      case EntityType.user:
        return getUserPosition();
      case EntityType.contact:
        return getContactPosition(entity.id!);
      case EntityType.finder:
        return getFinderPosition(entity.id!);
    }
  }

  /// PUBLIC API: Alle Contacts mit GPS-Daten
  List<Contact> getContactsWithGps() {
    final contacts = contactsBox.values
        .where((c) => c.latitude != null && c.longitude != null)
        .toList();

    logger.debug(
      LogCategory.service,
      'GPS Manager: getContactsWithGps',
      data: {'count': contacts.length},
    );

    return contacts;
  }

  /// PUBLIC API: Alle Finder-Items mit GPS-Daten
  List<FinderItem> getFinderItemsWithGps() {
    final items = finderItemsBox.values
        .where(
          (f) =>
              f.type == FinderItemType.location &&
              f.latitude != null &&
              f.longitude != null,
        )
        .toList();

    logger.debug(
      LogCategory.service,
      'GPS Manager: getFinderItemsWithGps',
      data: {'count': items.length},
    );

    return items;
  }

  // ===== DISTANCE CALCULATION =====

  /// PUBLIC API: Distanz zwischen zwei Entities berechnen
  ///
  /// @param from Start-Entity
  /// @param to Ziel-Entity
  /// @returns Distanz in Metern oder null bei Fehler
  Future<double?> getDistanceBetween(EntityRef from, EntityRef to) async {
    logger.debug(
      LogCategory.service,
      'GPS Manager: getDistanceBetween',
      data: {
        'from': '${from.type}${from.id != null ? ":${from.id}" : ""}',
        'to': '${to.type}${to.id != null ? ":${to.id}" : ""}',
      },
    );

    final fromPos = await getPosition(from);
    final toPos = await getPosition(to);

    if (fromPos == null || toPos == null) {
      logger.debug(
        LogCategory.service,
        'GPS Manager: Cannot calculate distance - position missing',
        data: {
          'fromPos': fromPos != null ? 'available' : 'null',
          'toPos': toPos != null ? 'available' : 'null',
        },
      );
      return null;
    }

    final distance = calculateDistance(fromPos, toPos);

    logger.info(
      LogCategory.service,
      'GPS Manager: Distance calculated',
      data: {
        'distanceMeters': distance.round(),
        'formatted': formatDistance(distance),
      },
    );

    return distance;
  }

  /// PUBLIC API: Distanz zwischen zwei Koordinaten berechnen
  ///
  /// @param from Start-Position
  /// @param to Ziel-Position
  /// @returns Distanz in Metern (Luftlinie)
  double calculateDistance(LatLng from, LatLng to) {
    return const Distance().as(LengthUnit.Meter, from, to);
  }

  // ===== FORMATTING =====

  /// PUBLIC API: Koordinaten formatieren
  ///
  /// @param lat Latitude
  /// @param lng Longitude
  /// @returns Formatiert: "52.5200° N, 13.4050° E"
  String formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    final latAbs = lat.abs().toStringAsFixed(4);
    final lngAbs = lng.abs().toStringAsFixed(4);
    return '$latAbs° $latDir, $lngAbs° $lngDir';
  }

  /// PUBLIC API: Position formatieren
  ///
  /// @param position GPS-Position
  /// @returns Formatiert: "52.5200° N, 13.4050° E"
  String formatPosition(LatLng position) {
    return formatCoordinates(position.latitude, position.longitude);
  }

  /// PUBLIC API: Distanz formatieren
  ///
  /// @param meters Distanz in Metern
  /// @returns Formatiert: "50 m" oder "1.2 km"
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${NumberFormat.decimalPattern().format(meters.round())} m';
    }
    // `toStringAsFixed` schreibt immer einen Punkt. In einer französischen
    // Oberfläche stand deshalb „1.3 km" — im Französischen wie im Deutschen
    // trennt ein Komma. NumberFormat nimmt die Sprache, die AppTextsBinding
    // an intl gegeben hat.
    final km = meters / 1000;
    final formatted = NumberFormat('#,##0.0').format(km);
    return '$formatted km';
  }

  // ===== MAPS INTEGRATION =====

  /// PUBLIC API: Entity in Maps-App öffnen
  ///
  /// @param entity Entity-Referenz
  /// @param label Optional: Label für Maps
  /// @returns true bei Erfolg
  Future<bool> openInMaps(EntityRef entity, {String? label}) async {
    logger.info(
      LogCategory.service,
      'GPS Manager: openInMaps',
      data: {'entity': '${entity.type}:${entity.id}', 'label': label},
    );

    final position = await getPosition(entity);
    if (position == null) {
      logger.warning(
        LogCategory.service,
        'GPS Manager: Cannot open Maps - no position',
      );
      return false;
    }

    return openInMapsWithPosition(position, label: label);
  }

  /// PUBLIC API: Position in Maps-App öffnen
  ///
  /// @param position GPS-Position
  /// @param label Optional: Label für Maps
  /// @returns true bei Erfolg
  Future<bool> openInMapsWithPosition(LatLng position, {String? label}) async {
    final query = label != null ? Uri.encodeComponent(label) : '';
    final url = Uri.parse(
      'https://maps.google.com/?q=${position.latitude},${position.longitude}($query)',
    );

    try {
      if (await canLaunchUrl(url)) {
        final success = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        logger.info(
          LogCategory.service,
          'GPS Manager: Maps opened',
          data: {'success': success, 'position': formatPosition(position)},
        );

        return success;
      }

      logger.warning(
        LogCategory.service,
        'GPS Manager: Cannot launch Maps URL',
      );
      return false;
    } catch (e) {
      logger.error(
        LogCategory.service,
        'GPS Manager: Failed to open Maps',
        data: {'error': e.toString()},
      );
      return false;
    }
  }

  /// PUBLIC API: Öffnet App-Einstellungen für GPS-Berechtigung
  ///
  /// @returns true wenn Einstellungen geöffnet wurden
  Future<bool> openLocationSettings() async {
    logger.info(
      LogCategory.service,
      'GPS Manager: Opening location settings...',
    );

    try {
      final opened = await Geolocator.openLocationSettings();

      logger.info(
        LogCategory.service,
        'GPS Manager: Location settings opened',
        data: {'success': opened},
      );

      return opened;
    } catch (e) {
      logger.error(
        LogCategory.service,
        'GPS Manager: Failed to open location settings',
        data: {'error': e.toString()},
      );
      return false;
    }
  }

  // ===== LIFECYCLE MANAGEMENT =====

  /// App Lifecycle Observer: Reagiert auf App-Resume
  ///
  /// Wenn User aus Android-Settings zurückkommt → Permission neu prüfen
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      logger.info(
        LogCategory.service,
        'GPS Manager: App resumed → Refreshing permission status',
      );

      // Permission-Status neu prüfen (async fire-and-forget)
      _refreshPermissionStatus();
    }
  }

  /// Refresh Permission & Service Status
  Future<void> _refreshPermissionStatus() async {
    await _checkPermissionStatus();
    await _checkServiceStatus();
  }

  /// PUBLIC API: Fragt den Berechtigungsstatus frisch beim System ab und
  /// meldet, ob die Wegaufzeichnung damit laufen darf.
  ///
  /// [hasTrackingPermission] liest den zwischengespeicherten Wert und genügt
  /// für Anzeigen. Wer daran eine Entscheidung aufhängt — Standortverfolgung
  /// starten oder nicht — braucht diese Methode: Kehrt die Nutzerin gerade aus
  /// den Systemeinstellungen zurück, läuft die Auffrischung beim Wiedereintritt
  /// nebenläufig und ist womöglich noch nicht durch.
  Future<bool> refreshAndCheckTrackingPermission() async {
    await _checkPermissionStatus();
    return hasTrackingPermission;
  }

  // ===== APP SETTINGS =====

  /// PUBLIC API: Öffnet App-Einstellungen für App-Permissions
  ///
  /// @returns true wenn Einstellungen geöffnet wurden
  Future<bool> openAppSettings() async {
    logger.info(
      LogCategory.service,
      'GPS Manager: Opening app settings...',
    );

    try {
      final opened = await Geolocator.openAppSettings();

      logger.info(
        LogCategory.service,
        'GPS Manager: App settings opened',
        data: {'success': opened},
      );

      return opened;
    } catch (e) {
      logger.error(
        LogCategory.service,
        'GPS Manager: Failed to open app settings',
        data: {'error': e.toString()},
      );
      return false;
    }
  }
}

// ===== ENTITY REFERENCE PATTERN =====

/// Referenz auf eine Position-Entity
///
/// Ermöglicht generische Position-Queries:
/// ```dart
/// gpsManager.getPosition(EntityRef.user());
/// gpsManager.getPosition(EntityRef.contact('contact-123'));
/// gpsManager.getDistanceBetween(
///   EntityRef.user(),
///   EntityRef.finder('finder-456'),
/// );
/// ```
@immutable
class EntityRef {
  /// User-Entity (aktuelle GPS-Position)
  const EntityRef.user() : type = EntityType.user, id = null;

  /// Contact-Entity
  const EntityRef.contact(String contactId)
    : type = EntityType.contact,
      id = contactId;

  /// Finder-Entity
  const EntityRef.finder(String finderId)
    : type = EntityType.finder,
      id = finderId;

  final EntityType type;
  final String? id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityRef &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => 'EntityRef(type: $type, id: $id)';
}

/// Entity-Typ für Position-Queries
enum EntityType {
  /// User-Position (aktuelle GPS-Position)
  user,

  /// Contact-Position (aus Contact-Model)
  contact,

  /// Finder-Position (aus FinderItem-Model)
  finder,
}
