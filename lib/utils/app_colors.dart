import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Zentrale Farbdefinitionen für Aurora.
///
/// Die Farben sind in **zwei Räume** geteilt, die sich nie berühren dürfen:
///
/// * **Identität** — wechselt. Die Wunschfarbe des aktiven Anteils. Sie
///   beantwortet „wer bin ich gerade" und darf alles einfärben, was zu einem
///   Anteil gehört.
/// * **Handlung** — steht fest. Genau drei Bedeutungen: [go], [wait], [signal].
///
/// Der Grund für die Trennung: Aurora soll ohne Lesen bedienbar sein. Wenn
/// Farbe eine Handlung mitträgt, darf dieselbe Farbe nicht gleichzeitig einen
/// Anteil bezeichnen — sonst heißt Grün zweierlei und beides wird unlesbar.
/// Deshalb prüft [isReservedForAction], ob eine gewählte Identitätsfarbe einer
/// Handlungsfarbe zu nahe kommt.
///
/// Die Werte stammen aus dem Bestand, nicht aus einem Neuentwurf: `paper` ist
/// die Farbe, die im Code 127-mal auftauchte, `ink` die häufigste Grundfläche.
/// Zusammengeführt wurden nur die Dubletten — drei fast identische Cremetöne
/// und fünf dunkle Gründe ohne unterscheidbare Aufgabe.
class AppColors {
  AppColors._();

  // ==================== FLÄCHEN ====================

  /// Tiefste Ebene: der Grund, auf dem alles liegt.
  static const Color inkDeep = Color(0xFF0F0F1E);

  /// Grundfläche der App. Häufigster Hintergrundwert im Bestand.
  static const Color ink = Color(0xFF1A1A2E);

  /// Erhöhte Fläche: Karten, Dialoge, Eingabefelder.
  ///
  /// Karten heben sich durch Fläche ab, nicht durch Rahmen. Das ersetzt die
  /// Rahmen-in-Rahmen-Verschachtelung, ohne Information zu verlieren.
  static const Color slate = Color(0xFF232238);

  /// Trennlinien und Umrisse. Nur wo Fläche allein nicht reicht.
  static const Color line = Color(0xFF3A3850);

  // ==================== TEXT ====================

  /// Primärtext und aktive Symbole. Das warme Creme ist Auroras Erkennungsmerkmal.
  static const Color paper = Color(0xFFE8DCC4);

  /// Hervorhebung über [paper] — Überschriften, aktiver Zustand.
  static const Color paperBright = Color(0xFFFFF8F0);

  /// Sekundärtext: Beschriftungen, Zeitangaben, Zusatzinformation.
  static const Color mist = Color(0xFFD4C5B9);

  /// Zurückgenommener Text: Platzhalter, deaktivierte Elemente.
  static const Color faint = Color(0xFF8A8A8A);

  // ==================== HANDLUNG ====================
  // Genau drei Bedeutungen. Diese Farben stehen der Identität nicht zur
  // Verfügung — siehe [isReservedForAction].

  /// Zustimmung: genommen, erledigt, bestätigt, anrufen.
  static const Color go = Color(0xFF7DD3A0);

  /// Aufschub: später, in Bearbeitung, Warnung.
  static const Color wait = Color(0xFFE4B45E);

  /// Ablehnung und Notfall: ausgelassen, Fehler, Notruf.
  ///
  /// Bewusst satt und nicht pastellig: Rosé ist eine etablierte Identitätsfarbe
  /// in Aurora, und ein blasses Korallenrot wäre davon kaum zu trennen.
  static const Color signal = Color(0xFFE5484D);

  /// Abgedunkelte Varianten für Flächen, auf denen [paper] lesbar bleiben muss.
  static const Color goDeep = Color(0xFF2E7D53);
  static const Color waitDeep = Color(0xFF8A5D0C);
  static const Color signalDeep = Color(0xFFA33235);

  // ==================== IDENTITÄT ====================

  /// Vorschlagspalette für Anteile.
  ///
  /// Bewusst im blau-violett-türkis-rosa Bereich: groß genug für viele Anteile
  /// und ohne Berührung mit [go], [wait] und [signal].
  static const List<Color> identityPalette = <Color>[
    Color(0xFF87CEEB), // Himmelblau
    Color(0xFFFFB6C1), // Rosé
    Color(0xFFDDA0DD), // Flieder
    Color(0xFF9B8AE0), // Violett
    Color(0xFF6FC7C4), // Türkis
    Color(0xFF8AA9F0), // Kornblume
    Color(0xFFD98FC0), // Magenta
    Color(0xFFA8C0E8), // Nebelblau
  ];

  /// Fallback, solange kein Anteil aktiv ist.
  static const Color identityFallback = Color(0xFF87CEEB);

  /// Prüft, ob [candidate] einer Handlungsfarbe zu nahe kommt.
  ///
  /// Der Farbwähler schließt solche Töne aus. Verwechselbar sind zwei Farben
  /// erst, wenn **drei** Bedingungen zusammenkommen: ähnlicher Farbwinkel,
  /// ähnliche Helligkeit und genug Sättigung, dass der Ton überhaupt als Farbe
  /// gelesen wird.
  ///
  /// Der Helligkeitsvergleich ist der entscheidende Teil. Ohne ihn fiele Rosé
  /// unter dieselbe Sperre wie ein sattes Rot, obwohl beide nebeneinander
  /// eindeutig unterscheidbar sind — und Rosé ist in Aurora eine der am
  /// häufigsten gewählten Identitätsfarben.
  static bool isReservedForAction(Color candidate) {
    final hsl = HSLColor.fromColor(candidate);
    if (hsl.saturation < 0.25) return false;

    for (final action in <Color>[go, wait, signal]) {
      final actionHsl = HSLColor.fromColor(action);

      final delta = (hsl.hue - actionHsl.hue).abs();
      final hueDistance = delta > 180 ? 360 - delta : delta;
      if (hueDistance >= 25) continue;

      if ((hsl.lightness - actionHsl.lightness).abs() < 0.22) return true;
    }
    return false;
  }

