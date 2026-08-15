import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Quadratisches Avatar-Widget für Orte/Finder Items
///
/// Universell verwendbar in:
/// - Finder-Listen (`FinderItemCard`)
/// - Finder-Detailansicht
/// - Map-Marker (via `MapMarkerLocation`)
///
/// **Features:**
/// - Quadratische Form mit leicht abgerundeten Ecken (BorderRadius ~3)
/// - ProfileImageWidget mit Rainbow-Initialen Fallback
/// - Orange Hintergrund als Fallback (anpassbar)
/// - White Border (anpassbar)
/// - Box Shadow
///
/// **Verwendung:**
/// ```dart
/// LocationAvatar(
///   imagePath: item.imagePath,
///   title: item.title,
///   size: 60,
///   fallbackColor: Colors.orange.shade600,
/// )
/// ```
class LocationAvatar extends StatelessWidget {
  const LocationAvatar({
    required this.imagePath,
    required this.title,
    super.key,
    this.size = 50,
    this.borderColor = Colors.white,
    this.borderWidth = 3,
    this.fallbackColor,
    this.showShadow = true,
    this.borderRadius = 8,
    this.contentBorderRadius = 3,
  });

  final String? imagePath;
  final String title;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Color? fallbackColor;
  final bool showShadow;
  final double borderRadius;
  final double contentBorderRadius;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = fallbackColor ?? Colors.orange.shade600;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(contentBorderRadius),
        child: ProfileImageWidget(
          avatarPath: imagePath,
          size: size,
          profileName: title,
          profileColor: backgroundColor,
        ),
      ),
    );
  }
}
