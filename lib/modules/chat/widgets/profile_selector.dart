import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:flutter/material.dart';

/// Dropdown zur Auswahl des Absender-Profils
class ProfileSelector extends StatelessWidget {
  const ProfileSelector({
    required this.selectedProfile,
    required this.availableProfiles,
    required this.onProfileSelected,
    super.key,
  });
  final Profile? selectedProfile;
  final List<Profile> availableProfiles;
  final ValueChanged<Profile?> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    if (availableProfiles.isEmpty) {
      return Text(
        AppLocalizations.of(context).noProfileAvailable,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Profile>(
          value: selectedProfile,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(fontSize: 14),
          items: availableProfiles.map((profile) {
            return DropdownMenuItem<Profile>(
              value: profile,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar/Farb-Indikator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: profile.preferredColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        profile.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profile.name,
                    style: TextStyle(
                      color: profile.preferredColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onProfileSelected,
        ),
      ),
    );
  }
}
