import 'package:flutter/material.dart';

/// Zentrale Spacing-Konstanten für Aurora
///
/// Verwendet ein 4px-Grid-System für konsistenten visuellen Rhythmus.
/// Alle Werte sind Vielfache von 4 für harmonische Layouts.
///
/// **Verwendung:**
/// ```dart
/// // Padding
/// Padding(
///   padding: AppSpacing.paddingAll,  // EdgeInsets.all(16)
///   child: ...
/// )
///
/// // SizedBox
/// SizedBox(height: AppSpacing.medium)  // 12.0
///
/// // Border Radius
/// BorderRadius.circular(AppSpacing.radiusMedium)  // 12.0
/// ```
class AppSpacing {
  AppSpacing._(); // Private constructor

  // Spacing Values (4px Grid)
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Legacy aliases (für Kompatibilität)
  static const double tiny = xs; // 4
  static const double small = sm; // 8
  static const double medium = md; // 12
  static const double standard = lg; // 16
  static const double large = xxl; // 24
  static const double extraLarge = xxxl; // 32

  // Border Radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;

  // Legacy aliases
  static const double radiusSmall = radiusSm;
  static const double radiusMedium = radiusMd;
  static const double radiusLarge = radiusLg;

  // Common EdgeInsets
  static const EdgeInsets paddingAll = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);

  static const EdgeInsets paddingH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingV = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVLg = EdgeInsets.symmetric(vertical: lg);

  // Card/Container padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  // List item spacing
  static const EdgeInsets listItemPadding = paddingAll;
  static const EdgeInsets listItemPaddingH = paddingH;

  // Bottom margin for lists (safe area compatible)
  static const double listBottomPadding = xxl;

  // Section spacing
  static const double sectionSpacing = xxl;
  static const double widgetSpacing = lg;
  static const double elementSpacing = sm;
}
