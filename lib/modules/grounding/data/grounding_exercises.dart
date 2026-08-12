import 'package:dis_app/modules/grounding/models/grounding_exercise.dart';
import 'package:flutter/material.dart';

/// Die fünf Erdungsübungen
///
/// Abgeleitet aus dem Programm *Finding Solid Ground* und den ISSTD-Leitlinien
/// zu Phase 1. Statische Inhaltsliste nach dem Muster von
/// `lib/utils/did_you_know_facts.dart`.
abstract final class GroundingExercises {
  static const List<GroundingExercise> all = [
    _orientation,
    _senses,
    _body,
    _container,
    _breath,
  ];

  /// Die Übung hinter dem großen Anker. Wer nicht wählen kann, landet hier.
  static GroundingExercise get anchor => _orientation;

  /// Die Atemübung.
  ///
  /// Öffentlich, weil „Spiele & Entspannung" denselben Weg anbietet: Dort
  /// stand „Atemübungen" lange als „Bald", während es sie hier längst gab.
  static GroundingExercise get breath => _breath;

  /// Alle Übungen außer der hinter dem großen Knopf
  ///
  /// Die Übersicht zeigt den großen Knopf und darunter die Kacheln. Wäre die
  /// Ankerübung auch als Kachel dabei, stünden zwei Wege mit demselben Symbol
  /// direkt untereinander — und wer das sieht, sucht nach einem Unterschied,
  /// den es nicht gibt.
  static List<GroundingExercise> get others =>
      all.where((e) => e.id != anchor.id).toList();

  static const _orientation = GroundingExercise(
    id: 'orientation',
    titleKey: 'groundingOrientationTitle',
    icon: Icons.explore,
    color: Color(0xFF4DB6AC),
    steps: [
      GroundingStep(
        imageKey: 'calendar_today',
        textKey: 'groundingOrientationStep1',
        showsCurrentDateTime: true,
      ),
      GroundingStep(
        imageKey: 'look_around',
        textKey: 'groundingOrientationStep2',
      ),
      GroundingStep(imageKey: 'name_tag', textKey: 'groundingOrientationStep3'),
      GroundingStep(
        imageKey: 'grown_body',
        textKey: 'groundingOrientationStep4',
      ),
      GroundingStep(
        imageKey: 'past_behind',
        textKey: 'groundingOrientationStep5',
      ),
      GroundingStep(
        imageKey: 'you_are_here',
        textKey: 'groundingOrientationStep6',
      ),
    ],
  );

  static const _senses = GroundingExercise(
    id: 'senses',
    titleKey: 'groundingSensesTitle',
    icon: Icons.visibility,
    color: Color(0xFF64B5F6),
    steps: [
      GroundingStep(imageKey: 'sense_eye', textKey: 'groundingSensesStep1'),
      GroundingStep(imageKey: 'sense_ear', textKey: 'groundingSensesStep2'),
      GroundingStep(imageKey: 'sense_touch', textKey: 'groundingSensesStep3'),
      GroundingStep(imageKey: 'sense_nose', textKey: 'groundingSensesStep4'),
      GroundingStep(imageKey: 'sense_mouth', textKey: 'groundingSensesStep5'),
      GroundingStep(imageKey: 'you_are_here', textKey: 'groundingSensesStep6'),
    ],
  );

  static const _body = GroundingExercise(
    id: 'body',
    titleKey: 'groundingBodyTitle',
    icon: Icons.accessibility_new,
    color: Color(0xFF81C784),
    steps: [
      GroundingStep(imageKey: 'feet_ground', textKey: 'groundingBodyStep1'),
      GroundingStep(imageKey: 'press_down', textKey: 'groundingBodyStep2'),
      GroundingStep(imageKey: 'hand_ice', textKey: 'groundingBodyStep3'),
      GroundingStep(
        imageKey: 'hold_tight',
        textKey: 'groundingBodyStep4',
        hold: Duration(seconds: 20),
      ),
      GroundingStep(imageKey: 'back_chair', textKey: 'groundingBodyStep5'),
      GroundingStep(imageKey: 'ground_holds', textKey: 'groundingBodyStep6'),
    ],
  );

  static const _container = GroundingExercise(
    id: 'container',
    titleKey: 'groundingContainerTitle',
    icon: Icons.inventory_2,
    color: Color(0xFFBA68C8),
    steps: [
      GroundingStep(
        imageKey: 'container_empty',
        textKey: 'groundingContainerStep1',
      ),
      GroundingStep(
        imageKey: 'container_lid',
        textKey: 'groundingContainerStep2',
      ),
      GroundingStep(
        imageKey: 'container_fill',
        textKey: 'groundingContainerStep3',
      ),
      GroundingStep(
        imageKey: 'container_closed',
        textKey: 'groundingContainerStep4',
      ),
      GroundingStep(
        imageKey: 'container_shelf',
        textKey: 'groundingContainerStep5',
      ),
      GroundingStep(
        imageKey: 'container_key',
        textKey: 'groundingContainerStep6',
      ),
    ],
  );

  static const _breath = GroundingExercise(
    id: 'breath',
    titleKey: 'groundingBreathTitle',
    icon: Icons.air,
    color: Color(0xFF9FA8DA),
    steps: [
      GroundingStep(
        imageKey: 'breath_in',
        textKey: 'groundingBreathStep1',
        hold: Duration(seconds: 4),
      ),
      GroundingStep(
        imageKey: 'breath_hold',
        textKey: 'groundingBreathStep2',
        hold: Duration(seconds: 2),
      ),
      GroundingStep(
        imageKey: 'breath_out',
        textKey: 'groundingBreathStep3',
        hold: Duration(seconds: 6),
      ),
      GroundingStep(imageKey: 'breath_repeat', textKey: 'groundingBreathStep4'),
      GroundingStep(imageKey: 'breath_done', textKey: 'groundingBreathStep5'),
    ],
  );
}
