import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Wiederverwendbarer Avatar Picker für Formulare
///
/// Zeigt einen quadratischen Container mit:
/// - Avatarbild (falls vorhanden)
/// - Initialen-Fallback (erste 2 Zeichen des Names)
/// - Kamera-Icon Overlay (unten rechts)
///
/// **Verwendung:**
/// ```dart
/// FormAvatarPicker(
///   avatarPath: _selectedAvatarPath,
///   fallbackText: _nameController.text,
///   onTap: () {
///     ImagePickerBottomSheet.show(
///       context,
///       title: 'Bild wählen',
///       onImagePathSelected: (path) {
///         setState(() => _selectedAvatarPath = path);
///       },
///     );
///   },
/// )
/// ```
class FormAvatarPicker extends StatelessWidget {
  const FormAvatarPicker({
    required this.onTap,
    super.key,
    this.avatarPath,
    this.fallbackText = '',
    this.size = 100,
  });

  /// Pfad zum Avatar-Bild (relativ oder Asset-Pfad)
  final String? avatarPath;

  /// Text für Initialen-Fallback (meist Name des Kontakts/Profils)
  final String fallbackText;

  /// Callback beim Tap auf den Avatar
  final VoidCallback onTap;

  /// Größe des quadratischen Containers (Standard: 100)
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Avatar Container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // Ein Aufruf, nicht zwei Zweige.
              //
              // Der `else`-Zweig rief die eigenen Initialen direkt auf, an
              // `ProfileImageWidget` vorbei — eine achte Stelle, die keine
              // Aenderung an dessen Schnittstelle je erwischt haette.
              // `avatarPath: null` behandelt das Widget selbst.
              child: ProfileImageWidget(
                avatarPath: avatarPath,
                size: size,
                profileName: fallbackText,
                profileColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                maxInitialChars: 2,
              ),
            ),
          ),

          // Kamera-Icon Overlay (unten rechts)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.32, // 32% der Größe
              height: size * 0.32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                size: size * 0.16, // 16% der Größe
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Initialen-Widget (erste 2 Zeichen)
}
