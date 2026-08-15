import 'package:flutter/material.dart';

/// Extension für vereinfachte SnackBar-Anzeige
/// Reduziert Boilerplate und standardisiert Styling
extension SnackBarHelper on BuildContext {
  /// Zeigt eine Erfolgs-SnackBar (grün)
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// Zeigt eine Fehler-SnackBar (rot)
  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration,
      ),
    );
  }

  /// Zeigt eine Warnung-SnackBar (orange)
  void showWarningSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: duration,
      ),
    );
  }

  /// Zeigt eine Info-SnackBar (blau)
  void showInfoSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: duration,
      ),
    );
  }

  /// Zeigt eine custom SnackBar mit individuellen Einstellungen
  void showCustomSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }
}
