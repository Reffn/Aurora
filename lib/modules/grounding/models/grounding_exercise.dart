import 'package:flutter/material.dart';

/// Eine Erdungsübung
///
/// Reines Dart, keine Hive-Annotation, keine Generierung. Übungen sind
/// Konstanten im Code — das Modul speichert nichts und liest nichts.
@immutable
class GroundingExercise {
  const GroundingExercise({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.steps,
    this.pacedRounds,
  });

  /// Stabile Kennung, z. B. 'orientation'. Wird nicht angezeigt.
  final String id;

  /// Schlüssel für den Titel in den ARB-Dateien
  final String titleKey;

  /// Symbol der Übung. Springt ein, wenn ein Bild fehlt.
  final IconData icon;

  final Color color;

  final List<GroundingStep> steps;

  /// Läuft die Übung als durchgehender Takt statt als Schrittfolge, steht
  /// hier die Zahl der Runden; `null` heißt Schrittfolge.
  ///
  /// Ein Takt durchläuft die Schritte mit [GroundingStep.breathPhase] je
  /// Runde einmal, jeden so lange wie sein [GroundingStep.hold], ohne Tippen
  /// (`BreathPacer`). Bis 3.0.24 war auch der Atem eine Schrittfolge: Wer
  /// atmete, musste mitten im Atemzug tippen.
  final int? pacedRounds;
}

/// Was der Atem in einer Phase des Takts tut. Der Kreis folgt ihr.
enum BreathPhase { inhale, hold, exhale }

/// Ein Schritt innerhalb einer Übung
@immutable
class GroundingStep {
  const GroundingStep({
    required this.imageKey,
    required this.textKey,
    this.hold,
    this.showsCurrentDateTime = false,
    this.breathPhase,
  });

  /// Schlüssel, nie ein Pfad. Aufgelöst über [GroundingImages].
  final String imageKey;

  /// Schlüssel für den Text in den ARB-Dateien. Der Text bestätigt nur,
  /// was das Bild bereits gesagt hat.
  final String textKey;

  /// Optionale Verweildauer. Zeichnet einen Ring, blockiert aber nie das
  /// Weitertippen — kein Timer darf weglaufen, während jemand weg ist.
  final Duration? hold;

  /// Nur der erste Schritt der Orientierungsübung zeigt echtes Datum und
  /// echte Uhrzeit. Der einzige dynamische Inhalt im ganzen Modul.
  final bool showsCurrentDateTime;

  /// Nur in einem Takt ([GroundingExercise.pacedRounds]): Einatmen, Halten
  /// oder Ausatmen. Die Dauer ist [hold].
  final BreathPhase? breathPhase;
}
