import 'package:dis_app/widgets/contact_avatar.dart';
import 'package:flutter/material.dart';

/// Map-Marker für Kontakte (dreieckig)
///
/// **Wrapper um `ContactAvatar`** für Map-spezifische Verwendung
///
/// Verwendet für:
/// - Kontakte mit GPS-Koordinaten auf der Karte
///
/// **Features:**
/// - Nutzt `ContactAvatar` (dreieckig, Rainbow-Initialen)
/// - Map-spezifische Defaults (size, border, shadow)
class MapMarkerContact extends StatelessWidget {
  const MapMarkerContact({
    required this.imagePath,
    required this.name,
    super.key,
    this.size = 50,
    this.borderColor = Colors.white,
    this.borderWidth = 3,
    this.fallbackColor,
  });

  final String? imagePath;
  final String name;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    return ContactAvatar(
      imagePath: imagePath,
      name: name,
      size: size,
      borderColor: borderColor,
      borderWidth: borderWidth,
      fallbackColor: fallbackColor,
    );
  }
}
