import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/data/grounding_images.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Ein einzelner Schritt: Bild groß, Fortschritt darunter, Text zuletzt
///
/// Die Reihenfolge ist Absicht. Das Bild trägt die Anweisung, der Text
/// bestätigt sie nur — wer nicht liest, hat nach dem Bild schon alles.
class StepView extends StatelessWidget {
  const StepView({
    required this.exercise,
    required this.index,
    required this.now,
    super.key,
  });

  final GroundingExercise exercise;
  final int index;

  /// Wird hereingereicht statt intern erzeugt, damit Tests ein festes Datum
  /// setzen können.
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final step = exercise.steps[index];
    final assetPath = GroundingImages.resolve(step.imageKey);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: assetPath != null
                ? Image.asset(
                    assetPath,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    // Fehlt das Asset trotz Eintrag, springt das Symbol ein.
                    errorBuilder: (context, error, stack) =>
                        _FallbackSymbol(exercise: exercise),
                  )
                : _FallbackSymbol(exercise: exercise),
          ),
        ),
        ProgressDots(
          active: index + 1,
          total: exercise.steps.length,
          color: exercise.color,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _stepText(l10n, step, Localizations.localeOf(context)),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, height: 1.4),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  /// Der Schritt, der das Datum nennt, ist der einzige, dessen Text die
  /// Anweisung wirklich trägt — das Bild kann kein Datum zeigen. Deshalb muss
  /// er in der Sprache stehen, die der Anteil gewählt hat: „6.8.2026" ist in
  /// einer französischen Oberfläche nicht nur fremd, sondern zweideutig, weil
  /// dort Tag und Monat andersherum gelesen werden. Der Wochentag steht dabei,
  /// weil Zeitverlust genau ihn kostet.
  String _stepText(AppLocalizations l10n, GroundingStep step, Locale locale) {
    final base = _lookup(l10n, step.textKey);
    if (!step.showsCurrentDateTime) return base;

    final tag = locale.toLanguageTag();
    final date = DateFormat.yMMMMEEEEd(tag).format(now);
    final time = DateFormat.Hm(tag).format(now);
    return '$base\n$date, $time';
  }

  /// Übersetzt einen Schlüssel. Fehlt er, bleibt der Text leer statt zu
  /// werfen — das Bild trägt den Schritt ohnehin allein.
  String _lookup(AppLocalizations l10n, String key) {
    return _groundingStrings(l10n)[key] ?? '';
  }

  static Map<String, String> _groundingStrings(AppLocalizations l10n) => {
    'groundingOrientationStep1': l10n.groundingOrientationStep1,
    'groundingOrientationStep2': l10n.groundingOrientationStep2,
    'groundingOrientationStep3': l10n.groundingOrientationStep3,
    'groundingOrientationStep4': l10n.groundingOrientationStep4,
    'groundingOrientationStep5': l10n.groundingOrientationStep5,
    'groundingOrientationStep6': l10n.groundingOrientationStep6,
    'groundingSensesStep1': l10n.groundingSensesStep1,
    'groundingSensesStep2': l10n.groundingSensesStep2,
    'groundingSensesStep3': l10n.groundingSensesStep3,
    'groundingSensesStep4': l10n.groundingSensesStep4,
    'groundingSensesStep5': l10n.groundingSensesStep5,
    'groundingSensesStep6': l10n.groundingSensesStep6,
    'groundingBodyStep1': l10n.groundingBodyStep1,
    'groundingBodyStep2': l10n.groundingBodyStep2,
    'groundingBodyStep3': l10n.groundingBodyStep3,
    'groundingBodyStep4': l10n.groundingBodyStep4,
    'groundingBodyStep5': l10n.groundingBodyStep5,
    'groundingBodyStep6': l10n.groundingBodyStep6,
    'groundingContainerStep1': l10n.groundingContainerStep1,
    'groundingContainerStep2': l10n.groundingContainerStep2,
    'groundingContainerStep3': l10n.groundingContainerStep3,
    'groundingContainerStep4': l10n.groundingContainerStep4,
    'groundingContainerStep5': l10n.groundingContainerStep5,
    'groundingContainerStep6': l10n.groundingContainerStep6,
    'groundingBreathStep1': l10n.groundingBreathStep1,
    'groundingBreathStep2': l10n.groundingBreathStep2,
    'groundingBreathStep3': l10n.groundingBreathStep3,
    'groundingBreathStep4': l10n.groundingBreathStep4,
    'groundingBreathStep5': l10n.groundingBreathStep5,
  };

  /// Titel einer Übung, für Kachel und Kopfzeile
  static String titleOf(AppLocalizations l10n, GroundingExercise exercise) {
    switch (exercise.id) {
      case 'orientation':
        return l10n.groundingOrientationTitle;
      case 'senses':
        return l10n.groundingSensesTitle;
      case 'body':
        return l10n.groundingBodyTitle;
      case 'container':
        return l10n.groundingContainerTitle;
      case 'breath':
        return l10n.groundingBreathTitle;
      default:
        return '';
    }
  }
}

/// Ersatz, wenn kein Bild vorliegt: das Symbol der Übung, groß
class _FallbackSymbol extends StatelessWidget {
  const _FallbackSymbol({required this.exercise});

  final GroundingExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Icon(exercise.icon, size: 160, color: exercise.color);
  }
}
