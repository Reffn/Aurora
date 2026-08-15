import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/widgets/user_marked_color_picker.dart';
import 'package:flutter/material.dart';

/// Widget für Farbauswahl beim Profil erstellen/bearbeiten
/// Zeigt ColorPicker inline statt in einem Dialog
class ProfileColorSection extends StatelessWidget {
  const ProfileColorSection({
    required this.selectedColor,
    required this.onColorChanged,
    required this.existingProfiles,
    super.key,
    this.currentProfileId,
  });

  final Color selectedColor;
  final void Function(Color color, Offset normalizedPosition) onColorChanged;
  final List<Profile> existingProfiles;
  final String? currentProfileId;

  @override
  Widget build(BuildContext context) {
    return UserMarkedColorPicker(
      initialColor: selectedColor,
      existingProfiles: existingProfiles,
      currentProfileId: currentProfileId,
      onColorChanged: onColorChanged,
    );
  }
}
