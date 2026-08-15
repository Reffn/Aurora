import 'package:dis_app/widgets/event_avatar.dart';
import 'package:flutter/material.dart';

/// Map-Marker für Events (hexagonal/6-eckig)
///
/// **Wrapper um `EventAvatar`** für Map-spezifische Verwendung
///
/// Verwendet für:
/// - Kalender-Events mit GPS-Koordinaten auf der Karte
///
/// **Features:**
/// - Nutzt `EventAvatar` (hexagonal, Rainbow-Initialen)
/// - Map-spezifische Defaults (size, border, shadow)
class MapMarkerEvent extends StatelessWidget {
  const MapMarkerEvent({
    required this.imagePath,
    required this.title,
    required this.eventColor,
    super.key,
    this.size = 50,
    this.borderColor = Colors.white,
    this.borderWidth = 3,
  });

  final String? imagePath;
  final String title;
  final Color eventColor;
  final double size;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return EventAvatar(
      imagePath: imagePath,
      title: title,
      eventColor: eventColor,
      size: size,
      borderColor: borderColor,
      borderWidth: borderWidth,
    );
  }
}
