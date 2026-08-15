import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/telemetry_event.dart';
import 'package:dis_app/modules/emergency/emergency_screen.dart';
import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:dis_app/modules/grounding/widgets/exercise_done_sheet.dart';
import 'package:dis_app/modules/grounding/widgets/step_view.dart';
import 'package:dis_app/modules/help/help_resources_screen.dart';
import 'package:dis_app/services/telemetry_recorder.dart';
import 'package:flutter/material.dart';

/// Führt durch eine Erdungsübung
///
/// Der Zustand lebt nur hier. Nichts wird gespeichert, nichts protokolliert.
/// Wer die App mitten in der Übung verlässt, landet beim nächsten Start auf
/// der Übersicht — ein „willst du weitermachen?" wäre in dem Zustand eine
/// Zumutung.
class ExercisePlayerScreen extends StatefulWidget {
  const ExercisePlayerScreen({required this.exercise, super.key});

  final GroundingExercise exercise;

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  int _index = 0;
  bool _done = false;

  void _next() {
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

  @override
  void dispose() {
    // Wer die Übung verlässt, bevor sie zu Ende ist, hat abgebrochen. Nach
    // „nochmal" steht `_done` wieder auf false — dann zählt der Abbruch der
    // Wiederholung, und das ist richtig so.
    if (!_done) {
      _recordTelemetry('abgebrochen');
    }
    super.dispose();
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
    if (_index == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _index--);
  }

  void _again() {
    setState(() {
      _index = 0;
      _done = false;
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Die ganze Fläche ist das Ziel. Kein kleiner Knopf.
            GestureDetector(
              key: const ValueKey('grounding-step-surface'),
              behavior: HitTestBehavior.opaque,
              onTap: _next,
              child: SizedBox.expand(
                child: StepView(
                  exercise: widget.exercise,
                  index: _index,
                  now: DateTime.now(),
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
    );
  }
}
