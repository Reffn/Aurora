import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Hexagonales Avatar-Widget für Kalender-Events
///
/// Universell verwendbar in:
/// - Event-Cards (`EventCard`)
/// - Kalender-Ansicht
/// - Timeline
/// - Map-Marker (via `MapMarkerEvent`)
///
/// **Features:**
/// - Hexagonale Form (ClipPath mit HexagonClipper)
/// - ProfileImageWidget mit Rainbow-Initialen Fallback
/// - Anpassbare Hintergrundfarbe (basierend auf Event-Farbe)
/// - White Border (anpassbar)
/// - Box Shadow
///
/// **Verwendung:**
/// ```dart
/// EventAvatar(
///   imagePath: event.imagePath,
///   title: event.title,
///   eventColor: event.color,
///   size: 50,
/// )
/// ```
class EventAvatar extends StatelessWidget {
  const EventAvatar({
    required this.imagePath,
    required this.title,
    required this.eventColor,
    super.key,
    this.size = 50,
    this.borderColor = Colors.white,
    this.borderWidth = 3,
    this.showShadow = true,
  });

  final String? imagePath;
  final String title;
  final Color eventColor;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Äußeres Hexagon (Border + Shadow)
          if (showShadow)
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: HexagonClipper(),
                child: Container(
                  width: size,
                  height: size,
                  color: borderColor,
                ),
              ),
            )
          else
            ClipPath(
              clipper: HexagonClipper(),
              child: Container(
                width: size,
                height: size,
                color: borderColor,
              ),
            ),
          // Inneres Hexagon (Content)
          Padding(
            padding: EdgeInsets.all(borderWidth),
            child: ClipPath(
              clipper: HexagonClipper(),
              child: SizedBox(
                width: size - (borderWidth * 2),
                height: size - (borderWidth * 2),
                child: ProfileImageWidget(
                  avatarPath: imagePath,
                  size: size - (borderWidth * 2),
                  profileName: title,
                  profileColor: eventColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Clipper für Hexagon-Form (6-Eck)
///
/// Erstellt reguläres Hexagon mit flacher Oberseite:
/// ```
///     ____
///    /    \
///   |      |
///    \____/
/// ```
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, 0) // Top center
      ..lineTo(w, h * 0.25) // Top right
      ..lineTo(w, h * 0.75) // Bottom right
      ..lineTo(w * 0.5, h) // Bottom center
      ..lineTo(0, h * 0.75) // Bottom left
      ..lineTo(0, h * 0.25) // Top left
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
