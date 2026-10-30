import 'dart:async';

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/modules/grounding/data/grounding_images.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/modules/grounding/widgets/step_view.dart';
import 'package:dis_app/widgets/progress_dots.dart';
import 'package:flutter/material.dart';

/// Der Atem als durchgehender Takt: ein Kreis, der vormacht, wann geatmet
/// wird.
///
/// Einatmen — er wächst; Halten — er steht; Ausatmen — er schrumpft. Jede
/// Phase dauert so lange wie das `hold` ihres Schritts (4, 2, 6 Sekunden),
/// darunter steht das passende Wort. Es läuft ohne Tippen durch alle
/// [GroundingExercise.pacedRounds] Runden; danach ruft es [onFinished].
///
/// Bis 3.0.24 füllte sich ein Ring und blieb stehen, weiter ging es nur per
/// Tipp — wer atmete, musste mitten im Atemzug tippen, und geführt wurde
/// genau ein Atemzug.
///
/// Die Bewegung zeigt hier die Sache selbst und ist deshalb erlaubt
/// (Regel 11). Ist die Bewegung in den Systemeinstellungen abgeschaltet,
/// steht der Kreis still; der Takt — der Wechsel der Wörter nach 4, 2 und 6
/// Sekunden — läuft weiter, denn er ist der Inhalt, nicht die Verzierung.
///
/// Die Zeit kommt aus einem `AnimationController`: In Widgettests läuft sie
/// über `tester.pump(Duration)`, ohne echtes Warten. Er läuft nur, solange
/// man den Takt sieht — im Hintergrund und unter einer verdeckenden Route
/// (etwa der Profilauswahl nach Abwesenheit) hält er an und läuft beim
/// Zurückkommen dort weiter, wo er stand. Bis zur Abnahme von 3.0.25 trieb
/// ihn ein `Timer`, der davon nichts wusste: Nach einer Minute im
/// Hintergrund stand man auf dem Abschluss, die Übung galt als beendet, und
/// der Kreis sprang.
class BreathPacer extends StatefulWidget {
  const BreathPacer({
    required this.exercise,
    required this.onRoundCompleted,
    required this.onFinished,
    super.key,
  });

  final GroundingExercise exercise;

  /// Nach jeder vollen Runde, mit der Zahl der durchlaufenen Runden.
  final ValueChanged<int> onRoundCompleted;

  /// Nach der letzten Runde.
  final VoidCallback onFinished;

  /// Durchmesser des Kreises, voll eingeatmet.
  static const double durchmesser = 240;

  /// So klein ist er ausgeatmet, und so groß steht er ohne Bewegung.
  static const double ausgeatmet = 0.55;
  static const double ohneBewegung = 0.8;

  @override
  State<BreathPacer> createState() => _BreathPacerState();
}