  /// Die Schrift- oder Symbolfarbe, die auf [background] lesbar bleibt.
  ///
  /// Identitätsfarben sind frei wählbar und reichen von fast Schwarz bis
  /// Weiß. Wo Weiß fest als Vordergrund eingetragen war, verschwand der
  /// Inhalt bei hellen Profilen vollständig: die Initiale im Avatar der
  /// Chat-Bubble, das Senden-Symbol im Doodle-Feld. Beide Male blieb eine
  /// leere Fläche stehen, ohne Hinweis, dass dort etwas stehen sollte.
  ///
  /// Gewählt wird, was den größeren Kontrast bringt — nicht, was oberhalb
  /// einer Helligkeitsschwelle liegt. Eine feste Schwelle bei 0.5 Luminanz
  /// entscheidet für mittelhelle Töne falsch: auf Pflaume (#DDA0DD) käme
  /// damit Weiß heraus und erreichte nur 2.1∶1, während Dunkel dort 8∶1
  /// liefert.
  static Color onColor(Color background) {
    const dark = Color(0xFF1C1B1F);
    return _contrastRatio(background, dark) >=
            _contrastRatio(background, Colors.white)
        ? dark
        : Colors.white;
  }

  /// Kontrastverhältnis nach WCAG 2.1, von 1∶1 bis 21∶1.
  static double _contrastRatio(Color a, Color b) {
    final luminanceA = a.computeLuminance();
    final luminanceB = b.computeLuminance();
    final lighter = math.max(luminanceA, luminanceB);
    final darker = math.min(luminanceA, luminanceB);
    return (lighter + 0.05) / (darker + 0.05);
  }

  // ==================== ÜBERGANG ====================
  // Die alten Namen zeigen auf die neuen Werte, damit bestehender Code
  // weiterläuft, während die verstreuten Color(0x…) eingesammelt werden.
  // Nach der Migration ersatzlos entfernen.

  @Deprecated('AppColors.go verwenden')
  static const Color success = go;
  @Deprecated('AppColors.goDeep verwenden')
  static const Color successDark = goDeep;

  @Deprecated('AppColors.signal verwenden')
  static const Color error = signal;
  @Deprecated('AppColors.signalDeep verwenden')
  static const Color errorDark = signalDeep;

  @Deprecated('AppColors.wait verwenden')
  static const Color warning = wait;
  @Deprecated('AppColors.waitDeep verwenden')
  static const Color warningDark = waitDeep;

  /// Neutrale Information. Gehört keinem der beiden Räume an und wird deshalb
  /// aus dem Textraum bedient statt aus einem eigenen Blau.
  @Deprecated('AppColors.mist verwenden')
  static const Color info = mist;
  @Deprecated('AppColors.faint verwenden')
  static const Color infoDark = faint;

  @Deprecated('AppColors.go verwenden')
  static const Color medicationTaken = go;
  @Deprecated('AppColors.signal verwenden')
  static const Color medicationRefused = signal;
  @Deprecated('AppColors.wait verwenden')
  static const Color medicationSnoozed = wait;

  @Deprecated('AppColors.goDeep verwenden')
  static const Color emergencyCall = goDeep;
  @Deprecated('AppColors.waitDeep verwenden')
  static const Color emergencySms = waitDeep;
  @Deprecated('AppColors.mist verwenden')
  static const Color emergencyShare = mist;

  @Deprecated('AppColors.go verwenden')
  static const Color priorityLow = go;
  @Deprecated('AppColors.wait verwenden')
  static const Color priorityMedium = wait;
  @Deprecated('AppColors.signal verwenden')
  static const Color priorityHigh = signal;
  @Deprecated('AppColors.signalDeep verwenden')
  static const Color priorityCritical = signalDeep;

  @Deprecated('AppColors.signal verwenden')
  static const Color ratingVeryNegative = signal;
  @Deprecated('AppColors.signal verwenden')
  static const Color ratingNegative = signal;
  @Deprecated('AppColors.wait verwenden')
  static const Color ratingNeutral = wait;
  @Deprecated('AppColors.go verwenden')
  static const Color ratingPositive = go;
  @Deprecated('AppColors.go verwenden')
  static const Color ratingVeryPositive = go;

  // ==================== OVERLAYS ====================

  static final Color overlayLight = paper.withValues(alpha: 0.08);
  static final Color overlayMedium = paper.withValues(alpha: 0.16);
  static final Color overlayStrong = paper.withValues(alpha: 0.26);

  @Deprecated('AppColors.mist verwenden')
  static const Color textSecondary = mist;
  @Deprecated('AppColors.mist verwenden')
  static const Color textTertiary = mist;
  @Deprecated('AppColors.faint verwenden')
  static const Color textFaint = faint;
  @Deprecated('AppColors.faint verwenden')
  static const Color textDisabled = faint;

  /// Früher `Colors.grey.shade100` — ein nahezu weißer Hintergrund in einer
  /// durchgehend dunklen App. Zeigt jetzt auf die erhöhte Fläche.
  @Deprecated('AppColors.slate verwenden')
  static const Color backgroundDisabled = slate;

  @Deprecated('AppColors.line verwenden')
  static const Color border = line;
  @Deprecated('AppColors.line verwenden')
  static const Color borderLight = line;
}
