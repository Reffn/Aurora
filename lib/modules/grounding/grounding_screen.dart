import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/data/grounding_exercises.dart';
import 'package:dis_app/modules/grounding/exercise_player_screen.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/modules/grounding/widgets/anchor_button.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_tile.dart';
import 'package:dis_app/widgets/section_header.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';

// Abstände als Konstanten für robuste Breitenberechnung
const double _horizontalPadding = 16;
const double _tileSpacing = 12;
const int _tilesPerRow = 2;

/// Übersicht des Erdungsbereichs
///
/// Trägt nur die Profil-Farblinie, keinen eigenen Titel: Der Bereichsname und
/// der Rückweg stehen schon in der Kopfzeile der Arbeitsfläche darüber.
/// Beides doppelt hieß zwei Kopfzeilen, zwei Rückwege und den Bereichsnamen
/// zweimal — Prüffrage 5 verlangt genau einen sichtbaren Rückweg.
class GroundingScreen extends StatelessWidget {
  const GroundingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: StandardAppBar(), body: GroundingBody());
  }
}

/// Der Inhalt des Erdungsbereichs
///
/// Dieser Body fragt bewusst kein Profil und keine Berechtigung ab.
/// Die StandardAppBar oben (mit Profil-Farblinie) ist eine App-Struktur-Anforderung,
/// aber der Inhalt selbst ist völlig rechtefrei.
class GroundingBody extends StatelessWidget {
  const GroundingBody({super.key});

  void _open(BuildContext context, GroundingExercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExercisePlayerScreen(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Padding(
        // Unten mehr Luft, damit die unterste Kachelreihe nicht unter der
        // Navigationsleiste des Systems verschwindet.
        padding: const EdgeInsets.fromLTRB(
          _horizontalPadding,
          _horizontalPadding,
          _horizontalPadding,
          _horizontalPadding + 48,
        ),
        child: Column(
          children: [
            AnchorButton(
              onTap: () => _open(context, GroundingExercises.anchor),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              icon: Icons.grid_view,
              title: l10n.groundingChooseLabel,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // Zwei Kacheln je Reihe, nicht drei: bei drei blieb für
                // „Wegschließen" so wenig Platz, dass das Wort mitten drin
                // umbrach. Breitere Kacheln sind zugleich größere Ziele —
                // im dissoziativen Zustand trifft niemand kleine Flächen.
                final usableWidth = constraints.maxWidth - _tileSpacing;
                final tileWidth = usableWidth / _tilesPerRow;

                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: _tileSpacing,
                  runSpacing: _tileSpacing,
                  children: GroundingExercises.others
                      .map(
                        (exercise) => SizedBox(
                          width: tileWidth,
                          child: ExerciseTile(
                            key: ValueKey('grounding-tile-${exercise.id}'),
                            exercise: exercise,
                            onTap: () => _open(context, exercise),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