class _BreathPacerState extends State<BreathPacer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final List<GroundingStep> _phasen = [
    for (final step in widget.exercise.steps)
      if (step.breathPhase != null && step.hold != null) step,
  ];

  int get _runden => widget.exercise.pacedRounds ?? 1;

  /// Dauer einer Runde in Millisekunden.
  late final int _rundeMs = _phasen.fold(
    0,
    (summe, step) => summe + step.hold!.inMilliseconds,
  );

  int _phase = 0;
  int _runde = 1;

  /// Fortschritt in der laufenden Phase, 0 bis 1.
  double _t = 0;
  int _volleRunden = 0;
  bool _fertig = false;

  /// Ob die App vorn ist und ob diese Fläche zu sehen ist. Nur wenn beides
  /// gilt, läuft der Takt.
  bool _vorn = true;
  bool _sichtbar = true;

  /// Die ganze Übung als eine Strecke von 0 bis 1 — Runde und Phase werden
  /// daraus abgeleitet. Ein Controller je Phase verlöre bei jedem Wechsel
  /// einen Frame, und über fünf Runden summierte sich das.
  ///
  /// `preserve`: Die Systemeinstellung „Animationen aus“ würde sonst die
  /// Dauer auf einen Bruchteil kürzen — hier ist die Dauer der Inhalt, nicht
  /// die Verzierung.
  late final AnimationController _strecke =
      AnimationController(
          vsync: this,
          duration: Duration(milliseconds: _rundeMs * _runden),
          animationBehavior: AnimationBehavior.preserve,
        )
        ..addListener(_fortschreiben)
        ..addStatusListener(_status);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final zustand = WidgetsBinding.instance.lifecycleState;
    _vorn = zustand == null || zustand == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sichtbar = TickerMode.valuesOf(context).enabled;
    _anpassen();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _vorn = state == AppLifecycleState.resumed;
    _anpassen();
  }

  /// Hält an oder läuft weiter, je nachdem, ob man den Takt gerade sieht.
  /// Weiter heißt: vom erreichten Stand, nicht von vorn.
  void _anpassen() {
    if (_fertig) return;
    if (_vorn && _sichtbar) {
      if (!_strecke.isAnimating) unawaited(_strecke.forward());
    } else if (_strecke.isAnimating) {
      _strecke.stop();
    }
  }

  /// Leitet Runde, Phase und Fortschritt aus der verstrichenen Zeit ab.
  void _fortschreiben() {
    final ms = (_strecke.value * _rundeMs * _runden).round();
    final volle = ms ~/ _rundeMs;
    var rest = ms % _rundeMs;
    var phase = 0;
    while (phase < _phasen.length - 1 &&
        rest >= _phasen[phase].hold!.inMilliseconds) {
      rest -= _phasen[phase].hold!.inMilliseconds;
      phase++;
    }

    while (_volleRunden < volle && _volleRunden < _runden) {
      _volleRunden++;
      widget.onRoundCompleted(_volleRunden);
    }

    setState(() {
      _runde = volle >= _runden ? _runden : volle + 1;
      _phase = volle >= _runden ? _phasen.length - 1 : phase;
      _t = volle >= _runden ? 1 : rest / _phasen[phase].hold!.inMilliseconds;
    });
  }

  void _status(AnimationStatus status) {
    if (status != AnimationStatus.completed || _fertig || !mounted) return;
    _fertig = true;
    while (_volleRunden < _runden) {
      _volleRunden++;
      widget.onRoundCompleted(_volleRunden);
    }
    widget.onFinished();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _strecke.dispose();
    super.dispose();
  }

  /// Wie groß der Kreis in dieser Phase beim Fortschritt `t` ist.
  double _faktor(BreathPhase phase, double t) {
    final weich = Curves.easeInOut.transform(t);
    return switch (phase) {
      BreathPhase.inhale =>
        BreathPacer.ausgeatmet + (1 - BreathPacer.ausgeatmet) * weich,
      BreathPhase.hold => 1,
      BreathPhase.exhale => 1 - (1 - BreathPacer.ausgeatmet) * weich,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final step = _phasen[_phase];
    final color = widget.exercise.color;
    final ohneBewegung = MediaQuery.disableAnimationsOf(context);

    // Das Bild kommt über die eine Bildauflösung des Moduls: Ein späteres
    // gezeichnetes Bild erscheint damit auch hier, nicht nur in den Schritten.
    final bild = GroundingImages.bildFuer(step.imageKey);

    Widget kreis(double faktor) {
      final d = BreathPacer.durchmesser * faktor;
      const rand = 3.0;
      return Container(
        key: const ValueKey('atem-kreis'),
        width: d,
        height: d,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.6),
            width: rand,
          ),
        ),
        child: GroundingBildView(
          bild: bild,
          exercise: widget.exercise,
          size: d - 2 * rand,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SizedBox.square(
              dimension: BreathPacer.durchmesser,
              child: Center(
                child: ohneBewegung
                    ? kreis(BreathPacer.ohneBewegung)
                    : kreis(_faktor(step.breathPhase!, _t)),
              ),
            ),
          ),
        ),
        // Welche Runde: ruhige Punkte, keine Zahl, die man lesen muss.
        ProgressDots(active: _runde, total: _runden, color: color),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Semantics(
            liveRegion: true,
            child: StepTextArea(text: StepView.textOf(l10n, step.textKey)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
