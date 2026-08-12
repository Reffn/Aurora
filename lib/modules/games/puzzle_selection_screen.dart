import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/puzzle_config.dart';
import 'package:dis_app/modules/games/jigsaw_puzzle_screen.dart';
import 'package:dis_app/modules/games/sliding_puzzle_screen.dart';
import 'package:dis_app/modules/games/widgets/puzzle_image_picker_dialog.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Screen zur Auswahl des Puzzle-Typs und der Schwierigkeit
class PuzzleSelectionScreen extends StatefulWidget {
  const PuzzleSelectionScreen({super.key});

  @override
  State<PuzzleSelectionScreen> createState() => _PuzzleSelectionScreenState();
}

class _PuzzleSelectionScreenState extends State<PuzzleSelectionScreen> {
  PuzzleType _selectedType = PuzzleType.jigsaw;
  PuzzleDifficulty _selectedDifficulty = PuzzleDifficulty.easy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.puzzleCreateTitle),
      ),
      body: SingleChildScrollView(
        // Unten nicht fest 24: Am Scrollende lag der Startknopf sonst unter
        // der Android-Navigationsleiste, und weiteres Rollen half nicht, weil
        // das Ende erreicht war. `safeBottomPaddingWithMargin` hält denselben
        // sichtbaren Abstand ein und legt die Systemfläche darunter.
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          context.safeBottomPaddingWithMargin(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Intro-Text
            const Icon(Icons.extension, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              l10n.puzzleRelaxationTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.puzzleRelaxationSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),

            // Puzzle-Typ Auswahl
            _buildSectionTitle(l10n.puzzleTypeLabel),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeCard(
                    type: PuzzleType.jigsaw,
                    icon: Icons.extension,
                    title: l10n.puzzleTypeJigsaw,
                    description: l10n.puzzleTypeJigsawDescription,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeCard(
                    type: PuzzleType.sliding,
                    icon: Icons.grid_on,
                    title: l10n.puzzleTypeSliding,
                    description: l10n.puzzleTypeSlidingDescription,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Schwierigkeit Auswahl
            _buildSectionTitle(l10n.puzzleDifficultyLabel),
            const SizedBox(height: 12),
            ...PuzzleDifficulty.values.map((difficulty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDifficultyCard(l10n, difficulty),
              );
            }),

            const SizedBox(height: 32),

            // Start-Button
            ElevatedButton.icon(
              onPressed: () => _startPuzzle(l10n),
              icon: const Icon(Icons.play_arrow, size: 28),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.puzzleSelectImageAndStart,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTypeCard({
    required PuzzleType type,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white70,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    AppLocalizations l10n,
    PuzzleDifficulty difficulty,
  ) {
    final isSelected = _selectedDifficulty == difficulty;

    String label;
    String description;
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        label = l10n.puzzleDifficultyEasy;
        description = l10n.puzzleDifficultyEasyDescription;
      case PuzzleDifficulty.medium:
        label = l10n.puzzleDifficultyMedium;
        description = l10n.puzzleDifficultyMediumDescription;
      case PuzzleDifficulty.hard:
        label = l10n.puzzleDifficultyHard;
        description = l10n.puzzleDifficultyHardDescription;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = difficulty),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Difficulty Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                difficulty == PuzzleDifficulty.easy
                    ? Icons.sentiment_satisfied
                    : difficulty == PuzzleDifficulty.medium
                    ? Icons.sentiment_neutral
                    : Icons.sentiment_very_dissatisfied,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(width: 16),

            // Difficulty Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPuzzle(AppLocalizations l10n) async {
    // Zeige Bildauswahl-Dialog
    final imageResult = await PuzzleImagePickerDialog.show(context);

    if (imageResult == null || !mounted) return;

    // Erstelle PuzzleConfig
    final dataEntry = getIt<DataEntry>();
    final activeProfile = dataEntry.getActiveProfile();

    if (activeProfile == null) {
      if (!mounted) return;
      showCustomSnackBar(
        context,
        message: l10n.errorNoProfileSelected,
        type: SnackBarType.error,
      );
      return;
    }

    final config = PuzzleConfig(
      id: const Uuid().v4(),
      type: _selectedType,
      difficulty: _selectedDifficulty,
      imageSource: imageResult.source,
      imagePath: imageResult.file?.path,
      imageUrl: imageResult.categoryName,
      createdAt: DateTime.now(),
      createdByProfileId: activeProfile.id,
    );

    // Navigiere zum entsprechenden Puzzle-Screen
    if (!mounted) return;

    if (_selectedType == PuzzleType.jigsaw) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => JigsawPuzzleScreen(
            config: config,
            imageFile: imageResult.file,
            imageBytes: imageResult.bytes,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => SlidingPuzzleScreen(
            config: config,
            imageFile: imageResult.file,
            imageBytes: imageResult.bytes,
          ),
        ),
      );
    }
  }
}
