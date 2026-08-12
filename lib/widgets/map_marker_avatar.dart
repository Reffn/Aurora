import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Map-Marker für Avatar-Darstellung (kreisförmig)
///
/// Verwendet für:
/// - User Position (mit Pulsing-Animation)
/// - Normale Avatar-Marker
///
/// **Features:**
/// - Kreisförmig (ClipOval)
/// - ProfileImageWidget mit Rainbow-Initialen Fallback
/// - Optional: Pulsing-Animation
/// - White Border (3px)
/// - Box Shadow
class MapMarkerAvatar extends StatefulWidget {
  const MapMarkerAvatar({
    required this.avatarPath,
    required this.profileName,
    required this.profileColor,
    super.key,
    this.size = 50,
    this.enablePulsing = false,
    this.borderColor = Colors.white,
    this.borderWidth = 3,
  });

  final String? avatarPath;
  final String profileName;
  final Color profileColor;
  final double size;
  final bool enablePulsing;
  final Color borderColor;
  final double borderWidth;

  @override
  State<MapMarkerAvatar> createState() => _MapMarkerAvatarState();
}

class _MapMarkerAvatarState extends State<MapMarkerAvatar> {
  @override
  Widget build(BuildContext context) {
    final avatarWidget = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: ProfileImageWidget(
          avatarPath: widget.avatarPath,
          size: widget.size,
          profileName: widget.profileName,
          profileColor: widget.profileColor,
        ),
      ),
    );

    // Ohne Pulsing: nur Avatar
    if (!widget.enablePulsing) {
      return avatarWidget;
    }

    // Mit Pulsing: Avatar + Animation Ring
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsierender äußerer Kreis
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.5, end: 1),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, double value, child) {
            return Container(
              width: widget.size * value,
              height: widget.size * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.profileColor.withValues(alpha: 0.2 * (1 - value)),
              ),
            );
          },
          onEnd: () {
            // Restart animation wenn Widget noch mounted
            if (mounted) setState(() {});
          },
        ),
        // Avatar
        avatarWidget,
      ],
    );
  }
}
