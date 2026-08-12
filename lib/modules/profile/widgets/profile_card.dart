import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Große Profilkarte für Auswahl-Screen
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.profile,
    super.key,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });
  final Profile profile;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // Ohne eigene Semantik sammelt der Baum Bereichstitel, Beschreibung und
    // den Namen ein und sagt sie hintereinander an. Der Name genügt: Wer
    // wählt, sucht sich, nicht die Überschrift darüber.
    return Semantics(
      button: true,
      label: profile.name,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? profile.preferredColor : Colors.grey[300]!,
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: profile.preferredColor.withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: profile.preferredColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: profile.preferredColor.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: ProfileImageWidget(
                    avatarPath: profile.avatarPath,
                    size: 80,
                    profileName: profile.name,
                    profileColor: profile.preferredColor,
                    // Zwei Zeichen, wie die eigene Kopie es hatte. Die
                    // Migration soll die Optik nicht nebenbei aendern.
                    maxInitialChars: 2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Semantics(
                  enabled: false,
                  child: Text(
                    profile.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: profile.preferredColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Optional: Alter
              if (profile.age != null) ...[
                const SizedBox(height: 4),
                Semantics(
                  enabled: false,
                  child: Text(
                    AppLocalizations.of(context).profileAgeYears(profile.age!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
