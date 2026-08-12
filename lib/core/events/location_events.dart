import 'package:dis_app/core/events/app_event.dart';

/// Event: GPS-Permission wurde erteilt
///
/// Wird gefeuert wenn der User GPS-Berechtigung erteilt hat.
/// LocationTrackingService hört auf dieses Event um seinen Status zu aktualisieren.
class LocationPermissionGrantedEvent extends AppEvent {
  LocationPermissionGrantedEvent();
}

/// Event: GPS-Permission wurde verweigert
///
/// Wird gefeuert wenn der User GPS-Berechtigung verweigert hat.
class LocationPermissionDeniedEvent extends AppEvent {
  LocationPermissionDeniedEvent();
}
