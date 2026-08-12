import 'package:dis_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Die Tagesphase als Wort: „morgens", „mittags", „abends", „nachts".
///
/// Eine Uhrzeit allein beantwortet „wie spät", nicht „wann bin ich". 6:00 und
/// 18:00 sind auf einer Uhr verwechselbar, morgens und abends nicht — und
/// Zeitverlust gehört zum Krankheitsbild.
///
/// Steht hier und nicht in einem Widget, weil die Zeitkarte sie auf zwei
/// Flächen braucht — Anker und Profilauswahl. Sie stammt aus der
/// `TimeOrientationLine`, die die Karte am 7. August 2026 abgelöst hat; das
/// Widget ist weg, die Grenzen bleiben, und zwar an einer Stelle.
String timePhaseOf(AppLocalizations l10n, int hour) {
  if (hour >= 5 && hour < 11) return l10n.timePhaseMorning;
  if (hour >= 11 && hour < 14) return l10n.timePhaseMidday;
  if (hour >= 14 && hour < 18) return l10n.timePhaseAfternoon;
  if (hour >= 18 && hour < 23) return l10n.timePhaseEvening;
  return l10n.timePhaseNight;
}

/// Der Gruß über dem Namen auf dem Anker.
///
/// Dieselben Grenzen wie `timePhaseOf`, nur gröber: Mittag und Nachmittag
/// teilen sich einen Gruß, weil das Deutsche für beide „Guten Tag" hat.
///
/// Nachts wird **nicht** verabschiedet. „Gute Nacht" ist im Deutschen ein
/// Abschied, und wer um drei Uhr nach vorn kommt, kommt an. Dasselbe gilt für
/// „Buonanotte" und „Bonne nuit" — die ARB-Datei hält das als Auflage für
/// spätere Übersetzungen fest.
String greetingOf(AppLocalizations l10n, int hour) {
  if (hour >= 5 && hour < 11) return l10n.greetingMorning;
  if (hour >= 11 && hour < 18) return l10n.greetingDay;
  if (hour >= 18 && hour < 23) return l10n.greetingEvening;
  return l10n.greetingNight;
}

/// Die Tönung, in der der obere Rand des Ankers steht.
///
/// Dieselben Grenzen wie der Gruß, damit Farbe und Wort nie auseinanderlaufen:
/// Wenn oben „Guten Abend" steht, ist der Grund abendlich, und nicht erst eine
/// Stunde später.
///
/// Sie sagt nichts an und sie fordert nichts. Ihre einzige Aufgabe ist, dass
/// der Kopf nicht als Kasten auf der Liste klebt, sondern in die Fläche
/// ausläuft — vorher trennte ihn ein Schatten, und ein Schatten ist eine
/// Kante.
///
/// Deshalb bleibt sie weit unter dem, was Regel 4 der Oberflächen-Richtlinien
/// der Sättigung vorbehält: Der Anker mischt sie mit rund 18 % auf die Fläche
/// und lässt sie nach einem Drittel der Höhe auslaufen. Was gefunden werden
/// muss, wenn es schwer ist, trägt weiter volle Farbe — die drei Knöpfe unten.
/// Ein Hauch im Hintergrund konkurriert damit nicht.
///
/// Der Grund für den Wechsel überhaupt ist derselbe wie bei `timePhaseOf`:
/// Zeitverlust gehört zum Krankheitsbild, und eine Fläche, die morgens anders
/// aussieht als abends, beantwortet „wann bin ich" schon, bevor jemand liest.
Color anchorTintOf(int hour) {
  if (hour >= 5 && hour < 11) return const Color(0xFFE8A33D); // Morgengold
  if (hour >= 11 && hour < 18) return const Color(0xFF4A8FD4); // Tagblau
  if (hour >= 18 && hour < 23) return const Color(0xFF8A5BB8); // Abendpflaume
  return const Color(0xFF3B4A8C); // Nachtindigo
}
