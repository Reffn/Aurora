import 'package:dis_app/widgets/profile_switch_avatar.dart';
import 'package:flutter/material.dart';

/// Map-Marker für Profilwechsel (diagonales Rechteck)
///
/// **Wrapper um `ProfileSwitchAvatar`** für Map-spezifische Verwendung
///
/// Verwendet für:
/// - Profilwechsel-Events auf der Karte
///
/// **Features:**
/// - Nutzt `ProfileSwitchAvatar` (diagonales Rechteck, Rainbow-Initialen)
/// - Map-spezifische Defaults (size)
class MapMarkerProfileSwitch extends StatelessWidget {
  const MapMarkerProfileSwitch({
    required this.fromAvatarPath,
    required this.fromProfileName,
    required this.fromProfileColor,
    required this.toAvatarPath,
    required this.toProfileName,
    required this.toProfileColor,
    super.key,
    this.avatarSize = 35,
  });

  final String? fromAvatarPath;
  final String fromProfileName;
  final Color fromProfileColor;

  final String? toAvatarPath;
  final String toProfileName;
  final Color toProfileColor;

  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return ProfileSwitchAvatar(
      fromAvatarPath: fromAvatarPath,
      fromProfileName: fromProfileName,
      fromProfileColor: fromProfileColor,
      toAvatarPath: toAvatarPath,
      toProfileName: toProfileName,
      toProfileColor: toProfileColor,
      size: avatarSize,
    );
  }
}
