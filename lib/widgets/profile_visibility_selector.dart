import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:flutter/material.dart';

/// Wiederverwendbares Widget für Profil-Sichtbarkeits-Auswahl
/// Verwendet in Calendar und Diary Forms
class ProfileVisibilitySelector extends StatelessWidget {
  const ProfileVisibilitySelector({
    required this.selectedProfileIds,
    required this.onChanged,
    required this.allProfiles,
    this.label,
    this.disabledProfileIds = const {},
    super.key,
  });

  /// Aktuell ausgewählte Profil-IDs
  final Set<String> selectedProfileIds;

  /// Callback wenn Auswahl sich ändert
  final ValueChanged<Set<String>> onChanged;

  /// Alle verfügbaren Profile
  final List<Profile> allProfiles;

  /// Überschrift der Sektion. Offen gelassen heißt: aus der Sprache holen.
  final String? label;

  /// Profile die nicht abgewählt werden können (z.B. Autor/Ersteller)
  final Set<String> disabledProfileIds;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? AppLocalizations.of(context).profileVisibilityTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...allProfiles.map((profile) {
          final isSelected = selectedProfileIds.contains(profile.id);
          final isDisabled = disabledProfileIds.contains(profile.id);

          return CheckboxListTile(
            title: Text(
              profile.name,
              style: TextStyle(
                color: isDisabled ? Colors.white70 : null,
              ),
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isDisabled
                    ? profile.preferredColor.withValues(alpha: 0.5)
                    : profile.preferredColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            value: isSelected,
            onChanged: isDisabled
                ? null // Disabled: Checkbox kann nicht geändert werden
                : (checked) {
                    final newSelection = Set<String>.from(selectedProfileIds);
                    if (checked ?? false) {
                      newSelection.add(profile.id);
                    } else {
                      newSelection.remove(profile.id);
                    }
                    onChanged(newSelection);
                  },
            activeColor: profile.preferredColor,
          );
        }),
      ],
    );
  }
}
