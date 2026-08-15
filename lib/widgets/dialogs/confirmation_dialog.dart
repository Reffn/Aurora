import 'package:dis_app/l10n/app_texts.dart';
import 'package:flutter/material.dart';

/// Ergebnis des Confirmation Dialogs
enum ConfirmationResult {
  /// Abbrechen (bleibt auf Screen)
  cancel,

  /// Bestätigen/Speichern
  confirm,

  /// Verwerfen (z.B. Änderungen verwerfen)
  discard,
}

/// Wiederverwendbarer Confirmation Dialog
///
/// Standardisierter Dialog für Bestätigungen, Speichern-Abfragen, etc.
/// Unterstützt 2-Button und 3-Button Layouts.
///
/// **2-Button Layout:**
/// - [Cancel] [Confirm]
///
/// **3-Button Layout:**
/// - [Cancel] [Discard] [Confirm]
///
/// Beispiele:
/// ```dart
/// // 2-Button: Ja/Nein
/// final result = await ConfirmationDialog.show(
///   context: context,
///   title: "Löschen?",
///   message: "Wirklich löschen?",
///   confirmText: "Löschen",
///   confirmColor: Colors.red,
/// );
/// if (result == ConfirmationResult.confirm) { ... }
///
/// // 3-Button: Speichern/Verwerfen/Abbrechen
/// final result = await ConfirmationDialog.show(
///   context: context,
///   title: "Ungespeicherte Änderungen",
///   message: "Möchtest du speichern?",
///   showDiscardButton: true,
///   confirmText: "Speichern",
/// );
/// ```
class ConfirmationDialog {
  /// Zeigt einen Confirmation Dialog an
  ///
  /// Returns:
  /// - [ConfirmationResult.confirm] wenn bestätigt/gespeichert
  /// - [ConfirmationResult.discard] wenn verworfen (nur bei showDiscardButton=true)
  /// - [ConfirmationResult.cancel] wenn abgebrochen
  /// - null wenn dismissed (außerhalb getippt)
  static Future<ConfirmationResult?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? cancelText,
    String confirmText = 'OK',
    // Kein fester Vorgabewert: Übersetzte Texte sind keine Konstanten, und
    // „Verwerfen" stand deshalb hier auf Deutsch — mitten in einem sonst
    // französischen Dialog neben „Annuler" und „Enregistrer". Der Rückfall
    // gehört in den Rumpf.
    String? discardText,
    bool showDiscardButton = false,
    Color? confirmColor,
    Color discardColor = Colors.red,
    IconData? icon,
  }) async {
    return showDialog<ConfirmationResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Text(message),
        actions: [
          // Cancel Button (immer vorhanden)
          TextButton(
            onPressed: () => Navigator.pop(context, ConfirmationResult.cancel),
            child: Text(cancelText ?? AppTexts.current.actionCancel),
          ),

          // Discard Button (optional, rot)
          if (showDiscardButton)
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, ConfirmationResult.discard),
              style: TextButton.styleFrom(
                foregroundColor: discardColor,
              ),
              child: Text(discardText ?? AppTexts.current.actionDiscard),
            ),

          // Confirm Button (immer vorhanden)
          FilledButton(
            onPressed: () => Navigator.pop(context, ConfirmationResult.confirm),
            style: confirmColor != null
                ? FilledButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Shortcut: Simple YES/NO Dialog
  static Future<bool> showYesNo({
    required BuildContext context,
    required String title,
    required String message,
    String yesText = 'Ja',
    String noText = 'Nein',
    IconData? icon,
  }) async {
    final result = await show(
      context: context,
      title: title,
      message: message,
      cancelText: noText,
      confirmText: yesText,
      icon: icon,
    );
    return result == ConfirmationResult.confirm;
  }

  /// Shortcut: Destructive Action (Löschen, etc.)
  static Future<bool> showDestructive({
    required BuildContext context,
    required String title,
    required String message,
    String? actionText,
    String? cancelText,
  }) async {
    final texts = AppTexts.current;
    final result = await show(
      context: context,
      title: title,
      message: message,
      cancelText: cancelText ?? texts.actionCancel,
      confirmText: actionText ?? texts.actionDelete,
      confirmColor: Colors.red,
      icon: Icons.warning,
    );
    return result == ConfirmationResult.confirm;
  }

  /// Shortcut: Unsaved Changes Dialog (3 Buttons)
  static Future<ConfirmationResult?> showUnsavedChanges({
    required BuildContext context,
    String? title,
    String? message,
  }) async {
    // Standardwerte muessen Konstanten sein, uebersetzte Texte sind es
    // nicht. Deshalb null als Vorgabe und der Rueckfall erst hier.
    final texts = AppTexts.current;
    return show(
      context: context,
      title: title ?? texts.unsavedChangesTitle,
      message: message ?? texts.unsavedChangesMessage,
      showDiscardButton: true,
      confirmText: texts.confirmSave,
    );
  }
}
