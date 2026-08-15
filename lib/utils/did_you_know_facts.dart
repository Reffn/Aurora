import 'dart:math';

import 'package:dis_app/l10n/app_localizations.dart';

/// Die „Wusstest du?"-Sätze auf dem Startbildschirm.
///
/// Sie standen vorher als deutsche Liste im Code. Wer Aurora auf Spanisch
/// stellte, bekam beim Start deutsche Sätze über Dissoziation zu lesen —
/// ausgerechnet die Texte, die erklären sollen, wie die App gedacht ist.
///
/// Sie werden bei jedem Aufruf frisch aus AppLocalizations geholt, damit ein
/// Sprachwechsel sofort wirkt.
class DidYouKnowFacts {
  const DidYouKnowFacts._();

  /// Alle Sätze in der Sprache der Nutzerin.
  static List<String> all(AppLocalizations l10n) => [
    // Über DIS
    l10n.fact01,
    l10n.fact02,
    l10n.fact03,
    l10n.fact04,
    l10n.fact05,

    // Was Aurora kann
    l10n.fact06,
    l10n.fact07,
    l10n.fact08,
    l10n.fact09,
    l10n.fact10,
    l10n.fact11,
    l10n.fact12,
    l10n.fact13,
    l10n.fact14,
    l10n.fact15,
    l10n.fact16,
    l10n.fact17,
    l10n.fact18,
    l10n.fact19,

    // Für den Alltag im System
    l10n.fact20,
    l10n.fact21,
    l10n.fact22,
    l10n.fact23,
    l10n.fact24,
    l10n.fact25,
    l10n.fact26,
    l10n.fact27,
    l10n.fact28,
    l10n.fact29,
    l10n.fact30,

    // Sicherheit
    l10n.fact31,
    l10n.fact32,
    l10n.fact33,
    l10n.fact34,

    // Ermutigung
    l10n.fact35,
    l10n.fact36,
    l10n.fact37,
    l10n.fact38,
  ];

  /// Wie viele Sätze es gibt.
  ///
  /// Wird gebraucht, wo ein Satz ausgewählt wird, bevor die Sprache
  /// feststeht — die Anzahl ist in jeder Sprache dieselbe.
  static const int count = 38;

  /// Gibt eine zufällig gemischte Liste zurück.
  static List<String> getShuffled(AppLocalizations l10n) {
    final shuffled = all(l10n);
    shuffled.shuffle();
    return shuffled;
  }

  /// Gibt einen einzelnen zufälligen Satz zurück.
  static String getRandom(AppLocalizations l10n) {
    final facts = all(l10n);
    return facts[Random().nextInt(facts.length)];
  }
}
