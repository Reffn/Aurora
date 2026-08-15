import 'package:dis_app/widgets/location_avatar.dart';
import 'package:flutter/material.dart';

/// Map-Marker für Orte/Finder Items (quadratisch)
///
/// **Wrapper um `LocationAvatar`** für Map-spezifische Verwendung
///
/// Verwendet für:
/// - Finder Items (gespeicherte Orte) auf der Karte
///
/// **Features:**
/// - Nutzt `LocationAvatar` (quadratisch, Rainbow-Initialen)
/// - Map-spezifische Defaults (size, border, shadow)
class MapMarkerLocation extends StatelessWidget {
  const MapMarkerLocation({
    required this.imagePath,
    required this.title,
    super.key,
    this.size = 50,
    this.borderColor = Colors.white,
    this.borderWidth = 3,
    this.fallbackColor,
  });

  final String? imagePath;
  final String title;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    return LocationAvatar(
      imagePath: imagePath,
      title: title,
      size: size,
      borderColor: borderColor,
      borderWidth: borderWidth,
      fallbackColor: fallbackColor,
    );
  }
}
