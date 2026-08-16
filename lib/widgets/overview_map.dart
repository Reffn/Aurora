import 'dart:async';
import 'dart:math' as math;

import 'package:dis_app/constants/netz_kennung.dart';
import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/models/finder_item.dart';
import 'package:dis_app/models/location_history_entry.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/models/profile_switch_event.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/location_tracking_service.dart';
import 'package:dis_app/services/map_service.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/position_age.dart';
import 'package:dis_app/widgets/map_marker_avatar.dart';
import 'package:dis_app/widgets/map_marker_contact.dart';
import 'package:dis_app/widgets/map_marker_location.dart';
import 'package:dis_app/widgets/map_marker_profile_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

/// Marker-Typ für Tap-Callbacks
enum MarkerType {
  userLocation,
  finderLocation,
  contact,
  profileSwitch,
}

/// GPS-Status für User-Feedback
enum GpsStatus {
  active,
  disabled,
  permissionDenied,
  permissionDeniedForever,
  loading,
  error,
}

/// Welche Punkte des Wegs eine Zeit bekommen.
///
/// Ein Weg ohne Zeiten sagt nur, dass jemand dort war. Die Frage ist aber,
/// *wann*: Ob die Person vor zwanzig Minuten am Supermarkt stand oder vor zwei
/// Tagen, entscheidet, ob man dort nach ihr sieht.
///
/// Nicht jeder Punkt bekommt eine. Der Verlauf zeichnet alle paar Minuten auf;
/// die Beschriftungen lägen übereinander und keine wäre lesbar — derselbe
/// Fehler, der die Marken am Zeitstrang unlesbar gemacht hat.
///
/// Beschriftet wird, wer weit genug von *allen* schon beschrifteten Punkten
/// entfernt liegt. Der Abstand zum jeweils letzten allein genügt nicht: Wer
/// hin und zurück denselben Weg geht, läuft an seinen eigenen Zeiten vorbei,
/// und die des Rückwegs lägen genau auf denen des Hinwegs.
///
/// [newestFirst] muss absteigend nach Zeit sortiert sein, so wie
/// [OverviewMap.historyPath]. Dadurch gewinnt bei einem doppelt begangenen Ort
/// die jüngere Zeit — sie ist die, nach der gefragt wird.
///
/// [keepClear] ist die aktuelle Position. Um sie herum bleibt es frei, weil
/// dort schon der Standort-Marker steht; eine Zeit daneben verdeckte ihn und
/// sagte nichts, was der Marker nicht schon sagt.
///
/// Der Abstand wächst mit dem Weg. Ein fester Meterwert reicht nicht: Die
/// Karte zoomt sich auf den Weg, also sind hundert Meter bei einem Gang um den
/// Block eine halbe Bildbreite und bei einer Fahrt durch die Stadt vierzig
/// Pixel. Beim ersten Versuch lagen deshalb fünf Zeiten übereinander.
/// [minMeters] ist nur noch die Untergrenze für sehr kurze Wege.
///
/// Was dabei verloren geht: Wer denselben Ort nach Stunden erneut besucht,
/// sieht dort nur die jüngere Zeit. Der Ort ist bekannt, der Weg dorthin
/// gezeichnet — die frühere Zeit stünde direkt auf der späteren und wäre so
/// oder so nicht lesbar.
List<LocationHistoryEntry> pathTimeLabelPoints(
  List<LocationHistoryEntry> newestFirst, {
  LatLng? keepClear,
  double minMeters = 120,
  int maxLabels = 4,
}) {
  const distance = Distance();
  // Die Weglänge geteilt durch die Zahl der Zeiten, die auf die Karte passen.
  // Bei einem Drittel lag der Wert genau auf dem Abstand zweier
  // Aufzeichnungen: Ein Rundungsunterschied von zwei Metern entschied dann
  // zwischen drei Zeiten und einer einzigen.
  final separation = math.max(minMeters, _pathSpread(newestFirst) / maxLabels);
  final taken = <LatLng>[if (keepClear != null) keepClear];
  final picked = <LocationHistoryEntry>[];

  for (final entry in newestFirst) {
    final at = LatLng(entry.latitude, entry.longitude);
    if (taken.any((other) => distance(other, at) < separation)) continue;
    taken.add(at);
    picked.add(entry);
  }
  return picked;
}

/// Die Diagonale des Wegs in Metern — so groß ist der Kartenausschnitt.
double _pathSpread(List<LocationHistoryEntry> points) {
  if (points.length < 2) return 0;
  var minLat = points.first.latitude;
  var maxLat = minLat;
  var minLon = points.first.longitude;
  var maxLon = minLon;
  for (final point in points) {
    minLat = math.min(minLat, point.latitude);
    maxLat = math.max(maxLat, point.latitude);
    minLon = math.min(minLon, point.longitude);
    maxLon = math.max(maxLon, point.longitude);
  }
  return const Distance()(LatLng(minLat, minLon), LatLng(maxLat, maxLon));
}

/// Wiederverwendbares Karten-Widget für Übersichtsdarstellungen
///
/// **Features:**
/// - Live GPS-Tracking (optional)
/// - Finder-Orte anzeigen
/// - Kontakte mit GPS anzeigen
/// - Timeline-Pfad zeichnen
/// - Profil-Wechsel Marker
/// - Zoom Controls (optional)
/// - GPS-Status Banner (optional)
/// - Interactive Mode (Marker setzen per Tap)
class OverviewMap extends StatefulWidget {
  const OverviewMap({
    super.key,
    this.showUserLocation = true,
    this.showPermissionBanner = true,
    this.showFinderLocations = false,
    this.showContacts = false,
    this.height = 250,
    this.historyPath,
    this.switchEvents,
    this.finderLocations,
    this.contacts,
    this.enableLiveTracking = false,
    this.onMarkerTap,
    this.initialZoom = 13,
    this.initialCenter,
    this.interactive = false,
    this.onMapTap,
    this.customMarkers,
    this.showZoomControls = false,
    this.showLocationButton = false,
    this.showGpsStatus = false,
    this.centerOnUser = false,
    this.externalController,
    this.pathColorOf,
    this.destination,
    this.destinationLabel,
  });

  /// Wohin es als Nächstes geht.
  ///
  /// Gezeichnet wird eine Luftlinie von der aktuellen Position dorthin, keine
  /// Route. Eine Route müsste einen fremden Dienst fragen, und dabei verließen
  /// beide Punkte das Gerät — Start *und* Ziel, also der ganze Weg eines
  /// Menschen. Die Luftlinie sagt Richtung und ungefähre Entfernung; das ist
  /// die Auskunft, um die es beim Hochkommen geht.
  final LatLng? destination;

  /// Der Name des Ziels, wie er am Punkt steht.
  final String? destinationLabel;

  /// Zeige aktuelle User-Position
  final bool showUserLocation;

