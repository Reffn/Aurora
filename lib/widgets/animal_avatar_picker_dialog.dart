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

  /// Liste der verfügbaren Avatar-Vorlagen
  ///
  /// Bis zum 14.08.2026 standen hier Hund, Katze und Giraffe — fremde Bilder,
  /// deren Nutzungsrecht niemand belegen konnte. In einer App, die offen
  /// gehen soll, wandert so ein Bild mit jeder Kopie des Quelltextes weiter.
  ///
  /// Ersetzt durch Aurora-eigene Chamäleons aus demselben Bestand wie die
  /// Bereichsbilder. Jede Vorlage hat eine eigene Grundfarbe: Wer zwischen
  /// Anteilen wechselt, soll sie auseinanderhalten können, ohne den Namen zu
  /// lesen.
  static final List<AnimalAvatar> _animalAvatars = [
    AnimalAvatar(
      assetPath: 'assets/images/cham_avatar_gelassen.webp',
      label: (l10n) => l10n.animalAvatarCalm,
    ),
    AnimalAvatar(
      assetPath: 'assets/images/cham_avatar_herz.webp',
      label: (l10n) => l10n.animalAvatarHeart,
    ),
    AnimalAvatar(
      assetPath: 'assets/images/cham_avatar_nachdenklich.webp',
      label: (l10n) => l10n.animalAvatarThinking,
    ),
    AnimalAvatar(
      assetPath: 'assets/images/cham_avatar_musik.webp',
      label: (l10n) => l10n.animalAvatarMusic,
    ),
    AnimalAvatar(
      assetPath: 'assets/images/cham_avatar_tasse.webp',
      label: (l10n) => l10n.animalAvatarMug,
    ),
    AnimalAvatar(
      assetPath: 'assets/images/cham_avatar_stern.webp',
      label: (l10n) => l10n.animalAvatarStar,
    ),
    AnimalAvatar(
      assetPath: 'assets/images/cham_avatar_sonnenbrille.webp',
      label: (l10n) => l10n.animalAvatarSunglasses,
    ),
    AnimalAvatar(
      assetPath: 'assets/images/cham_avatar_daumen.webp',
      label: (l10n) => l10n.animalAvatarThumbsUp,
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

            // Wrap statt Row: Acht Vorlagen passen nicht mehr nebeneinander,
            // und bei grosser Schrift auch drei nicht. Der Scrollbereich
            // fängt ab, was auf kleinen Schirmen darunter noch übrig bleibt.
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: _animalAvatars.map((animal) {
                    return _buildAnimalOption(context, animal);
                  }).toList(),
                ),
              ),
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
      // Feste Breite, sonst zieht ein langer Name — „Lunettes de soleil" —
      // seine Kachel breit und die Reihe bricht an einer anderen Stelle als
      // in den übrigen Sprachen.
      //
      // 96 waren zu knapp: „Nachdenklich" und „Sonnenbrille" brachen mitten
      // im Wort. Am S24 fiel das nicht auf, weil dort zwei Kacheln je Reihe
      // stehen und die Namen kürzer wirken; auf einem breiteren Schirm mit
      // drei je Reihe schon. Ein Widgettest fängt das nicht: Er misst mit
      // der Testschrift, in der jedes Zeichen so breit ist wie hoch — dort
      // bricht sogar „Musik".
      child: SizedBox(
        width: 128,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Die Vorlagen sind runde Scheiben mit durchsichtigen Ecken. Ein
            // eckiger Rahmen darum sässe neben dem Bild statt daran.
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
