import 'package:flutter/material.dart';

/// Extension für sicheres Bottom-Padding auf allen Geräten
///
/// Berechnet automatisch das benötigte Padding basierend auf:
/// - System UI (Navigation Bar, Home Indicator)
/// - Keyboard Insets
/// - Extra Breathing Room
///
/// **Usage:**
/// ```dart
/// ListView(
///   padding: EdgeInsets.only(bottom: context.safeBottomPadding),
///   children: [...],
/// )
/// ```
extension SafeBottomPadding on BuildContext {
  /// Bottom Padding das Safe Area + Keyboard + Extra Margin berücksichtigt
  ///
  /// Setzt sich zusammen aus:
  /// - `viewPadding.bottom`: System UI (Navigation Bar, Home Indicator)
  /// - `viewInsets.bottom`: Keyboard Höhe (wenn geöffnet)
  /// - `16px`: Extra Breathing Room
  double get safeBottomPadding {
    final mediaQuery = MediaQuery.of(this);
    final viewPadding = mediaQuery.viewPadding.bottom;
    final viewInsets = mediaQuery.viewInsets.bottom;

    // viewInsets.bottom ist 0 wenn Keyboard zu, > 0 wenn Keyboard offen
    // viewPadding.bottom ist die System UI Höhe (Navigation Bar, Home Indicator)
    // Bei geöffnetem Keyboard: Nur viewInsets verwenden (enthält bereits viewPadding)
    // Bei geschlossenem Keyboard: viewPadding + breathing room verwenden
    if (viewInsets > 0) {
      return viewInsets + 16; // Keyboard offen: Keyboard Höhe + 16px
    } else {
      return viewPadding + 16; // Keyboard zu: System UI + 16px
    }
  }

  /// Minimales Bottom Padding ohne extra Margin (nur Safe Area)
  ///
  /// Verwende dies wenn du selbst die Margin kontrollieren willst
  double get safeBottomPaddingMinimal {
    final mediaQuery = MediaQuery.of(this);
    final viewPadding = mediaQuery.viewPadding.bottom;
    final viewInsets = mediaQuery.viewInsets.bottom;

    if (viewInsets > 0) {
      return viewInsets;
    } else {
      return viewPadding;
    }
  }

  /// Custom Bottom Padding mit konfigurierbarem Extra Margin
  ///
  /// **Usage:**
  /// ```dart
  /// padding: EdgeInsets.only(
  ///   bottom: context.safeBottomPaddingWithMargin(32),
  /// )
  /// ```
  double safeBottomPaddingWithMargin(double margin) {
    final mediaQuery = MediaQuery.of(this);
    final viewPadding = mediaQuery.viewPadding.bottom;
    final viewInsets = mediaQuery.viewInsets.bottom;

    if (viewInsets > 0) {
      return viewInsets + margin;
    } else {
      return viewPadding + margin;
    }
  }

  /// Bottom Padding für Listen, über denen ein FloatingActionButton schwebt.
  ///
  /// Der FAB liegt global im Scaffold in `main.dart` und weiß nichts von den
  /// Tab-Inhalten darunter. Ohne diesen Abstand verdeckt er den letzten
  /// Listeneintrag — in der Medikamentenliste traf das die Antwort „Später",
  /// die dadurch nicht mehr antippbar war.
  ///
  /// 56 px Standardgröße des FAB, 16 px Abstand zum Scaffold-Rand, dazu
  /// Luft nach oben.
  ///
  /// **Usage:**
  /// ```dart
  /// ListView(
  ///   padding: EdgeInsets.only(bottom: context.safeBottomPaddingForFab),
  ///   children: [...],
  /// )
  /// ```
  double get safeBottomPaddingForFab => safeBottomPaddingWithMargin(88);
}