  /// Ob die Karte ihr eigenes Band „GPS-Berechtigung erforderlich" zeigt.
  ///
  /// Aus, wo die umgebende Fläche den Fall schon erklärt. In der Zeitkarte
  /// lagen sonst zwei Bitten um dieselbe Sache übereinander — das Band der
  /// Karte samt orangem Knopf, und darüber die Zeile „Aurora braucht den
  /// Standort für diese Karte". Der Text der einen lief mitten durch den Knopf
  /// der anderen. Zweimal fragen macht die Antwort nicht leichter.
  final bool showPermissionBanner;

  /// Zeige Finder-Orte
  final bool showFinderLocations;

  /// Zeige Kontakte mit GPS
  final bool showContacts;

  /// Höhe des Karten-Widgets
  final double height;

  /// Timeline-Bewegungspfad (optional)
  final List<LocationHistoryEntry>? historyPath;

  /// Profil-Wechsel Events (optional)
  final List<ProfileSwitchEvent>? switchEvents;

  /// Finder-Locations Liste (wenn nicht aus DataEntry geholt werden soll)
  final List<FinderItem>? finderLocations;

  /// Kontakte Liste (wenn nicht aus DataEntry geholt werden soll)
  final List<Contact>? contacts;

  /// Live GPS-Tracking aktivieren (kontinuierlich aktualisieren)
  final bool enableLiveTracking;

  /// Callback wenn Marker getappt wird
  final void Function(MarkerType type, String id)? onMarkerTap;

  /// Initial Zoom-Level
  final double initialZoom;

  /// Initial Center (falls null, wird automatisch berechnet)
  final LatLng? initialCenter;

  /// Interaktive Karte (Marker setzen per Tap)
  final bool interactive;

  /// Callback bei Map-Tap (nur wenn interactive: true)
  final void Function(LatLng)? onMapTap;

  /// Zusätzliche Custom Marker (für spezielle Use-Cases wie MapPicker)
  final List<Marker>? customMarkers;

  /// Zeige Zoom Controls (+ / - Buttons)
  final bool showZoomControls;

  /// Zeige "Meine Position" Button
  final bool showLocationButton;

  /// Zeige GPS-Status Banner
  final bool showGpsStatus;

  /// Zentriere Map auf User-Position mit dynamischem Zoom
  /// Zoom-Level wird basierend auf Distanz zu initialCenter berechnet
  final bool centerOnUser;

  /// Externer MapController (optional)
  final MapController? externalController;

  /// Die Farbe eines Anteils, für Weg und Punkte.
  ///
  /// Ohne sie ist der Weg einfarbig — er zeigt dann, wo der Körper war, aber
  /// nicht, wer ihn dorthin gebracht hat.
  final Color Function(String profileId)? pathColorOf;

  @override
  State<OverviewMap> createState() => _OverviewMapState();
}

class _OverviewMapState extends State<OverviewMap> {
  final mapService = getIt<MapService>();
  final gpsManager = getIt<GpsManager>();
  late final DataEntry _dataEntry;
  late final MapController _mapController;

  LatLng? _userLocation;
  Timer? _liveTrackingTimer;
  bool _permissionDenied = false;

  /// Ob die Hand gerade die Karte hält.
  ///
  /// Solange nicht gepant wurde, ist der eigene Standort das Zentrum und
  /// die Karte zieht mit jeder neuen Position nach. Nach dem ersten
  /// eigenen Griff bleibt sie stehen — wer sich umsieht, dem darf die
  /// Karte nicht unter den Fingern wegspringen. Der „Meine Position"-Knopf
  /// holt das Nachführen zurück.
  bool _userPanned = false;

  /// Wie alt die angezeigte Position ist, falls sie aus dem Speicher kommt.
  ///
  /// `null` heißt: gerade gemessen. Auf der Notfallkarte ist der Unterschied
  /// der wichtigste auf dem Schirm.
  Duration? _locationAge;

  // Neue State-Variablen
  late double _currentZoom;
  GpsStatus? _gpsStatus;

  // Stabiles Map-Center (wird nur einmal berechnet, nicht bei jedem rebuild)
  late LatLng _initialMapCenter;

  // KRITISCH: GlobalKey für _StableMapContainer damit Flutter das Widget nicht disposed
  final GlobalKey _mapContainerKey = GlobalKey();

  // GPS Loading State
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();
    _currentZoom = widget.initialZoom;
    _mapController = widget.externalController ?? MapController();

    // Initial center: widget.initialCenter > Fallback Berlin
    // (Wird später auf _userLocation updated wenn GPS verfügbar)
    _initialMapCenter = widget.initialCenter ?? const LatLng(52.52, 13.405);

