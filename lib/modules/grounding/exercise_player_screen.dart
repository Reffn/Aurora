import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/modules/emergency/emergency_screen.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/modules/grounding/widgets/breath_pacer.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_done_sheet.dart';
import 'package:dis_app/modules/grounding/widgets/step_view.dart';
import 'package:dis_app/modules/help/help_resources_screen.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:flutter/material.dart';

/// Ab dieser Strecke gilt ein Zug als Wisch. Gemessen wird der Weg, nicht
/// die Geschwindigkeit: Im dissoziativen Zustand sind Gesten langsam, und
/// ein Schwellwert auf Tempo ließe genau diese Hände durchfallen.
const double _swipeDistance = 60;

/// Führt durch eine Erdungsübung
///
/// Der Zustand lebt nur hier. Nichts wird gespeichert, nichts protokolliert.
/// Wer die App mitten in der Übung verlässt, landet beim nächsten Start auf
/// der Übersicht — ein „willst du weitermachen?" wäre in dem Zustand eine
/// Zumutung.
///
/// Drei Wege nach vorn, alle gleichwertig: die ganze Fläche tippen, nach
/// links wischen, oder der Knopf unten mit Pfeil und Wort. Gerätebefund:
/// Ein Schritt zeigte Bild, Satz und Punkte, und nichts zeigte den Weg
/// weiter — die Punkte legten Wischen nahe, Wischen tat nichts. Wer nicht
/// weiterkam, drückte Zurück, und das zählte als Abbruch: sieben auf drei
/// Abschlüsse beim Hauptknopf. Jede Geste hat jetzt einen sichtbaren Knopf
/// (Richtlinie 8), und das Bild trägt ihn (Richtlinie 5).
class ExercisePlayerScreen extends StatefulWidget {
  const ExercisePlayerScreen({
    required this.exercise,
    this.clock = DateTime.now,
    super.key,
  });

  final GroundingExercise exercise;

  /// Die Uhr. Hereingereicht, damit Tests sie stellen können — und damit
  /// die Zeit auf dem Orientierungsschritt weiterläuft: Vorher stand
  /// `DateTime.now()` nur im build, und wer eine Minute dort blieb, sah
  /// eine stehende Uhr. Für eine Übung, die „jetzt" sagt, ist das falsch.
  final DateTime Function() clock;

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  int _index = 0;
  bool _done = false;

  /// Ob schon einmal weitergegangen wurde. Der Hinweis-Puls am Weiter-Knopf
  /// gilt nur dem allerersten Schritt, bis klar ist, wie es weitergeht.
  bool _advancedOnce = false;

  late DateTime _now = widget.clock();
  Timer? _ticker;
  double _dragDx = 0;

  /// Nur im Takt (Atem): wie viele volle Runden durchlaufen sind, ob für
  /// dieses Öffnen schon gemeldet wurde, und der wievielte Durchlauf es ist
  /// (für „Nochmal“).
  int _volleRunden = 0;
  bool _gemeldet = false;
  int _durchlauf = 0;

  bool get _takt => widget.exercise.pacedRounds != null;

  @override
  void initState() {
    super.initState();
    // Sekündlich nachsehen, aber nur bei neuer Minute neu bauen — die
    // Anzeige kennt keine Sekunden.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = widget.clock();
    final sameMinute =
        now.year == _now.year &&
        now.month == _now.month &&
        now.day == _now.day &&
        now.hour == _now.hour &&
        now.minute == _now.minute;
    if (sameMinute) return;
    setState(() => _now = now);
  }

  void _next() {
    _advancedOnce = true;
    if (_index >= widget.exercise.steps.length - 1) {
      // Gemessen wird nicht, ob es geholfen hat, sondern ob es tragbar war.
      // Nach Wirkung wird nicht gefragt — eine Selbsteinschätzung direkt nach
      // einer Krise wäre ein Gesundheitsdatum feinster Körnung.
      _recordTelemetry('beendet');
      setState(() => _done = true);
      return;
    }
    setState(() => _index++);
  }

