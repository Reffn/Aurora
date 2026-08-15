import 'package:flutter/material.dart';

/// Konstanten für die Karussell-Navigation
/// Zentralisiert alle Magic Numbers für bessere Wartbarkeit
class CarouselConstants {
  // Private Constructor (Utility-Klasse)
  CarouselConstants._();

  // === Swipe-Gesten ===
  /// Minimale Swipe-Geschwindigkeit als Prozent der Bildschirmbreite pro Sekunde
  /// Beispiel: 15.0 = schnellerer Response für Swipe-Only Navigation
  /// → Screen-unabhängig, gleiches Swipe-Gefühl auf allen Geräten
  static const double swipeVelocityThreshold = 15;

  /// Minimaler Swipe-Abstand (als Prozent der Bildschirmbreite)
  static const double swipeDragThreshold = 0.10; // 10% der Bildschirmbreite

  // === Layout ===
  /// Höhe der Karussell-Navigation (in % der Bildschirmhöhe)
  static const double navigationHeight = 10;

  /// Breite eines Tab-Items (in % der Bildschirmbreite)
  /// Gestaffelt basierend auf Distanz zum aktiven Tab
  static const double tabWidthActive = 25; // Distance 0 (Mitte)
  static const double tabWidthNear = 18; // Distance 1 (±1)
  static const double tabWidthFar = 12; // Distance 2+ (weit weg)

  /// Durchschnittliches Spacing für Swipe-Berechnungen
  /// Verwendet Durchschnitt aus distance-basierten Spacings (23+17+14)/3 ≈ 18
  static const double tabWidthWithMargins = 20;

  // === Abstände ===
  /// Horizontaler Abstand zwischen Tabs
  static const double tabHorizontalMargin = 4;

  /// Vertikaler Padding innerhalb der Tabs
  static const double tabVerticalPadding = 10;

  /// Horizontaler Padding innerhalb der Tabs
  static const double tabHorizontalPadding = 4;

  /// Abstand zwischen Icon und Label
  static const double iconLabelSpacing = 6;

  // === Skalierung & Opacity ===
  /// Reduzierung der Skalierung pro Distanz-Einheit (0-1)
  /// Verstärkt für klarere visuelle Hierarchie
  static const double scaleDistanceFactor = 0.25;

  /// Reduzierung der Opacity pro Distanz-Einheit (0-1)
  static const double opacityDistanceFactor = 0.25;

  /// Minimale Skalierung für weit entfernte Tabs
  /// Kleiner für mehr sichtbare Tabs und klarere Mitte-Markierung
  static const double minScale = 0.45;

  /// Maximale Skalierung für aktiven Tab
  static const double maxScale = 1;

  /// Minimale Opacity für weit entfernte Tabs
  static const double minOpacity = 0.4;

  /// Maximale Opacity für aktiven Tab
  static const double maxOpacity = 1;

  /// Distanz-Schwellenwert für "aktiv" Status (0.0 = exakt aktiv)
  /// WICHTIG: Muss < 0.5 sein, sonst können 2 Tabs gleichzeitig aktiv sein!
  /// Bei 0.4: Nur der Tab im Zentrum (distance < 0.4) wird hervorgehoben
  static const double activeDistanceThreshold = 0.4;

  // === Icon & Text ===
  /// Icon-Größe für aktiven Tab
  static const double iconSizeActive = 28;

  /// Icon-Größe für inaktive Tabs
  static const double iconSizeInactive = 22;

  /// Schriftgröße für aktiven Tab
  static const double fontSizeActive = 12;

  /// Schriftgröße für inaktive Tabs
  static const double fontSizeInactive = 10;

  // === Rahmen & Schatten ===
  /// Border-Radius der Tab-Karten
  static const double borderRadius = 16;

  /// Border-Breite für aktiven Tab
  static const double borderWidthActive = 2.5;

  /// Border-Breite für inaktive Tabs
  static const double borderWidthInactive = 1;

  /// Blur-Radius für Schatten unter der Navigation
  static const double shadowBlurRadius = 20;

  /// Offset Y für Schatten
  static const double shadowOffsetY = 8;

  /// Blur-Radius für aktiven Tab-Glow
  static const double glowBlurRadius = 15;

  /// Spread-Radius für aktiven Tab-Glow
  static const double glowSpreadRadius = 2;

  // === Animationen ===
  /// Dauer für Page-Wechsel Animationen
  static const Duration pageAnimationDuration = Duration(milliseconds: 400);

  /// Dauer für Container-Transformationen
  static const Duration containerAnimationDuration = Duration(
    milliseconds: 300,
  );

  /// Kurve für Page-Wechsel
  static const Curve pageAnimationCurve = Curves.easeInOutCubic;

  /// Kurve für Container-Transformationen
  static const Curve containerAnimationCurve = Curves.easeOut;

  // === Farben (Opacity-Werte) ===
  /// Opacity für Hintergrund-Glow (äußerer Ring)
  static const double glowOpacityOuter = 0.05;

  /// Opacity für Hintergrund-Glow (mittlerer Ring)
  static const double glowOpacityMiddle = 0.15;

  /// Opacity für aktiven Tab-Hintergrund
  static const double activeTabBackgroundOpacity = 0.25;

  /// Opacity für inaktiven Tab-Hintergrund
  static const double inactiveTabBackgroundOpacity = 0.6;

  /// Opacity für aktiven Tab-Border
  static const double activeBorderOpacity = 0.6;

  /// Opacity für inaktiven Tab-Border
  static const double inactiveBorderOpacity = 0.1;

  /// Opacity für inaktive Icons/Labels
  static const double inactiveContentOpacity = 0.7;

  /// Opacity für Schatten
  static const double shadowOpacity = 0.3;
}
