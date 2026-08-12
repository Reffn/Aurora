import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/games/drawing_screen.dart';
import 'package:dis_app/modules/games/memory_screen.dart';
import 'package:dis_app/modules/games/puzzle_selection_screen.dart';
import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/exercise_player_screen.dart';
import 'package:dis_app/widgets/icon_container.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';

/// Spiele-Screen
/// Features:
/// - Puzzle (Jigsaw & Schiebepuzzle)
/// - Atemübungen — dieselbe Übung, die auch „Halt" anbietet
/// - Memory, ohne Uhr und ohne Punkte
/// - Zeichnen — dieselbe Fläche wie im Chat, nur ohne Verlauf darunter
///
/// Was hier steht, ist begehbar. Eine Karte, die nur ankündigt, ist an einer
/// Stelle, die jemand in schlechtem Zustand ansteuert, teurer als eine
/// fehlende — das galt schon für die Atemübungen und danach noch einmal für
/// das Zeichnen.
/// Fokus auf Entspannung, keine Punktesysteme
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  /// Ob dieser Anteil eine Zeichnung in den Chat schicken darf.
  ///
  /// Dieselbe Prüfung wie im Chat: Die alte Sammelberechtigung gilt weiter
  /// als Freibrief, sonst entscheidet das Einzelrecht.
  bool _darfZeichnungSchicken() {
    final profile = getIt<DataEntry>().getActiveProfile();
    if (profile == null) return false;

    return profile.hasPermission(Permission.sendChatMessage) ||
        profile.hasPermission(Permission.sendDoodle);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: const StandardAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Intro-Text
            const Icon(Icons.games, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.gamesTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.gamesSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Puzzle-Karte
            _buildGameCard(
              context,
              l10n,
              icon: Icons.extension,
              title: l10n.gamesPuzzleTitle,
              subtitle: l10n.gamesPuzzleSubtitle,
              description: l10n.gamesPuzzleDescription,
              color: Colors.blue,
              isAvailable: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const PuzzleSelectionScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Atemübungen — führt zu der Übung, die es längst gibt.
            //
            // Sie stand hier als „Bald", während „Halt" eine fertige
            // Atemübung anbietet. Wer unter Stress den naheliegenden Eintrag
            // wählt, landete damit in einer Sackgasse statt auf dem
            // vorhandenen Weg. Eine tote Karte an einer Stelle, die jemand
            // in schlechtem Zustand ansteuert, ist teurer als eine fehlende.
            _buildGameCard(
              context,
              l10n,
              icon: Icons.air,
              title: l10n.gamesBreathingTitle,
              subtitle: l10n.gamesBreathingSubtitle,
              description: l10n.gamesBreathingDescription,
              color: Colors.teal,
              isAvailable: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => ExercisePlayerScreen(
                      exercise: GroundingExercises.breath,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildGameCard(
              context,
              l10n,
              icon: Icons.grid_view,
              title: l10n.gamesMemoryTitle,
              subtitle: l10n.gamesMemorySubtitle,
              description: l10n.gamesMemoryDescription,
              color: Colors.purple,
              isAvailable: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const MemoryScreen(),
                  ),
                );
              },
            ),

            // Zeichnen — die Zeichenfläche gab es längst, sie hing nur im
            // Chat fest. Dieselbe tote Karte neben einer fertigen Sache wie
            // oben bei den Atemübungen.
            //
            // Sie erscheint nur, wenn dieser Anteil ein Doodle schicken darf:
            // Das Bild landet im gemeinsamen Verlauf. Eine Karte anzubieten,
            // die an der Rechteprüfung scheitert, wäre der Fehlerpfad, den
            // Errorless Learning gar nicht erst entstehen lassen will —
            // deshalb fehlt sie lieber ganz.
            if (_darfZeichnungSchicken()) ...[
              const SizedBox(height: 16),
              _buildGameCard(
                context,
                l10n,
                icon: Icons.brush,
                title: l10n.gamesDrawingTitle,
                subtitle: l10n.gamesDrawingSubtitle,
                description: l10n.gamesDrawingDescription,
                color: Colors.orange,
                isAvailable: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const DrawingScreen(),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required bool isAvailable,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: isAvailable ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAvailable ? color.withValues(alpha: 0.5) : Colors.white12,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              IconContainer.medium(
                icon: icon,
                backgroundColor: isAvailable
                    ? color.withValues(alpha: 0.15)
                    : Colors.white10,
                iconColor: isAvailable ? color : Colors.white38,
              ),

              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Flexible, damit der Name umbricht statt überzulaufen:
                        // „Atemübungen" passt, „Ejercicios de respiración"
                        // nicht — die Zeile lief um 50 Pixel über den Rand.
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isAvailable
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                          ),
                        ),
                        if (!isAvailable) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.gamesComingSoon,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isAvailable
                            ? color.withValues(alpha: 0.8)
                            : Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 8),
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

              // Arrow
              if (isAvailable)
                Icon(
                  Icons.chevron_right,
                  color: color,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
