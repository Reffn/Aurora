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
    Widget bild = KeyedSubtree(
      key: const ValueKey('grounding-bild'),
      child: GroundingBildView(
        bild: GroundingImages.bildFuer(step.imageKey),
        exercise: exercise,
      ),
    );

    final hold = step.hold;
    if (hold != null) {
      bild = _HoldRing(
        key: ValueKey('grounding-hold-$index'),
        duration: hold,
        color: exercise.color,
        child: bild,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Center(child: bild)),
        ProgressDots(
          active: index + 1,
          total: exercise.steps.length,
          color: exercise.color,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: StepTextArea(
            text: _stepText(l10n, step, Localizations.localeOf(context)),
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
  String _lookup(AppLocalizations l10n, String key) => textOf(l10n, key);

  /// Der Text eines Schritts, auch für den Atem-Takt.
  static String textOf(AppLocalizations l10n, String key) =>
      _groundingStrings(l10n)[key] ?? '';

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

/// Der Satz unter dem Bild, in einem Bereich fester Höhe.
///
/// Am Gerät (A14, 3.0.24) sprangen Bild und Text je Schritt auf und ab: Das
/// Bild steht mittig im Rest der Fläche, und ein zweizeiliger Satz nahm ihm
/// eine Zeile weg. Der Bereich ist jetzt immer so hoch wie drei Zeilen bei
/// 22 pt — mit der Systemschrift gerechnet, damit er bei großer Schrift
/// mitwächst. Ein Satz, der auch dann noch länger ist, darf den Bereich
/// sprengen: Abschneiden wäre schlimmer als ein Sprung.
///
/// Die Höhe wird nicht im Test gemessen, sondern gerechnet: Widgettests
/// setzen jede Glyphe so breit wie hoch, Umbrüche dort sagen über das Gerät
/// nichts.
class StepTextArea extends StatelessWidget {
  const StepTextArea({required this.text, super.key});

  final String text;

  static const double fontSize = 22;
  static const double lineHeight = 1.4;
  static const int lines = 3;

  @override
  Widget build(BuildContext context) {
    final skaliert = MediaQuery.textScalerOf(context).scale(fontSize);
    return Container(
      constraints: BoxConstraints(
        minHeight: skaliert * lineHeight * lines,
        minWidth: double.infinity,
      ),
      alignment: Alignment.topCenter,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: fontSize, height: lineHeight),
      ),
    );
  }
}

/// Der Ring um das Bild, der sich über die Verweildauer füllt.
///
/// Das Modell versprach ihn seit dem ersten Tag („zeichnet einen Ring"),
/// gezeichnet hat ihn nie jemand. Er macht vor, was der Schritt verlangt —
/// vier Sekunden einatmen, sechs ausatmen — und ist damit die eine
/// Bewegung, die Richtlinie 11 ausdrücklich erlaubt. Er blockiert nichts:
/// Weitertippen geht jederzeit, der Ring ist Angebot, nicht Schranke.
///
/// Endlich, nicht wiederholend — ein Ring, der nie zur Ruhe kommt, hält
/// jeden `pumpAndSettle` an. Bei abgeschalteter Bewegung steht er voll.
class _HoldRing extends StatelessWidget {
  const _HoldRing({
    required this.duration,
    required this.color,
    required this.child,
    super.key,
  });

  final Duration duration;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduceMotion ? Duration.zero : duration,
      builder: (context, value, child) => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 256,
            height: 256,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              color: color.withValues(alpha: 0.7),
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
          child!,
        ],
      ),
      child: child,
    );
  }
}

/// Das Bild eines Schritts im ruhigen Kreis der Übung.
///
/// Ein gezeichnetes Bild, wenn eins hinterlegt ist; sonst das eigene Symbol
/// des Schritts; fehlt auch das, das Symbol der Übung. Der Kreis ist derselbe
/// wie auf dem Abschluss (`ExerciseDoneSheet`): Farbe der Übung, gedämpft —
/// dies ist der Halt-Bereich, hier bleibt alles ruhig (Regel 4).
class GroundingBildView extends StatelessWidget {
  const GroundingBildView({
    required this.bild,
    required this.exercise,
    this.size = 220,
    super.key,
  });

  final GroundingBild? bild;
  final GroundingExercise exercise;
  final double size;

  @override
  Widget build(BuildContext context) {
    final symbol = _SymbolKreis(
      icon: switch (bild) {
        GroundingBildSymbol(:final icon) => icon,
        _ => exercise.icon,
      },
      color: exercise.color,
      size: size,
    );

    return switch (bild) {
      GroundingBildAsset(:final path) => Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        // Fehlt das Asset trotz Eintrag, springt das Symbol ein.
        errorBuilder: (context, error, stack) => symbol,
      ),
      _ => symbol,
    };
  }
}

class _SymbolKreis extends StatelessWidget {
  const _SymbolKreis({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
      ),
      child: Icon(icon, size: size * 0.55, color: color),
    );
  }
}