  /// Meldet den Takt, höchstens einmal je Öffnen.
  ///
  /// Definition für die Atemübung: `uebung_beendet_breath`, sobald beim
  /// Verlassen oder Beenden mindestens eine volle Runde durchlaufen ist;
  /// `uebung_abgebrochen_breath`, wenn vor dem Ende der ersten Runde
  /// verlassen wird. Danach — auch nach „Nochmal“ — kein weiteres Ereignis:
  /// Mehrere Ereignisse je Öffnen ergäben eine Folge, und eine Folge verrät
  /// mehr als eine Zahl.
  void _taktMelden() {
    if (_gemeldet) return;
    _gemeldet = true;
    _recordTelemetry(_volleRunden >= 1 ? 'beendet' : 'abgebrochen');
  }

  /// „Fertig“ oder das Ende der letzten Runde: zum Abschluss.
  void _taktBeenden() {
    _taktMelden();
    setState(() => _done = true);
  }

  @override
  void dispose() {
    if (_takt) {
      _taktMelden();
    } else if (!_done) {
      // Wer die Übung verlässt, bevor sie zu Ende ist, hat abgebrochen. Nach
      // „nochmal" steht `_done` wieder auf false — dann zählt der Abbruch der
      // Wiederholung, und das ist richtig so.
      _recordTelemetry('abgebrochen');
    }
    _ticker?.cancel();
    super.dispose();
  }

  /// Ein Wisch nach links geht weiter, nach rechts zurück — nie aus der
  /// Übung hinaus: Auf dem ersten Schritt tut ein Wisch nach rechts nichts.
  /// Ein versehentliches Verlassen wäre genau der Abbruch, der hier
  /// verhindert werden soll; der Rückweg bleibt der Pfeil oben links.
  void _onDragEnd(DragEndDetails _) {
    final dx = _dragDx;
    _dragDx = 0;
    if (dx <= -_swipeDistance) {
      _next();
    } else if (dx >= _swipeDistance && _index > 0) {
      _back();
    }
  }

  /// Meldet ein Ereignis, wenn Name und Dienst dafür bereitstehen.
  ///
  /// `null` heißt: Diese Übung hat kein Ereignis in der Whitelist — dann wird
  /// nichts gemeldet statt etwas Falsches. Die Registrierungsprüfung ist
  /// nötig, weil dieser Schirm auch ohne eingerichtete Dependency Injection
  /// gebaut werden kann; im Widget-Test ist genau das der Normalfall.
  void _recordTelemetry(String outcome) {
    final name = TelemetryEventName.fromWireName(
      'uebung_${outcome}_${widget.exercise.id}',
    );
    if (name == null) return;
    if (!getIt.isRegistered<TelemetryRecorder>()) return;
    unawaited(getIt<TelemetryRecorder>().record(name));
  }

  void _back() {
    if (_takt || _index == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _index--);
  }

  void _again() {
    setState(() {
      _index = 0;
      _done = false;
      _volleRunden = 0;
      _durchlauf++;
    });
  }

  void _other() => Navigator.of(context).pop();

