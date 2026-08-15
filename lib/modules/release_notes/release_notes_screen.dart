import 'dart:async';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/feedback/feedback_screen.dart';
import 'package:dis_app/services/release_notes_gate.dart';
import 'package:flutter/material.dart';

/// Was sich geändert hat — einmal nach dem Update, dann nie wieder.
///
/// **Der Schirm ist kein Änderungsprotokoll.** Er ist die eine Gelegenheit,
/// in der Aurora jemanden erreicht: Play verteilt Updates, aber niemand
/// erfährt dabei, was neu ist, und niemand wird gefragt, was fehlt. Bei 24
/// monatlich aktiven Geräten liegt kein einziges echtes Feedback vor. Deshalb
/// trägt die Fläche zwei Dinge und nicht mehr — einen kurzen Absatz zur
/// Fassung und die Frage danach.
///
/// Die Regeln, an denen er sich messen lässt
/// ([docs/oberflaechen-richtlinien.md]):
/// - 4: Keine gesättigte Fläche. Hier muss nichts im schlechtesten Zustand
///   gefunden werden; der Schirm ist ruhig.
/// - 5: Jeder Knopf trägt Symbol und Wort.
/// - 10: Es steht dort, was nach dem Schreiben passiert, und es gibt einen
///   Ausgang, der nicht „Abbrechen" heißt.
/// - 11: Keine Feier, keine Animation, kein nicht überspringbarer Moment.
///
/// Beide Knöpfe sind gleich groß. Wer nur weiterwill, soll dafür nicht den
/// kleineren treffen müssen.
///
/// **Pflege bei jeder Fassung:** `releaseNotesHighlights` beschreibt, was sich
/// geändert hat, und gehört vor jedem Release neu gesetzt — in **allen fünf**
/// Sprachdateien (`lib/l10n/app_{de,en,fr,es,it}.arb`). Bleibt der Text
/// stehen, liest die eine Person, die den Schirm überhaupt zu Gesicht bekommt,
/// die Neuigkeit von vorletztem Mal.
class ReleaseNotesScreen extends StatelessWidget {
  const ReleaseNotesScreen({
    required this.onDismissed,
    required this.gate,
    this.appVersion,
    this.onOpenFeedback,
    super.key,
  });

  /// Wird gerufen, sobald die Fassung als gesehen vermerkt ist.
  ///
  /// Darf leer bleiben: Der Vermerk landet in derselben `settings`-Box, auf
  /// die `main.dart` hört — der Wechsel kommt von selbst.
  final VoidCallback onDismissed;

  final ReleaseNotesGate gate;

  /// Nur für die Überschrift. Fehlt sie, steht dort keine Nummer.
  final String? appVersion;

  /// Wie das Formular geöffnet wird. Ohne Angabe: der echte Weg dorthin.
  ///
  /// Die Naht existiert, damit prüfbar bleibt, was hier wirklich zählt — dass
  /// die Fassung *vor* dem Öffnen vermerkt wird, sonst stünde der Schirm nach
  /// der Rückkehr aus dem Formular erneut da. `FeedbackScreen` holt seinen
  /// Versender aus GetIt; ein Test, der dafür den ganzen Container aufsetzt,
  /// prüft am Ende den Aufbau statt die Reihenfolge.
  final Future<void> Function()? onOpenFeedback;

  static const double _buttonHeight = 110;

  Future<void> _weiter() async {
    await gate.markSeen();
    onDismissed();
  }

  Future<void> _zumFeedback(BuildContext context) async {
    // Der Navigator wird vor dem Warten gegriffen: `markSeen` löst den
    // Wechsel des Startschirms aus, und dieser Kontext ist danach nicht mehr
    // eingehängt.
    final navigator = Navigator.of(context);

    await gate.markSeen();
    onDismissed();

    final oeffnen = onOpenFeedback;
    if (oeffnen != null) {
      await oeffnen();
      return;
    }

    await navigator.push(
      MaterialPageRoute<void>(builder: (_) => const FeedbackScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final version = appVersion;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Der Text scrollt, die Knöpfe bleiben stehen. Prüffrage 6:
              // nichts liegt außerhalb des Schirms.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Icon(
                        Icons.update,
                        size: 56,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.releaseNotesTitle,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      if (version != null && version.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        // Produktname und Nummer werden nicht übersetzt —
                        // deshalb kein Platzhalter in den Sprachdateien.
                        Text(
                          'Aurora $version',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.releaseNotesHighlights,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.releaseNotesAsk,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      // Richtlinie 10: sagen, was nach dem Absenden passiert.
                      Text(
                        l10n.releaseNotesWhatHappens,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _ReleaseNotesButton(
                key: const Key('release_notes_feedback'),
                icon: Icons.chat_bubble_outline,
                label: l10n.releaseNotesFeedbackAction,
                height: _buttonHeight,
                onPressed: () => unawaited(_zumFeedback(context)),
              ),
              const SizedBox(height: 12),
              _ReleaseNotesButton(
                key: const Key('release_notes_continue'),
                icon: Icons.arrow_forward,
                label: l10n.releaseNotesContinueAction,
                height: _buttonHeight,
                onPressed: () => unawaited(_weiter()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Beide Wege tragen dieselbe Form. Kein Knopf ist lauter als der andere.
class _ReleaseNotesButton extends StatelessWidget {
  const _ReleaseNotesButton({
    required this.icon,
    required this.label,
    required this.height,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            // Richtlinie 5: Symbol links und groß, Wort daneben. Nie eins
            // von beiden allein.
            Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
