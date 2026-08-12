import 'package:dis_app/models/profile.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Größen für ProfileAvatar Initialen
enum AvatarSize {
  small, // 18px Font, 2.5px Stroke (ProfileSwitcherBar)
  medium, // 32px Font, 3.5px Stroke (Default)
  large, // 42px Font, 4.5px Stroke (ProfileSelectionScreen)
}

/// Runder Avatar für Profil-Auswahl (Netflix-Style)
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.profile,
    super.key,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.size = 120, // Default Netflix-style size
    this.avatarSize = AvatarSize.medium, // Default Initialen-Größe
    this.showName = true, // Name unter Avatar anzeigen
    this.showGlow = false, // Glow-Effekt für aktive Profile
    this.nameFontSize = 16,
  });
  final Profile profile;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final double size;
  final AvatarSize avatarSize;
  final bool showName;
  final bool showGlow;

  /// Schriftgröße des Namens unter dem Kreis.
  ///
  /// Auf der Auswahlfläche größer als sonst: Dort ist der Name der Inhalt,
  /// nicht die Beschriftung eines Bedienelements. In der Profilleiste steht
  /// er dagegen neben anderen und bleibt klein.
  final double nameFontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Runder Avatar
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: profile.preferredColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? profile.preferredColor : Colors.black,
                width: isSelected ? 4 : 1,
              ),
              boxShadow: _buildBoxShadow(),
            ),
            child: ClipOval(
              child: ProfileImageWidget(
                avatarPath: profile.avatarPath,
                size: size,
                profileName: profile.name,
                profileColor: profile.preferredColor,
              ),
            ),
          ),

          // Name (optional)
          if (showName) ...[
            const SizedBox(height: 12),
            Text(
              profile.name,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Gibt BoxShadow basierend auf showGlow und isSelected zurück
  List<BoxShadow>? _buildBoxShadow() {
    if (showGlow) {
      // Glow-Effekt (für ProfileSwitcherBar aktive Profile)
      return [
        // Primary glow
        BoxShadow(
          color: profile.preferredColor.withValues(alpha: 0.7),
          blurRadius: 20,
          spreadRadius: 4,
        ),
        // Secondary glow
        BoxShadow(
          color: profile.preferredColor.withValues(alpha: 0.5),
          blurRadius: 12,
          spreadRadius: 2,
        ),
        // Depth shadow
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (isSelected) {
      // Standard Selection Shadow (für ProfileSelectionScreen)
      return [
        BoxShadow(
          color: profile.preferredColor.withAlpha(102),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
    }
    return null;
  }
}