    _initializeMap();
  }

  @override
  void didUpdateWidget(OverviewMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Wenn historyPath Daten hat, nutze neueste Position als User Location
    if (widget.historyPath != null && widget.historyPath!.isNotEmpty) {
      final latestEntry =
          widget.historyPath!.first; // Bereits sortiert (neueste zuerst)
      final newLocation = LatLng(latestEntry.latitude, latestEntry.longitude);

      // Nur updaten wenn sich Position geändert hat
      if (_userLocation == null ||
          _userLocation!.latitude != newLocation.latitude ||
          _userLocation!.longitude != newLocation.longitude) {
        if (mounted) {
          setState(() {
            _userLocation = newLocation;
          });
          _followUser(newLocation);

          logger.debug(
            LogCategory.ui,
            '🗺️ MAP: User location updated from historyPath',
            data: {
              'lat': newLocation.latitude,
              'lng': newLocation.longitude,
              'formatted': gpsManager.formatPosition(newLocation),
            },
          );
        }
      }
    }
  }

  /// Zieht die Karte auf die neue Position nach, solange niemand pant.
  ///
  /// Vor dem ersten Frame hat der Controller noch keine Karte — dann trägt
  /// [_initialMapCenter] das Zentrum und der Fehlgriff bleibt folgenlos.
  void _followUser(LatLng location) {
    if (_userPanned) return;
    try {
      _mapController.move(location, _mapController.camera.zoom);
    } catch (_) {
      // Karte noch nicht bereit; das Initial-Zentrum übernimmt.
    }
  }

  @override
  void dispose() {
    _liveTrackingTimer?.cancel();
    // Nur disposen wenn interner Controller
    if (widget.externalController == null) {
      _mapController.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeMap() async {
    // GPS-Status checken (wenn Banner aktiviert)
    if (widget.showGpsStatus) {
      await _checkGpsStatus();
    }

    if (widget.showUserLocation || widget.enableLiveTracking) {
      if (mounted) {
        setState(() => _isLoadingGps = true);
      }

      await _updateUserLocation();

      if (mounted) {
        setState(() => _isLoadingGps = false);
      }

      if (widget.enableLiveTracking && mounted) {
        // Live-Tracking alle 5-10 Sekunden
        _liveTrackingTimer = Timer.periodic(
          const Duration(seconds: 8),
          (_) => _updateUserLocation(),
        );
      }
    }
  }

  /// GPS-Status ermitteln (via GPS Manager)
  Future<void> _checkGpsStatus() async {
    if (!mounted) return;

    setState(() => _gpsStatus = GpsStatus.loading);

    try {
      // Service & Permission Status vom GPS Manager
      final serviceEnabled = gpsManager.isGpsServiceEnabled.value;
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _gpsStatus = GpsStatus.disabled);
        }
        return;
      }

      final hasPermission = gpsManager.hasGpsPermission.value;
      if (!hasPermission) {
        if (mounted) {
          setState(() => _gpsStatus = GpsStatus.permissionDenied);
        }
        return;
      }

      // GPS aktiv!
      if (mounted) {
        setState(() => _gpsStatus = GpsStatus.active);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _gpsStatus = GpsStatus.error);
      }
    }
  }

  /// Holt die Position für die Karte.
  ///
  /// [askIfDenied] darf **nur** gesetzt sein, wenn ein Mensch gerade etwas
  /// angetippt hat. Beim Aufbau der Karte ist es aus, und das ist der Punkt:
  /// Diese Karte steckt auch in Übersichtsflächen, die niemand als Karte
  /// aufgerufen hat. Vorher fragte jede von ihnen beim Erscheinen nach dem
  /// Standort — am 8. August 2026 sprang der Systemdialog direkt nach dem
  /// Anlegen des ersten Profils auf, und nach dem Ablehnen beim Betreten des
  /// Profils gleich wieder.
  ///
  /// Wer den Standort will, greift danach: der „Mein Standort"-Knopf oder
  /// „Berechtigung erteilen" im Hinweisband. Beide fragen, alles andere nicht.
  Future<void> _updateUserLocation({bool askIfDenied = false}) async {
    final callId = DateTime.now().millisecondsSinceEpoch;
    logger.debug(
      LogCategory.ui,
      '🗺️ MAP: _updateUserLocation() ENTRY',
      data: {
        'callId': callId,
        'currentPermissionDenied': _permissionDenied,
        'currentUserLocation': _userLocation?.toString() ?? 'null',
        'centerOnUser': widget.centerOnUser,
      },
    );

    try {
      LatLng? location;

      // Strategie: Erst Cache prüfen, dann Live-GPS
      final trackingService = getIt<LocationTrackingService>();
      final lastKnown = trackingService.getLastKnownPosition();

      // Ist die angezeigte Position live oder aus dem Speicher? Das entschied
      // hier bisher nichts — und genau daran hing der Fehler auf der
      // Notfallkarte: Eine gespeicherte Position wurde als „aktiv" ausgegeben,
      // während der Hinweis darüber „Standort verweigert" sagte. Im Notfall
      // ist eine alte Position, die sich für eine aktuelle ausgibt,
      // gefährlicher als gar keine.
      Duration? age;

      if (lastKnown != null) {
        // Cache verfügbar - nutze letzte bekannte Position (sofort!)
        location = LatLng(lastKnown.latitude, lastKnown.longitude);
        age = DateTime.now().difference(lastKnown.timestamp);
        logger.info(
          LogCategory.ui,
          '🗺️ MAP: Using cached position from LocationTrackingService',
          data: {
            'lat': location.latitude,
            'lng': location.longitude,
            'age': age.inMinutes,
          },
        );
      } else {
        // Kein Cache - fallback auf Live-GPS
        logger.debug(
          LogCategory.ui,
          '🗺️ MAP: No cached position, falling back to live GPS',
        );
        // Gefragt wird nur, wenn jemand danach gegriffen hat.
        location = await gpsManager.getUserPosition(askIfDenied: askIfDenied);
      }
      if (location != null && mounted) {
        logger.info(
          LogCategory.ui,
          '🗺️ MAP: User location updated successfully',
          data: {
            'lat': location.latitude,
            'lng': location.longitude,
            'formatted': gpsManager.formatPosition(location),
          },
        );

        setState(() {
          _userLocation = location;
          _locationAge = age;

          // Die Wahrheit steht beim GPS-Manager, nicht in der Annahme, dass
          // eine vorhandene Position auch eine Erlaubnis bedeutet.
          _permissionDenied = !gpsManager.hasGpsPermission.value;

          if (widget.showGpsStatus) {
            // „Aktiv" nur, wenn die Position gerade gemessen wurde. Eine
            // gespeicherte Position ist ein Anhaltspunkt, kein Standort.
            _gpsStatus = _permissionDenied
                ? GpsStatus.permissionDenied
                : GpsStatus.active;
          }

          // Update initial center wenn wir zum ersten Mal GPS bekommen
          // (nur wenn kein explizites initialCenter vom widget gesetzt wurde)
          if (widget.initialCenter == null &&
              _initialMapCenter.latitude == 52.52 &&
              _initialMapCenter.longitude == 13.405) {
            _initialMapCenter = location!;
            logger.debug(
              LogCategory.ui,
              '🗺️ MAP: Initial map center updated to user location',
            );
          }
        });

        // Nachführen: Der eigene Standort bleibt das Zentrum, bis die Hand
        // die Karte übernimmt. Der centerOnUser-Zweig darunter rechnet den
        // Zoom selbst und braucht das nicht doppelt.
        if (!(widget.centerOnUser && widget.initialCenter != null)) {
          _followUser(location);
        }

        // Auto-center auf User mit dynamischem Zoom basierend auf Distanz
        if (widget.centerOnUser && widget.initialCenter != null) {
          try {
            logger.debug(
              LogCategory.ui,
              '🗺️ MAP: Starting auto-center calculation',
              data: {
                'callId': callId,
                'userLat': location.latitude,
                'userLng': location.longitude,
                'targetLat': widget.initialCenter!.latitude,
                'targetLng': widget.initialCenter!.longitude,
              },
            );

            final distance = gpsManager.calculateDistance(
              location,
              widget.initialCenter!,
            );

            logger.debug(
              LogCategory.ui,
              '🗺️ MAP: Distance calculated',
              data: {'callId': callId, 'distanceMeters': distance.round()},
            );

            // Zoom basierend auf Distanz
            double zoom;
            if (distance < 100) {
              zoom = 17;
            } else if (distance < 250) {
              zoom = 16;
            } else if (distance < 500) {
              zoom = 15;
            } else if (distance < 1000) {
              zoom = 14;
            } else if (distance < 2000) {
              zoom = 13;
            } else if (distance < 5000) {
              zoom = 12;
            } else {
              zoom = 11;
            }

            logger.info(
              LogCategory.ui,
              '🗺️ MAP: Auto-centering on user with dynamic zoom',
              data: {
                'callId': callId,
                'distanceMeters': distance.round(),
                'calculatedZoom': zoom,
                'userPosition': gpsManager.formatPosition(location),
                'targetPosition': gpsManager.formatPosition(
                  widget.initialCenter!,
                ),
              },
            );

            logger.debug(
              LogCategory.ui,
              '🗺️ MAP: Calling _mapController.move()',
              data: {'callId': callId},
            );

            // Map auf User-Position bewegen mit berechnetem Zoom
            _mapController.move(location, zoom);

            logger.debug(
              LogCategory.ui,
              '🗺️ MAP: _mapController.move() SUCCESS',
              data: {'callId': callId},
            );

            setState(() => _currentZoom = zoom);

            logger.debug(
              LogCategory.ui,
              '🗺️ MAP: setState() SUCCESS - zoom updated',
              data: {'callId': callId, 'newZoom': zoom},
            );
          } catch (e, stackTrace) {
            logger.error(
              LogCategory.ui,
              '🗺️ MAP: Auto-center FAILED',
              data: {
                'callId': callId,
                'error': e.toString(),
                'stackTrace': stackTrace.toString(),
              },
            );
          }
        }
      } else if (location == null) {
        logger.warning(
          LogCategory.ui,
          '🗺️ MAP: getCurrentLocation() returned null',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          if (widget.showGpsStatus) {
            _gpsStatus = GpsStatus.error;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.debug(
      LogCategory.ui,
      'OverviewMap.build() called - STABLE VERSION (no TileLayer rebuild)',
      data: {
        '_permissionDenied': _permissionDenied,
        '_userLocation': _userLocation?.toString() ?? 'null',
        '_isLoadingGps': _isLoadingGps,
        '_initialMapCenter': _initialMapCenter.toString(),
      },
    );

    // Check if we need user location at all
    final needsUserLocation =
        widget.showUserLocation || widget.enableLiveTracking;

    // If we don't need user location, show map directly
    if (!needsUserLocation) {
      logger.debug(
        LogCategory.ui,
        'OverviewMap: User location not needed, showing map directly',
      );
      return _buildStableMapWithReactiveMarkers();
    }

    // We need user location - use reactive permission checking
    final trackingService = getIt<LocationTrackingService>();

    return ValueListenableBuilder<bool>(
      valueListenable: trackingService.hasLocationPermission,
      builder: (context, hasPermission, _) {
        logger.debug(
          LogCategory.ui,
          'OverviewMap: Permission state from LocationTrackingService',
          data: {
            'hasPermission': hasPermission,
            '_isLoadingGps': _isLoadingGps,
            '_userLocation': _userLocation?.toString() ?? 'null',
          },
        );

        // GPS lädt noch
        if (_isLoadingGps && _userLocation == null) {
          logger.debug(
            LogCategory.ui,
            'OverviewMap: GPS is loading...',
          );
          return _buildLoadingGpsBanner();
        }

        // GPS-Berechtigung verweigert
        if (!hasPermission) {
          if (!widget.showPermissionBanner) {
            // Die umgebende Fläche sagt es selbst — siehe
            // [OverviewMap.showPermissionBanner].
            return const SizedBox.shrink();
          }
          logger.debug(
            LogCategory.ui,
            'OverviewMap: GPS permission denied - showing banner',
          );
          return _buildPermissionDeniedBanner();
        }

        // Permission granted but location not yet loaded
        if (_userLocation == null) {
          logger.debug(
            LogCategory.ui,
            'OverviewMap: Permission granted but location still loading',
          );
          return _buildLoadingGpsBanner();
        }

        logger.info(
          LogCategory.ui,
          'OverviewMap: Building STABLE map (TileLayer will NOT rebuild)',
        );

        // Stabile Map mit nur reaktiver MarkerLayer
        return _buildStableMapWithReactiveMarkers();
      },
    );
  }

  /// Baut stabile Map mit nur reaktiver MarkerLayer
  ///
  /// **WICHTIG:** Verwendet _StableMapContainer Widget das nur einmal erstellt wird.
  /// Dadurch bleibt TileLayer stabil und wird nicht bei jedem rebuild disposed.
  Widget _buildStableMapWithReactiveMarkers() {
    logger.info(
      LogCategory.ui,
      '🗺️ MAP: Building StableMapContainer',
      data: {
        'mapCenter_lat': _initialMapCenter.latitude,
        'mapCenter_lng': _initialMapCenter.longitude,
        'mapCenter_formatted': gpsManager.formatPosition(_initialMapCenter),
        'zoom': _currentZoom,
        'height': widget.height,
        'showUserLocation': widget.showUserLocation,
        'showContacts': widget.showContacts,
        'showFinderLocations': widget.showFinderLocations,
        'userLocation': _userLocation != null
            ? '${_userLocation!.latitude},${_userLocation!.longitude}'
            : 'null',
        'customMarkersCount': widget.customMarkers?.length ?? 0,
      },
    );

    return _StableMapContainer(
      key:
          _mapContainerKey, // KRITISCH: Verhindert dass Flutter das Widget disposed!
      height: widget.height,
      mapController: _mapController,
      initialCenter: _initialMapCenter,
      initialZoom: _currentZoom,
      interactive: widget.interactive,
      onMapTap: widget.onMapTap,
      historyPath: widget.historyPath,
      buildPathTimeLabelLayer:
          widget.historyPath != null && widget.historyPath!.isNotEmpty
          ? buildPathTimeLabelLayer
          : null,
      buildDestinationLayers: buildDestinationLayers,
      buildHistoryPath:
          widget.historyPath != null && widget.historyPath!.isNotEmpty
          ? _buildHistoryPath
          : null,
      buildReactiveMarkerLayer: _buildReactiveMarkerLayer,
      showZoomControls: widget.showZoomControls,
      showLocationButton: widget.showLocationButton,
      showGpsStatus: widget.showGpsStatus,
      buildZoomControls: _buildZoomControls,
      buildLocationButton: _buildLocationButton,
      buildGpsStatusBanner: _buildGpsStatusBanner,
      onUserGesture: () => _userPanned = true,
    );
  }

  /// Baut MarkerLayer aus übergebenen Daten
  ///
  /// Die Karte wird von außen mit Daten versorgt. Die TileLayer bleibt
  /// stabil und lädt weiter Tiles — nur die Marker werden neu gebaut, wenn
  /// sich die übergebenen Listen ändern.
  ///
  /// Diese Änderung (10.08.2026) erzwingt, dass jede Aufrufstelle selbst
  /// nachlädt, wenn sich Daten ändern. Das ist überwunden; kein Widgettest
  /// kann darunter leiden, dass die Karte sich Hive selbst öffnet.
  Widget _buildReactiveMarkerLayer() {
    // Daten laden.
    //
    // [OverviewMap.showContacts] und [OverviewMap.showFinderLocations]
    // standen vorher nur im Log und blieben ohne Wirkung: Kontakte und
    // Orte erschienen auf jeder Karte, die dieses Widget benutzt. Bei
    // Kontakten ist das die Adresse eines anderen Menschen — die
    // Profilauswahl schaltet sie ausdrücklich ab, und genau dort war
    // sie an.
    final allContacts = widget.showContacts
        ? (widget.contacts ?? <Contact>[])
              .where(
                (Contact c) => c.latitude != null && c.longitude != null,
              )
              .toList()
        : <Contact>[];

    final allFinderLocations = widget.showFinderLocations
        ? (widget.finderLocations ?? <FinderItem>[])
              .where(
                (FinderItem i) =>
                    i.type == FinderItemType.location &&
                    i.latitude != null &&
                    i.longitude != null,
              )
              .toList()
        : <FinderItem>[];

    final markers = _buildMarkers(allContacts, allFinderLocations);

    logger.debug(
      LogCategory.ui,
      'OverviewMap: MarkerLayer rebuilt',
      data: {
        'contactsWithGPS': allContacts.length,
        'finderLocations': allFinderLocations.length,
        'totalMarkers': markers.length,
        'showContacts': widget.showContacts,
        'showFinderLocations': widget.showFinderLocations,
      },
    );

    // Nur MarkerLayer wird neu gebaut, TileLayer bleibt stabil!
    return MarkerLayer(markers: markers);
  }

  /// Baut Timeline-Bewegungspfad
  /// Der zurückgelegte Weg: erst die Linie, dann die Punkte darauf.
  ///
  /// Bis hierher zeichnete diese Methode nur rote Punkte — eine Streuung
  /// ohne Richtung. Eine Linie sagt, wo es langging und in welcher
  /// Reihenfolge; Punkte allein sagen nur, dass man irgendwo war.
  ///
  /// Die Linie ist abschnittsweise eingefärbt: Jeder Abschnitt trägt die
  /// Farbe des Anteils, der ihn gegangen ist. So beantwortet der Weg
  /// dieselbe Frage wie die Marken darüber — wer war wo — ohne ein Wort.
  ///
  /// Unter der farbigen Linie liegt eine weiße Fassung. Ohne sie
  /// verschwindet ein dunkler Anteilsfarbton auf einer Straße und ein heller
  /// auf einer Wiese; Kartenkacheln haben jede Helligkeit im Angebot.
  List<Widget> _buildHistoryPath() {
    // Sortiere nach Timestamp (neueste zuerst)
    final sortedHistory = widget.historyPath!.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final line = sortedHistory.reversed
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();

    final segments = <Polyline>[];
    if (line.length > 1) {
      segments.add(
        Polyline(
          points: line,
          strokeWidth: 7,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      );
      final chronological = sortedHistory.reversed.toList();
      for (var i = 0; i < chronological.length - 1; i++) {
        final owner = chronological[i].profileId;
        segments.add(
          Polyline(
            points: [line[i], line[i + 1]],
            strokeWidth: 4,
            color: widget.pathColorOf?.call(owner) ?? const Color(0xFF3949AB),
          ),
        );
      }
    }

    // Skip erste Position (= aktuelle, wird als Avatar mit showUserLocation angezeigt)
    // Alle anderen Positionen als kleine rote Punkte
    final oldPositions = widget.showUserLocation && sortedHistory.length > 1
        ? sortedHistory.skip(1).toList()
        : sortedHistory;

    final markers = oldPositions
        .map(
          (entry) => Marker(
            point: LatLng(entry.latitude, entry.longitude),
            width: 14,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Der Punkt trägt die Farbe des Anteils, der dort war —
                // nicht mehr ein einheitliches Rot, das nur „hier war
                // jemand" sagen konnte.
                color: (widget.pathColorOf?.call(entry.profileId) ?? Colors.red)
                    .withValues(alpha: 0.85),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();

    return [
      if (segments.isNotEmpty) PolylineLayer(polylines: segments),
      MarkerLayer(markers: markers),
    ];
  }

  /// Die Punkte des Wegs ohne den jüngsten.
  ///
  /// Der jüngste ist die aktuelle Position und trägt schon den Standort-Marker;
  /// ein zweiter Punkt darunter wäre dieselbe Auskunft zweimal.
  List<LocationHistoryEntry> get _oldPositions {
    final sorted =
        (widget.historyPath ?? const <LocationHistoryEntry>[]).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return widget.showUserLocation && sorted.length > 1
        ? sorted.skip(1).toList()
        : sorted;
  }

  /// Das Ziel und die Luftlinie dorthin.
  ///
  /// Gestrichelt, weil die Linie kein Weg ist: Sie sagt „dort entlang, so
  /// weit", nicht „hier gehst du". Eine durchgezogene Linie wäre dieselbe
  /// Zeichnung wie der zurückgelegte Weg und behauptete damit dasselbe.
  List<Widget> buildDestinationLayers() {
    final target = widget.destination;
    if (target == null) return const [];

    return [
      if (_userLocation != null)
        PolylineLayer(
          polylines: [
            // Dunkle Fassung zuerst. Ohne sie ging die helle Linie auf
            // hellgrauen Straßenkacheln unter — derselbe Fehler wie beim Weg,
            // dessen weißer Kern in der weißen Fassung verschwand. Kacheln
            // haben jede Helligkeit im Angebot, also braucht jede Linie hier
            // zwei.
            Polyline(
              points: [_userLocation!, target],
              strokeWidth: 6,
              color: Colors.black.withValues(alpha: 0.55),
              pattern: StrokePattern.dashed(segments: const [10, 8]),
            ),
            Polyline(
              points: [_userLocation!, target],
              strokeWidth: 3,
              color: AppColors.paper,
              pattern: StrokePattern.dashed(segments: const [10, 8]),
            ),
          ],
        ),
      MarkerLayer(
        markers: [
          Marker(
            point: target,
            width: 120,
            height: 62,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.ink,
                    border: Border.all(
                      color: AppColors.paper,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.event,
                    size: 16,
                    color: AppColors.paper,
                  ),
                ),
                if (widget.destinationLabel != null) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.destinationLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ];
  }

  /// Die Zeiten am Weg als eigene Ebene.
  ///
  /// Eigen, weil ihr Platz im Stapel festliegt: über Wechseln, Orten und
  /// Kontakten, unter dem Standort. Lägen sie bei den Wegpunkten, zeichnete
  /// jede Marke darüber sie zu — genau das war am Gerät zu sehen.
  Widget buildPathTimeLabelLayer() {
    return MarkerLayer(markers: _pathTimeLabels(_oldPositions));
  }

  /// Wann jemand wo war — die Zeiten am Weg.
  ///
  /// Die Zeit steht relativ da („vor 20 Minuten"), nicht als Uhrzeit. Wer
  /// nach Stunden wieder vorn ist, müsste aus „14:20" erst ausrechnen, wie
  /// lange das her ist — und weiß dafür oft nicht, wie spät es gerade ist.
  List<Marker> _pathTimeLabels(List<LocationHistoryEntry> newestFirst) {
    final now = DateTime.now();

    final labels = <Marker>[];
    // Zwei Blasen mit demselben Wort sagen zweimal dasselbe. Die Zeitangabe
    // ist bewusst grob gerundet — zwei Punkte vierzig Minuten auseinander
    // heißen beide „vor einer Stunde". Dann bleibt die jüngere stehen.
    final gesagt = <String>{};
    // Wie viele Zeiten die Karte trägt, hängt daran, wie hoch sie ist. Oben
    // und unten liegt je ein Zeitstrang, dazwischen bleibt der Rest; eine
    // Zeitblase samt Abstand braucht rund sechzig Punkte davon. Auf der
    // Ankerfläche mit 180 Punkten sind das zwei, auf der Chronologie vier —
    // vorher standen dort überall vier, und auf der kleinen Karte lagen sie
    // auf den Wechselmarken.
    final points = pathTimeLabelPoints(
      newestFirst,
      keepClear: widget.showUserLocation ? _userLocation : null,
      maxLabels: ((widget.height - 60) / 60).clamp(2, 4).round(),
    );
    for (final entry in points) {
      final text = formatPositionAge(now.difference(entry.timestamp));
      if (!gesagt.add(text)) continue;
      labels.add(
        Marker(
          point: LatLng(entry.latitude, entry.longitude),
          // Breit genug für „il y a une heure et demie": Der Marker begrenzt
          // nur, die Blase schrumpft auf ihren Text. Zu eng gefasst stand hier
          // „il y a 54 minut…" — eine abgeschnittene Zeit ist keine.
          width: 190,
          height: 32,
          // Die Zeit sitzt über ihrem Punkt, nicht auf ihm: Der Punkt trägt
          // die Farbe des Anteils, und die soll sichtbar bleiben.
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return labels;
  }

  /// Wer an der aktuellen Position steht.
  ///
  /// Hier stand vorher immer der aktive Anteil — und wo keiner aktiv ist, das
  /// Wort „Unbekannt". Auf der Profilauswahl ist genau das der Normalfall,
  /// und „Unbekannt" unter dem eigenen Standort ist keine Auskunft, sondern
  /// eine Beunruhigung: Es liest sich, als wüsste die App nicht, wo man ist.
  ///
  /// Die Position stammt entweder aus dem Verlauf — dann gehört sie dem
  /// Anteil, der sie aufgezeichnet hat — oder frisch vom GPS, dann dem, der
  /// gerade vorn ist. Löst keins von beidem auf, bleibt es unbeschriftet.
  Profile? _userLocationOwner() {
    final history = widget.historyPath;
    if (history != null && history.isNotEmpty) {
      final recorder = _dataEntry.profilesBox.get(history.first.profileId);
      if (recorder != null) return recorder;
    }
    return _dataEntry.getActiveProfile();
  }

  /// Baut die Marker, die auf der Karte liegen — ohne den Standort.
  ///
  /// Die Reihenfolge ist die Rangfolge: Was später in die Liste kommt, liegt
  /// oben. Zuunterst die Wechselpunkte — wer wann vorn war, steht bereits im
  /// Zeitstrang, der Punkt ergänzt allein das Wo. Darüber die eigenen Orte,
  /// darüber die Kontakte, denn ein Mensch in Reichweite wiegt schwerer als
  /// ein Ort. Standort und Zeiten liegen in eigenen Ebenen darüber.
  ///
  /// Vorher stand hier keine Rangfolge, sondern die Reihenfolge, in der die
  /// Blöcke geschrieben wurden — und die weiße Wechselmarke lag zuoberst auf
  /// allem anderen.
  List<Marker> _buildMarkers(
    List<Contact> allContacts,
    List<FinderItem> allFinderLocations,
  ) {
    final markers = <Marker>[];

    // Profile-Switch Marker (überlappende Avatare)
    if (widget.switchEvents != null) {
      for (final event in widget.switchEvents!) {
        if (event.latitude != null && event.longitude != null) {
          // Lade From- und To-Profile
          final fromProfile = event.fromProfileId != null
              ? _dataEntry.profilesBox.get(event.fromProfileId)
              : null;
          final toProfile = _dataEntry.profilesBox.get(event.toProfileId);

          // Skip wenn To-Profile nicht existiert
          if (toProfile == null) continue;

          markers.add(
            Marker(
              point: LatLng(event.latitude!, event.longitude!),
              child: GestureDetector(
                onTap: () => widget.onMarkerTap?.call(
                  MarkerType.profileSwitch,
                  event.id,
                ),
                child: MapMarkerProfileSwitch(
                  fromAvatarPath: fromProfile?.avatarPath,
                  fromProfileName: fromProfile?.name ?? '?',
                  fromProfileColor:
                      fromProfile?.preferredColor ?? Colors.grey.shade400,
                  toAvatarPath: toProfile.avatarPath,
                  toProfileName: toProfile.name,
                  toProfileColor: toProfile.preferredColor,
                ),
              ),
            ),
          );
        }
      }
    }

    // User-Location Marker (blau, pulsierend, mit Namen-Label)
    //
    // Er wird hier gebaut, aber am Ende der Liste wieder angehängt: Er
    // beantwortet die Frage, die zuerst kommt, und muss obenauf liegen.
    final userMarkerAt = markers.length;
    var hasUserMarker = false;
    if (_userLocation != null && widget.showUserLocation) {
      final owner = _userLocationOwner();
      logger.debug(
        LogCategory.ui,
        '🗺️ MAP: Creating User Location Marker',
        data: {
          'lat': _userLocation!.latitude,
          'lng': _userLocation!.longitude,
          'formatted': gpsManager.formatPosition(_userLocation!),
          'profileName': owner?.name,
        },
      );
      markers.add(
        Marker(
          point: _userLocation!,
          width: 80,
          height: owner == null ? 34 : 60,
          child: GestureDetector(
            onTap: () =>
                widget.onMarkerTap?.call(MarkerType.userLocation, 'current'),
            // Ohne Anteil bleibt der Punkt und die Beschriftung fällt weg.
            // Ein Kreis sagt „hier"; das ist wahr, auch wenn niemand
            // angemeldet ist. Ein Avatar mit Namen darunter wäre eine
            // Behauptung darüber, wer dort steht.
            //
            // Mit Anteil trägt der Avatar allein — Farbe und Bild sind die
            // Marke. Ein Namensschild darunter sagte dasselbe noch einmal in
            // Worten und stand doppelt zum Namen in der Kopfzeile.
            child: owner == null
                ? Center(
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3949AB),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: MapMarkerAvatar(
                      avatarPath: owner.avatarPath,
                      profileName: owner.name,
                      profileColor: owner.preferredColor,
                      enablePulsing: true,
                    ),
                  ),
          ),
        ),
      );
      hasUserMarker = true;
    }

    // Finder-Locations Marker (Viereck mit Bild/Initialen)
    for (final item in allFinderLocations) {
      logger.debug(
        LogCategory.ui,
        '🗺️ MAP: Creating Finder Location Marker',
        data: {
          'id': item.id,
          'title': item.title,
          'lat': item.latitude,
          'lng': item.longitude,
          'formatted': gpsManager.formatCoordinates(
            item.latitude!,
            item.longitude!,
          ),
          'hasImage': item.imagePath != null,
        },
      );
      markers.add(
        Marker(
          point: LatLng(item.latitude!, item.longitude!),
          width: 80,
          height: 90,
          child: GestureDetector(
            onTap: () => widget.onMarkerTap?.call(
              MarkerType.finderLocation,
              item.id,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quadratischer Marker mit Bild/Initialen
                MapMarkerLocation(
                  imagePath: item.imagePath,
                  title: item.title,
                ),
                const SizedBox(height: 4),
                // Name-Label mit Hintergrund
                Container(
                  constraints: const BoxConstraints(maxWidth: 80),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Contacts Marker (Avatar + Name)
    for (final contact in allContacts) {
      logger.debug(
        LogCategory.ui,
        '🗺️ MAP: Creating Contact Marker',
        data: {
          'id': contact.id,
          'name': contact.name,
          'lat': contact.latitude,
          'lng': contact.longitude,
          'formatted': gpsManager.formatCoordinates(
            contact.latitude!,
            contact.longitude!,
          ),
        },
      );
      markers.add(
        Marker(
          point: LatLng(contact.latitude!, contact.longitude!),
          width: 80,
          height: 90,
          child: GestureDetector(
            onTap: () =>
                widget.onMarkerTap?.call(MarkerType.contact, contact.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dreieckiger Marker mit Bild/Initialen
                MapMarkerContact(
                  imagePath: contact.imagePath,
                  name: contact.name,
                ),
                const SizedBox(height: 4),
                // Name-Label mit Hintergrund
                Container(
                  constraints: const BoxConstraints(maxWidth: 80),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    contact.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Der Standort ganz nach oben.
    if (hasUserMarker) markers.add(markers.removeAt(userMarkerAt));

    // Custom Markers (für spezielle Use-Cases wie MapPicker)
    if (widget.customMarkers != null) {
      logger.debug(
        LogCategory.ui,
        '🗺️ MAP: Adding Custom Markers',
        data: {
          'count': widget.customMarkers!.length,
          'positions': widget.customMarkers!.map((m) {
            return '${m.point.latitude},${m.point.longitude}';
          }).toList(),
        },
      );
      markers.addAll(widget.customMarkers!);
    }

    logger.info(
      LogCategory.ui,
      '🗺️ MAP: Total markers built',
      data: {'totalMarkers': markers.length},
    );

    return markers;
  }

  /// Zoom Controls (+ / - Buttons)
  Widget _buildZoomControls() {
    return Positioned(
      left: 16,
      top: widget.height * 0.5 - 60,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: 'zoom_in_${widget.key}',
            // Ohne Namen meldet Android diese Knöpfe als leere Schaltflächen.
            // Die Karte wird von Zeitachse und Notfall geteilt — der Name
            // wirkt deshalb an beiden Stellen.
            tooltip: AppLocalizations.of(context).mapZoomIn,
            backgroundColor: Colors.white,
            onPressed: () {
              setState(() {
                _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
              });
              _mapController.move(
                _mapController.camera.center,
                _currentZoom,
              );
            },
            child: Semantics(
              enabled: false,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_out_${widget.key}',
            tooltip: AppLocalizations.of(context).mapZoomOut,
            backgroundColor: Colors.white,
            onPressed: () {
              setState(() {
                _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
              });
              _mapController.move(
                _mapController.camera.center,
                _currentZoom,
              );
            },
            child: Semantics(
              enabled: false,
              child: const Icon(Icons.remove, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// Location Button ("Meine Position")
  Widget _buildLocationButton() {
    return Positioned(
      right: 16,
      bottom: widget.showGpsStatus ? 60 : 16,
      child: FloatingActionButton(
        heroTag: 'location_${widget.key}',
        tooltip: AppLocalizations.of(context).mapToMyLocation,
        backgroundColor: Colors.white,
        onPressed: () {
          // Der Griff zum Knopf ist die Bitte, wieder zu folgen.
          _userPanned = false;
          if (_userLocation != null) {
            setState(() => _currentZoom = 15.0);
            _mapController.move(_userLocation!, _currentZoom);
          } else {
            // Hier hat jemand gegriffen — hier darf gefragt werden.
            _updateUserLocation(askIfDenied: true);
          }
        },
        child: Semantics(
          enabled: false,
          child: Icon(
            Icons.my_location,
            color: _userLocation != null ? Colors.blue.shade700 : Colors.grey,
          ),
        ),
      ),
    );
  }

  /// GPS-Status Banner
  Widget _buildGpsStatusBanner() {
    final l10n = AppLocalizations.of(context);
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_gpsStatus) {
      case GpsStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.gps_fixed;
        statusText = l10n.gpsActive;
      case GpsStatus.loading:
        statusColor = Colors.blue;
        statusIcon = Icons.gps_not_fixed;
        statusText = l10n.mapGpsLoading;
      case GpsStatus.disabled:
        statusColor = Colors.orange;
        statusIcon = Icons.location_off;
        statusText = l10n.gpsOff;
      case GpsStatus.permissionDenied:
      case GpsStatus.permissionDeniedForever:
        statusColor = Colors.red;
        statusIcon = Icons.location_disabled;
        statusText = l10n.commonNoPermission;
      case GpsStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = l10n.gpsError;
      case null:
        statusColor = Colors.grey;
        statusIcon = Icons.gps_off;
        statusText = l10n.gpsStatusUnknown;
    }

    return Positioned(
      bottom: 16,
      left: 16,
      right: widget.showLocationButton ? 80 : 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGpsBanner() {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.mapGpsPositionLoading,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mapGpsPositionLoadingHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fragt die Berechtigung an — der Knopf sagt das, also muss er es tun.
  ///
  /// Vorher rief er `_updateUserLocation()`, und das nimmt bei vorhandener
  /// gespeicherter Position den Zwischenspeicher und fragt nie. Der Knopf
  /// „Berechtigung erteilen" führte damit zu nichts.
  Future<void> _requestPermission() async {
    final position = await gpsManager.getUserPosition(
      askIfDenied: true,
      forceRefresh: true,
    );

    if (!mounted) return;

    if (position != null) {
      setState(() {
        _userLocation = position;
        _locationAge = null;
        _permissionDenied = false;
        if (widget.showGpsStatus) {
          _gpsStatus = GpsStatus.active;
        }
      });
    } else {
      await _updateUserLocation(askIfDenied: true);
    }
  }

  Widget _buildPermissionDeniedBanner() {
    final l10n = AppLocalizations.of(context);
    return Container(
      // Mindesthöhe statt fester Höhe: Steht hier zusätzlich das Alter der
      // gespeicherten Position, passt der Text sonst nicht mehr hinein und
      // wird unten abgeschnitten — ausgerechnet der Satz, der im Notfall
      // zählt.
      constraints: BoxConstraints(minHeight: widget.height),
      // Ruhig, nicht orange.
      //
      // Richtlinie 4: Gesättigte Farbe ist reserviert für das, was im
      // schlechtesten Zustand gefunden werden muss. Eine Berechtigungsfrage
      // ist das nie. Auf der Notfall-Fläche war dieser Block das Auffälligste
      // — orange umrandet, mit vollflächig orangem Knopf —, und „Noch keine
      // Notfallkontakte" stand blass darunter. Der Blick ging zuerst auf eine
      // Systemfrage statt auf die Menschen, die helfen können.
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      // Rollbar, weil der Platz nicht immer reicht: Gibt der Einbettungsort
      // eine feste Höhe vor (die Zeitkarte: 220), läuft der Inhalt mit dem
      // Alters-Hinweis sonst unten über — genau der Satz, der zählt, wäre
      // abgeschnitten.
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: Colors.white.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).gpsPermissionRequired,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mapAllowLocation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              // Ohne Berechtigung kann eine gespeicherte Position auf der
              // Karte stehen. Wie alt sie ist, entscheidet, ob sie im Notfall
              // hilft oder in die Irre führt — also steht es dabei.
              if (_userLocation != null && _locationAge != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.mapLastKnownPosition(formatPositionAge(_locationAge!)),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange.shade200,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Umrissen statt vollflächig. Das Angebot bleibt sichtbar und
              // mit einem Griff erreichbar (Richtlinie 9: angeboten, nicht
              // aufgedrängt), ohne die lauteste Fläche des Schirms zu sein.
              OutlinedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.location_on),
                label: Text(AppLocalizations.of(context).permissionGrant),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.85),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stabile Map-Container die FlutterMap + TileLayer hostet
///
/// **Wichtig:** Eigenes StatefulWidget damit FlutterMap nur einmal erstellt wird
/// und nicht bei jedem Parent-Rebuild neu instantiiert wird.
/// Die TileLayer bleibt so stabil und kann Tiles laden ohne disposed zu werden.
class _StableMapContainer extends StatefulWidget {
  const _StableMapContainer({
    required this.height,
    required this.mapController,
    required this.initialCenter,
    required this.initialZoom,
    required this.interactive,
    required this.onMapTap,
    required this.historyPath,
    required this.buildHistoryPath,
    required this.buildPathTimeLabelLayer,
    required this.buildDestinationLayers,
    required this.buildReactiveMarkerLayer,
    required this.showZoomControls,
    required this.showLocationButton,
    required this.showGpsStatus,
    required this.buildZoomControls,
    required this.buildLocationButton,
    required this.buildGpsStatusBanner,
    this.onUserGesture,
    super.key,
  });

  /// Meldet die erste eigene Geste auf der Karte — sie beendet das
  /// Nachführen auf den Standort.
  final VoidCallback? onUserGesture;

  final double height;
  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final bool interactive;
  final void Function(LatLng)? onMapTap;
  final List<LocationHistoryEntry>? historyPath;
  final List<Widget> Function()? buildHistoryPath;

  /// Die Zeiten am Weg — eine eigene Ebene, damit sie über den Markern liegt.
  final Widget Function()? buildPathTimeLabelLayer;

  /// Ziel und Luftlinie dorthin.
  final List<Widget> Function() buildDestinationLayers;
  final Widget Function() buildReactiveMarkerLayer;
  final bool showZoomControls;
  final bool showLocationButton;
  final bool showGpsStatus;
  final Widget Function() buildZoomControls;
  final Widget Function() buildLocationButton;
  final Widget Function() buildGpsStatusBanner;

  @override
  State<_StableMapContainer> createState() => _StableMapContainerState();
}

class _StableMapContainerState extends State<_StableMapContainer> {
  @override
  void initState() {
    super.initState();
    logger.info(
      LogCategory.ui,
      '🎯 _StableMapContainer: CREATED (FlutterMap will be STABLE now!)',
      data: {
        'center':
            '${widget.initialCenter.latitude}, ${widget.initialCenter.longitude}',
        'zoom': widget.initialZoom,
      },
    );
  }

  @override
  void dispose() {
    logger.info(
      LogCategory.ui,
      '🎯 _StableMapContainer: DISPOSED',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.debug(
      LogCategory.ui,
      '🎯 _StableMapContainer.build() - FlutterMap stays STABLE',
    );

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Map (STABLE - wird nur einmal in initState erstellt!)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: widget.initialZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                onTap: widget.interactive && widget.onMapTap != null
                    ? (_, latLng) => widget.onMapTap!(latLng)
                    : null,
                // Nur echte Gesten zählen: Programmatisches Nachführen läuft
                // ebenfalls durch diesen Callback, würde sich mit hasGesture
                // aber nicht selbst als „Hand auf der Karte" melden.
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) widget.onUserGesture?.call();
                },
              ),
              children: [
                // Tile Layer (STABLE!) with FMTC v10 persistent caching
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // Nennt den Betreiber, nicht die Diagnose — siehe
                  // NetzKennung. Der Kachelserver sieht ohnehin schon, welchen
                  // Ausschnitt jemand ansieht; er muss nicht auch erfahren,
                  // warum.
                  userAgentPackageName: NetzKennung.kachelPaketName,
                  tileProvider: FMTCTileProvider(
                    stores: const {
                      'mapStore': BrowseStoreStrategy.readUpdateCreate,
                    },
                  ),
                  errorTileCallback: (tile, error, stackTrace) {
                    logger.error(
                      LogCategory.ui,
                      'OverviewMap: Tile loading ERROR',
                      data: {
                        'tile':
                            '${tile.coordinates.z}/${tile.coordinates.x}/${tile.coordinates.y}',
                        'error': error.toString(),
                        'stackTrace': stackTrace?.toString() ?? 'no stack',
                      },
                    );
                  },
                  tileBuilder: (context, tileWidget, tile) {
                    logger.debug(
                      LogCategory.ui,
                      '✅ Tile loaded',
                      data: {
                        'tile':
                            '${tile.coordinates.z}/${tile.coordinates.x}/${tile.coordinates.y}',
                      },
                    );
                    return tileWidget;
                  },
                ),

                // Timeline-Pfad (optional)
                if (widget.historyPath != null &&
                    widget.historyPath!.isNotEmpty &&
                    widget.buildHistoryPath != null)
                  ...widget.buildHistoryPath!(),

                // Marker Layer (REACTIVE)
                widget.buildReactiveMarkerLayer(),

                // Ziel und Luftlinie über den Markern: Wohin es geht, wiegt
                // schwerer als wo etwas steht.
                ...widget.buildDestinationLayers(),

                // Die Zeiten am Weg zuletzt, also zuoberst. Sie halten sich
                // von der aktuellen Position ohnehin fern, verdecken den
                // Standort-Marker also nicht.
                if (widget.historyPath != null &&
                    widget.historyPath!.isNotEmpty &&
                    widget.buildPathTimeLabelLayer != null)
                  widget.buildPathTimeLabelLayer!(),
              ],
            ),
          ),

          // Zoom Controls (optional)
          if (widget.showZoomControls) widget.buildZoomControls(),

          // Location Button (optional)
          if (widget.showLocationButton) widget.buildLocationButton(),

          // GPS-Status Banner (optional)
          if (widget.showGpsStatus) widget.buildGpsStatusBanner(),
        ],
      ),
    );
  }
}
