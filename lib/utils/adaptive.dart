import 'package:flutter/material.dart';

/// Adaptive sizing utilities für kontinuierlich responsive UI
/// Passt sich flüssig an jede Bildschirmgröße an (keine harten Breakpoints)
class Adaptive {
  // Baseline für Skalierung (iPhone SE Breite)
  static const double _baselineWidth = 375;

  /// Bildschirmbreite
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Bildschirmhöhe
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Prozentuale Breite (0-100)
  /// Beispiel: `Adaptive.w(context, 50)` = 50% der Bildschirmbreite
  static double w(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  /// Prozentuale Höhe (0-100)
  /// Beispiel: `Adaptive.h(context, 10)` = 10% der Bildschirmhöhe
  static double h(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  /// Responsive Font-Größe (skaliert mit Bildschirmbreite)
  /// Basis: 375px (iPhone SE)
  /// Clamp: 0.8x - 1.5x (verhindert zu kleine/große Fonts)
  static double fontSize(BuildContext context, double baseFontSize) {
    final width = screenWidth(context);
    final scale = width / _baselineWidth;
    return baseFontSize * scale.clamp(0.8, 1.5);
  }

  /// Responsive Spacing (skaliert mit Bildschirmbreite)
  /// Clamp: 0.8x - 1.3x
  static double spacing(BuildContext context, double baseSpacing) {
    final width = screenWidth(context);
    final scale = width / _baselineWidth;
    return baseSpacing * scale.clamp(0.8, 1.3);
  }

  /// Responsive Icon-Größe (skaliert mit Bildschirmbreite)
  /// Clamp: 0.85x - 1.4x
  static double iconSize(BuildContext context, double baseIconSize) {
    final width = screenWidth(context);
    final scale = width / _baselineWidth;
    return baseIconSize * scale.clamp(0.85, 1.4);
  }

  /// Responsive Padding (EdgeInsets mit adaptivem Spacing)
  static EdgeInsets padding(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(spacing(context, all));
    }

    return EdgeInsets.only(
      left: spacing(context, left ?? horizontal ?? 0),
      top: spacing(context, top ?? vertical ?? 0),
      right: spacing(context, right ?? horizontal ?? 0),
      bottom: spacing(context, bottom ?? vertical ?? 0),
    );
  }

  /// Responsive BorderRadius
  static BorderRadius borderRadius(BuildContext context, double baseRadius) {
    return BorderRadius.circular(spacing(context, baseRadius));
  }

  /// Scale Factor (für custom Berechnungen)
  /// 1.0 = 375px Breite (Baseline)
  static double scaleFactor(BuildContext context) {
    return screenWidth(context) / _baselineWidth;
  }

  /// Ist Display klein? (< 400px Breite)
  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < 400;
  }

  /// Ist Display groß? (> 800px Breite)
  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) > 800;
  }
}