  /// Führt in den Notfallbereich. Fehlt das Recht, zu den Hotlines — die
  /// gehören keinem Profil und brauchen keines. Der Knopf zeigt nie ins Leere.
  void _call() {
    final profile = getIt<DataEntry>().getActiveProfile();
    final mayCall =
        profile?.hasPermission(Permission.callEmergencyContacts) ?? false;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            mayCall ? const EmergencyScreen() : const HelpResourcesScreen(),
      ),
    );
  }

  /// Der Atem als Takt: Kreis und Wort laufen von selbst, „Fertig“ steht
  /// jederzeit unten (Regel 10 — kein Ablauf ohne Ausgang), der Pfeil oben
  /// links führt hinaus wie bei jeder Übung.
  Widget _buildTakt() {
    // Gemeldet wird im Moment des Verlassens, nicht erst beim Aufräumen:
    // Während die Route hinausgleitet, läuft der Takt noch ein paar hundert
    // Millisekunden weiter — eine Runde, die dabei voll würde, hat niemand
    // geatmet. Gilt für den Pfeil oben links und die Zurück-Taste.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _taktMelden();
      },
      child: _buildTaktFlaeche(),
    );
  }

  Widget _buildTaktFlaeche() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: BreathPacer(
                      key: ValueKey('grounding-breath-$_durchlauf'),
                      exercise: widget.exercise,
                      onRoundCompleted: (runden) => _volleRunden = runden,
                      onFinished: _taktBeenden,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: IconButton(
                      key: const ValueKey('grounding-back'),
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: _back,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _NextButton(
                key: const ValueKey('grounding-breath-finish'),
                isLast: true,
                color: widget.exercise.color,
                pulse: false,
                onTap: _taktBeenden,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ExerciseDoneSheet(
                  onAgain: _again,
                  onOther: _other,
                  onCall: _call,
                  color: widget.exercise.color,
                ),
              ),
              // Auch hier muss ein sichtbarer Weg zurück sein. Wer keine der
              // drei Möglichkeiten will, darf nicht auf die Systemtaste
              // angewiesen sein.
              Positioned(
                left: 8,
                top: 8,
                child: IconButton(
                  key: const ValueKey('grounding-done-back'),
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: _other,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_takt) return _buildTakt();

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isLast = _index >= widget.exercise.steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Die ganze Fläche ist das Ziel. Kein kleiner Knopf —
                  // und zusätzlich der Wisch, den die Punkte versprechen.
                  GestureDetector(
                    key: const ValueKey('grounding-step-surface'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _next,
                    onHorizontalDragStart: (_) => _dragDx = 0,
                    onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
                    onHorizontalDragEnd: _onDragEnd,
                    child: SizedBox.expand(
                      // Ein kurzes Überblenden zeigt, dass sich etwas
                      // bewegt hat — endlich, nicht wiederholend, und bei
                      // abgeschalteter Bewegung ein harter Wechsel.
                      child: AnimatedSwitcher(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 220),
                        child: StepView(
                          key: ValueKey('grounding-step-$_index'),
                          exercise: widget.exercise,
                          index: _index,
                          now: _now,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: IconButton(
                      key: const ValueKey('grounding-back'),
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: _back,
                    ),
                  ),
                ],
              ),
            ),
            // Der sichtbare Weg nach vorn. Unten, wo der Daumen ohnehin
            // liegt; Pfeil und Wort; auf dem letzten Schritt ein Haken.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _NextButton(
                key: const ValueKey('grounding-next'),
                isLast: isLast,
                color: widget.exercise.color,
                pulse: _index == 0 && !_advancedOnce && !reduceMotion,
                onTap: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Der Weiter-Knopf unter der Fläche
///
/// Auf dem ersten Schritt atmet der Pfeil dreimal leise — ein Hinweis,
/// kein Alarm — und hört dann auf. Endlich, weil ein Puls ohne Ende jeden
/// Test anhält und auf Dauer nicht Hinweis, sondern Unruhe ist. Die Farbe
/// ist die der Übung, gedämpft wie beim großen Anker: Dies ist der Halt-
/// Bereich, hier bleibt alles ruhig (Richtlinie 4).
class _NextButton extends StatefulWidget {
  const _NextButton({
    required this.isLast,
    required this.color,
    required this.pulse,
    required this.onTap,
    super.key,
  });

  final bool isLast;
  final Color color;
  final bool pulse;
  final VoidCallback onTap;

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: 1.06,
  ).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      // Gerade Zahl: Jeder Durchlauf ist eine Richtung, und der Knopf soll
      // in Normalgröße zur Ruhe kommen, nicht halb geschwollen stehen
      // bleiben. Drei Atemzüge hin und zurück, dann Ruhe.
      unawaited(
        _controller
            .repeat(reverse: true, count: 6)
            .then((_) => _controller.value = 0),
      );
    }
  }

  @override
  void didUpdateWidget(covariant _NextButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.pulse && oldWidget.pulse) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scale,
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: FilledButton.tonalIcon(
          onPressed: widget.onTap,
          style: FilledButton.styleFrom(
            backgroundColor: widget.color.withValues(alpha: 0.18),
            foregroundColor: scheme.onSurface,
            side: BorderSide(color: widget.color.withValues(alpha: 0.6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: Icon(
            widget.isLast ? Icons.check : Icons.arrow_forward,
            size: 28,
          ),
          label: Text(
            widget.isLast ? l10n.actionDone : l10n.actionContinue,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
