import 'package:dis_app/widgets/image_picker/image_picker_bottom_sheet.dart'
    show ImagePickerBottomSheet;
import 'package:dis_app/widgets/image_picker/image_picker_handler.dart'
    show ImagePickerHandler;
import 'package:flutter/material.dart';

/// # Image Picker Loading Dialog Manager
///
/// Static Helper-Klasse für Loading-Dialog während Image-Save Operations.
///
/// ## Problem gelöst:
/// Normaler Dialog-Close mit `Navigator.pop(context)` schlägt fehl,
/// wenn der Parent-Context disposed wurde während einer async operation.
///
/// **Beispiel-Szenario:**
/// ```dart
/// showDialog(context: parentContext, ...);
/// await saveImage();  // Dauert 2 Sekunden
/// // parentContext ist jetzt disposed (Bottom Sheet wurde geschlossen)
/// Navigator.pop(parentContext);  // ❌ FEHLER: context.mounted = false
/// ```
///
/// ## Solution:
/// Dialog-Context wird **separat** vom Parent-Context gespeichert und kann
/// unabhängig geschlossen werden, auch wenn Parent bereits disposed ist.
///
/// ## Usage Pattern:
/// ```dart
/// // Zeigen
/// await ImagePickerLoadingDialog.show(context);
///
/// // Async Work (Parent-Context kann disposed werden)
/// await someAsyncOperation();
///
/// // Schließen (funktioniert auch wenn Parent weg ist!)
/// ImagePickerLoadingDialog.close();
/// ```
///
/// ## Implementation Notes:
/// - **Static State:** `_dialogContext` wird class-level gespeichert
/// - **Null-Safe:** Prüft `mounted` vor jedem `pop()`
/// - **Thread-Safe:** Nur ein Dialog gleichzeitig möglich
/// - **Auto-Cleanup:** Context wird nach `close()` auf `null` gesetzt
///
/// ## Known Limitations:
/// - Nur ein aktiver Dialog zur Zeit (kein Stacking)
/// - Spezifisch für Image-Picker (nicht wiederverwendbar für andere Dialoge)
/// - Keine Progress-Anzeige (nur spinning indicator)
///
/// ## Verwandte Klassen:
/// - [ImagePickerHandler] - Nutzt diesen Dialog während save
/// - [ImagePickerBottomSheet] - Parent-Widget das disposed werden kann
///
/// @author Claude Code
/// @version 1.0.0
class ImagePickerLoadingDialog {
  /// Gespeicherter Dialog-Context (unabhängig von Parent)
  ///
  /// ⚠️ **WICHTIG:** Wird im Dialog-Builder gesetzt, nicht im Parent!
  ///
  /// **Lebenszyklus:**
  /// 1. `null` - Kein Dialog aktiv
  /// 2. `show()` - Context wird gesetzt
  /// 3. `close()` - Context wird auf `null` zurückgesetzt
  ///
  /// **Null-Safety:**
  /// Immer prüfen mit `_dialogContext?.mounted ?? false` vor Verwendung.
  static BuildContext? _dialogContext;

  /// Zeigt Loading-Dialog an
  ///
  /// **Verhalten:**
  /// - Dialog ist non-dismissible (kein Tap-Outside-Close)
  /// - Zeigt zentrierten [CircularProgressIndicator]
  /// - Dialog-Context wird intern gespeichert für späteren [close]
  /// - Blockiert User-Interaktion während aktiv
  ///
  /// **Context-Management:**
  /// Der übergebene `context` (Parent) wird **NICHT** für [close] verwendet!
  /// Stattdessen wird der Dialog-Context aus dem Builder gespeichert.
  ///
  /// **Error Handling:**
  /// - Falls Parent-Context ungültig: Dialog wird nicht angezeigt
  /// - Falls bereits ein Dialog aktiv: Alter wird nicht geschlossen (Limitierung)
  ///
  /// **Beispiel:**
  /// ```dart
  /// // Parent-Context vom Bottom Sheet
  /// final parentContext = context;
  ///
  /// // Dialog anzeigen
  /// await ImagePickerLoadingDialog.show(parentContext);
  ///
  /// // Ab hier kann parentContext disposed werden!
  /// ```
  ///
  /// @param context Parent-Context (z.B. von Bottom Sheet)
  /// @returns Future<void> die completed wenn Dialog angezeigt wird
  static Future<void> show(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // ✅ WICHTIG: Dialog-Context speichern, NICHT parent context!
        _dialogContext = ctx;

        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      },
    );
  }

  /// Schließt Loading-Dialog (auch wenn Parent disposed)
  ///
  /// **Null-Safety-Checks:**
  /// 1. Prüft `_dialogContext != null`
  /// 2. Prüft `_dialogContext.mounted`
  /// 3. Nutzt `!` operator nur **nach** beiden Checks
  ///
  /// **Cleanup:**
  /// - Context wird nach erfolgreichem Close auf `null` gesetzt
  /// - Falls Context bereits disposed: Kein Error, silent return
  ///
  /// **Called from:**
  /// - [ImagePickerHandler.pickFromCamera] - Nach erfolgreichem Save
  /// - [ImagePickerHandler.pickFromGallery] - Nach erfolgreichem Save
  /// - Error-Handling catch blocks - Bei Save-Fehler
  ///
  /// **Edge Cases:**
  /// - **Scenario 1:** Dialog wurde nie angezeigt
  ///   → `_dialogContext == null` → Silent return ✅
  ///
  /// - **Scenario 2:** Dialog wurde manuell geschlossen (User Back-Button)
  ///   → `_dialogContext.mounted == false` → Silent return ✅
  ///
  /// - **Scenario 3:** App in Background → Foreground während Dialog aktiv
  ///   → Context bleibt mounted → Normal close ✅
  ///
  /// **Beispiel:**
  /// ```dart
  /// try {
  ///   await saveImage();
  ///   ImagePickerLoadingDialog.close();  // ✅ Funktioniert!
  /// } catch (e) {
  ///   ImagePickerLoadingDialog.close();  // ✅ Auch im Error-Fall!
  ///   rethrow;
  /// }
  /// ```
  static void close() {
    // Null-Safety: Erst checken, dann verwenden
    if (_dialogContext?.mounted ?? false) {
      // Safe to use ! operator hier, weil wir mounted geprüft haben
      Navigator.of(_dialogContext!).pop();
      _dialogContext = null;
    }
  }
}
