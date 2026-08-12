import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Dialog zur Auswahl vordefinierter Tier-Avatar-Vorlagen
class AnimalAvatarPickerDialog extends StatelessWidget {
  const AnimalAvatarPickerDialog({super.key});

  /// Zeigt den Dialog an und gibt den ausgewählten Asset-Pfad zurück
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const AnimalAvatarPickerDialog(),
    );
  }

  /// Liste der verfügbaren Tier-Avatar-Vorlagen
  static final List<AnimalAvatar> _animalAvatars = [
    AnimalAvatar(
      assetPath: 'assets/images/Hund.png',
      label: (l10n) => l10n.animalAvatarDog,
    ),
    AnimalAvatar(
      assetPath: 'assets/images/Katze.webp',
      label: (l10n) => l10n.animalAvatarCat,
    ),
    AnimalAvatar(
      assetPath: 'assets/images/Girafe.png',
      label: (l10n) => l10n.animalAvatarGiraffe,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titel
            Text(
              AppLocalizations.of(context).imagePickerAnimalAvatar,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Grid mit Tier-Avataren
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _animalAvatars.map((animal) {
                return _buildAnimalOption(context, animal);
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Abbrechen-Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalOption(BuildContext context, AnimalAvatar animal) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, animal.assetPath),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tier-Bild
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                animal.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            animal.label(AppLocalizations.of(context)),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Datenklasse für einen Tier-Avatar
///
/// Der Name kommt als Funktion über die Sprache herein, nicht als fertiger
/// String: Die Liste ist statisch und wird einmal gebaut, die Sprache kann
/// sich danach noch ändern. Ein hier festgeschriebener Name blieb deshalb
/// deutsch, auch wenn die App auf Italienisch stand.
class AnimalAvatar {
  const AnimalAvatar({
    required this.assetPath,
    required this.label,
  });

  final String assetPath;
  final String Function(AppLocalizations l10n) label;
}
