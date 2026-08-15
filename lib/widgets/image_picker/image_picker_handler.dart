import 'dart:async';
import 'dart:io';

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/attachment_helper.dart';
import 'package:dis_app/widgets/animal_avatar_picker_dialog.dart';
import 'package:dis_app/widgets/doodle_avatar_screen.dart';
import 'package:dis_app/widgets/image_picker/image_picker_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// # Image Picker Handler - Business Logic Layer
///
/// Zentrale Klasse für Bild-Auswahl, Permission-Handling und Speichern.
/// Entkoppelt Business-Logik von UI-Komponenten.
///
/// ## Architektur-Entscheidung:
/// Diese Klasse wurde aus ProfileAvatarPickerBottomSheet extrahiert (426 Zeilen)
/// um Code-Maintainability zu verbessern und Fehleranfälligkeit zu reduzieren.
///
/// **Vorher:** UI + Permissions + Image Picking + Saving in einer Klasse (❌ komplex)
/// **Nachher:** 3 separate Module mit klaren Verantwortlichkeiten (✅ modular)
///
/// ## Verantwortlichkeiten:
/// 1. **Permission Management** - Kamera, Photo Library (inkl. Android 13+)
/// 2. **Image Picking** - Camera, Gallery, Animal Avatars
/// 3. **Image Saving** - Integration mit AttachmentHelper
/// 4. **Loading State** - Integration mit ImagePickerLoadingDialog
/// 5. **Error Handling** - User-Feedback via SnackBars/Dialogs
///
/// ## Context-Management-Pattern:
///
/// **Kritisches Problem gelöst:**
/// Beim Image-Picking können mehrere Context-Switches auftreten:
///
/// ```
/// Timeline der Context-Lebenszyklen:
/// t0: Bottom Sheet öffnet        → context1 (mounted ✅)
/// t1: User wählt "Kamera"        → context1 (mounted ✅)
/// t2: Kamera-App öffnet          → context1 (paused ⚠️)
/// t3: User macht Foto            → context1 (paused ⚠️)
/// t4: Zurück zur App             → context1 (disposed ❌) wenn z.B. Form-Screen verlassen
/// t5: Bild wird gespeichert      → PROBLEM: context1 nicht mehr verfügbar!
/// t6: Loading-Dialog muss closed werden → FEHLER wenn context1 verwendet wird!
/// ```
///
/// **Lösung:**
/// - [ImagePickerLoadingDialog] nutzt separaten Dialog-Context
/// - Callback wird **immer** ausgeführt, auch wenn Parent-Context disposed
/// - UI-Feedback nur wenn Context mounted ist
///
/// ## Usage Pattern (von UI-Layer):
///
/// ```dart
/// // In Bottom Sheet Widget:
/// final handler = ImagePickerHandler(
///   onImagePathSelected: (path) {
///     // Callback wird garantiert aufgerufen!
///     _updateAvatarPath(path);
///   },
/// );
///
/// // User tapped "Kamera":
/// await handler.pickFromCamera(context);
/// // Bottom Sheet kann geschlossen werden während Kamera aktiv ist!
/// ```
///
/// ## Permission-Handling:
///
/// **Plattform-Unterschiede:**
/// - **Kamera:** `Permission.camera`, überall. Wer die Kamera aufmacht,
///   greift auf ein Gerät zu — das braucht eine Frage.
/// - **Galerie auf Android:** **keine Berechtigung.** Der System-Photo-Picker
///   übergibt genau das eine Bild, das der Mensch ausgewählt hat.
/// - **Galerie auf iOS:** `Permission.photos`, „Limited Access" gilt als
///   gewährt.
///
/// **Permission-Status-Flow:**
/// ```
/// 1. granted         → ✅ Direkt fortfahren
/// 2. limited (iOS)   → ✅ Fortfahren (User hat "Select Photos" gewählt)
/// 3. denied          → 🟡 Request zeigen → granted/denied/permanentlyDenied
/// 4. permanentlyDenied → 🔴 Dialog mit "Einstellungen öffnen"-Button
/// ```
///
/// ## Error-Handling-Strategie:
///
/// **3 Ebenen von Fehlern:**
/// 1. **Permission denied** → User-freundliche SnackBar mit Action
/// 2. **Image Picker cancelled** → Silent (kein Error, normal behavior)
/// 3. **Save failed** → Error SnackBar + Loading-Dialog-Close
///
/// **Beispiel-Flow:**
/// ```dart
/// try {
///   if (!await _checkCameraPermission(context)) {
///     return; // Permission denied - UI-Feedback bereits gezeigt
///   }
///   final image = await _picker.pickImage(...);
///   if (image == null) return; // User cancelled - silent
///   await _handleImageSave(context, image); // Saving mit Error-Handling
/// } catch (e) {
///   // Unerwartete Fehler (sollten nicht auftreten)
/// }
/// ```
///
/// ## Known Edge Cases:
///
/// **Edge Case 1: App Background während Kamera-Nutzung**
/// - Context kann disposed werden
/// - Lösung: Callback wird trotzdem ausgeführt (Bild ist ja gespeichert)
/// - UI-Feedback nur wenn mounted
///
/// **Edge Case 2: Android — gar keine Galerie-Berechtigung**
/// - Der System-Photo-Picker fragt nichts und gibt nur das gewählte Bild
/// - Lösung: Auf Android wird nicht geprüft, sondern direkt geöffnet
///
/// **Edge Case 3: iOS "Limited Photos" Access**
/// - User kann nur bestimmte Fotos freigeben
/// - Lösung: `status.isLimited` wird als granted behandelt
///
/// **Edge Case 4: Permission permanent denied**
/// - User hat Permission dauerhaft abgelehnt
/// - Lösung: Dialog mit "App-Einstellungen öffnen"-Button
///
/// @author Claude Code
/// @version 1.0.0
class ImagePickerHandler {
  ImagePickerHandler({required this.onImagePathSelected});

  /// Callback für ausgewählten Image-Pfad
  ///
  /// **WICHTIG:** Wird **immer** aufgerufen wenn Bild erfolgreich gespeichert!
  /// Auch wenn Parent-Context bereits disposed ist.
  ///
  /// **Pfad-Format:**
  /// - Camera/Gallery: Relative path (z.B. `avatar_123.jpg`)
  /// - Animal Avatar: Asset path (z.B. `assets/images/Hund.png`)
  final void Function(String imagePath) onImagePathSelected;

  /// ImagePicker-Instance (wiederverwendbar)
  final ImagePicker _picker = ImagePicker();

  // ============================================================================
  // PUBLIC API - Entry Points for UI Layer
  // ============================================================================

  /// Wählt Bild von Kamera aus
  ///
  /// **Flow:**
  /// 1. Check Camera Permission (mit User-Feedback wenn denied)
  /// 2. Öffne Kamera-App
  /// 3. Wenn Bild ausgewählt: Speichern mit Loading-Dialog
  /// 4. Callback ausführen mit relativem Pfad
  ///
  /// **Context-Usage:**
  /// - Permission-Dialogs/SnackBars
  /// - Loading-Dialog (via ImagePickerLoadingDialog)
  /// - Error-SnackBars
  ///
  /// **Edge Cases:**
  /// - Permission denied → SnackBar mit "Einstellungen"-Action
  /// - User cancelled → Silent return (kein Error)
  /// - Save failed → Error SnackBar + rethrow
  ///
  /// @param context Parent-Context (z.B. von Bottom Sheet)
  /// @returns Future<void> die completed wenn fertig oder abgebrochen
  Future<void> pickFromCamera(BuildContext context) async {
    logger.info(
      LogCategory.ui,
      '📸 ImagePickerHandler: pickFromCamera started',
    );

    // 1. Permission Check
    final hasPermission = await _checkCameraPermission(context);
    // Prüfe nach await ob context noch valid ist
    if (!context.mounted) {
      return;
    }
    if (!hasPermission) {
      logger.info(
        LogCategory.ui,
        '📸 ImagePickerHandler: Camera permission denied',
      );
      return; // UI-Feedback bereits in _checkCameraPermission gezeigt
    }

    // 2. Pick Image
    await _pickImage(context, ImageSource.camera);
  }

  /// Wählt Bild aus Galerie aus
  ///
  /// **Auf Android ohne jede Berechtigung.** `image_picker` öffnet dort den
  /// System-Photo-Picker: Der Mensch sucht ein Bild aus, die App bekommt
  /// genau dieses und sonst nichts. Vorher zu fragen wäre nicht nur
  /// überflüssig, sondern hat Update 3.0.15 die Ablehnung eingebracht —
  /// die Frage lautet nämlich „darf ich alle deine Bilder sehen", und die
  /// Antwort braucht Aurora nie.
  ///
  /// **iOS** behält den Weg über `Permission.photos`, samt „Limited Access".
  /// Dort ist die Abfrage etabliert, und die Richtlinie, um die es geht,
  /// ist eine von Google Play.
  ///
  /// @param context Parent-Context (z.B. von Bottom Sheet)
  /// @returns Future<void> die completed wenn fertig oder abgebrochen
  Future<void> pickFromGallery(BuildContext context) async {
    logger.info(
      LogCategory.ui,
      '📸 ImagePickerHandler: pickFromGallery started',
    );

    if (!Platform.isAndroid) {
      final hasPermission = await _checkPhotosPermission(context);
      // Prüfe nach await ob context noch valid ist
      if (!context.mounted) {
        return;
      }
      if (!hasPermission) {
        logger.info(
          LogCategory.ui,
          '📸 ImagePickerHandler: Photos permission denied',
        );
        return; // UI-Feedback bereits in _checkPhotosPermission gezeigt
      }
    }

    await _pickImage(context, ImageSource.gallery);
  }

  /// Wählt Tier-Avatar aus Asset-Dialog aus
  ///
  /// **Unterschied zu Camera/Gallery:**
  /// - Kein Permission-Check nötig (Assets sind gebundled)
  /// - Kein Speichern nötig (Asset-Path wird direkt zurückgegeben)
  /// - Kein Loading-Dialog nötig (instant)
  ///
  /// **Flow:**
  /// 1. Zeige AnimalAvatarPickerDialog
  /// 2. User wählt Tier aus → Dialog returnt Asset-Path
  /// 3. Callback direkt ausführen (kein Save)
  ///
  /// **Fehler-Handling:**
  /// - Dialog cancelled → null return → Silent
  /// - Unerwarteter Fehler → Error SnackBar
  ///
  /// @param context Parent-Context (z.B. von Bottom Sheet)
  /// @returns Future<void> die completed wenn fertig oder abgebrochen
  Future<void> pickAnimalAvatar(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    logger.info(
      LogCategory.ui,
      '📸 ImagePickerHandler: pickAnimalAvatar started',
    );

    try {
      // Zeige Tier-Avatar-Dialog
      final assetPath = await AnimalAvatarPickerDialog.show(context);

      logger.info(
        LogCategory.ui,
        '📸 ImagePickerHandler: Animal avatar selected',
        data: {'assetPath': assetPath},
      );

      // Callback nur wenn Asset ausgewählt
      if (assetPath != null) {
        // WICHTIG: Kein await hier! Callback ist synchron.
        onImagePathSelected(assetPath);
        logger.info(
          LogCategory.ui,
          '📸 ImagePickerHandler: pickAnimalAvatar complete ✅',
        );
      } else {
        logger.info(
          LogCategory.ui,
          '📸 ImagePickerHandler: Animal avatar selection cancelled',
        );
      }
    } catch (e) {
      logger.error(
        LogCategory.ui,
        '📸 ImagePickerHandler: Error picking animal avatar',
        data: {'error': e.toString()},
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imagePickerAnimalError(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Lässt das Bild selbst malen
  ///
  /// **Unterschied zu Camera/Gallery:**
  /// - Kein Permission-Check nötig (nichts wird gelesen, nur gemalt)
  /// - Kein Loading-Dialog (das Speichern dauert Millisekunden, kein I/O
  ///   von außen)
  ///
  /// **Flow:**
  /// 1. Öffne DoodleAvatarScreen
  /// 2. User malt und übernimmt → PNG-Bytes zurück
  /// 3. Speichern über AttachmentHelper → relativer Pfad
  /// 4. Callback mit dem Pfad
  ///
  /// **Fehler-Handling:**
  /// - Zurück ohne Übernehmen → null → Silent
  /// - Speichern fehlgeschlagen → Error SnackBar
  ///
  /// @param context Parent-Context (z.B. von Bottom Sheet)
  /// @returns Future<void> die completed wenn fertig oder abgebrochen
  Future<void> pickDoodle(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final profileColor = Theme.of(context).colorScheme.primary;

    logger.info(
      LogCategory.ui,
      '📸 ImagePickerHandler: pickDoodle started',
    );

    try {
      final imageBytes = await DoodleAvatarScreen.show(
        context,
        profileColor: profileColor,
      );

      if (imageBytes == null) {
        logger.info(
          LogCategory.ui,
          '📸 ImagePickerHandler: Doodle cancelled',
        );
        return;
      }

      final avatarPath = await AttachmentHelper.saveDoodle(imageBytes);

      logger.info(
        LogCategory.ui,
        '📸 ImagePickerHandler: Doodle saved',
        data: {'avatarPath': avatarPath},
      );

      // Wie bei Camera/Gallery: Der Callback läuft auch dann, wenn der
      // Parent-Context inzwischen weg ist — das Bild liegt ja schon.
      onImagePathSelected(avatarPath);
    } catch (e) {
      logger.error(
        LogCategory.ui,
        '📸 ImagePickerHandler: Error saving doodle',
        data: {'error': e.toString()},
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imagePickerSaveError(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ============================================================================
  // PERMISSION HANDLING - Platform-Specific Logic
  // ============================================================================

  /// Prüft Camera Permission (iOS + Android)
  ///
  /// **Permission-Status-Flow:**
  /// - `granted` → ✅ return true
  /// - `denied` → Request → granted ✅ / denied 🔴
  /// - `permanentlyDenied` → Dialog mit "Einstellungen öffnen" 🔴
  ///
  /// **User-Feedback:**
  /// - Denied nach Request → Orange SnackBar mit Action
  /// - Permanently Denied → Alert-Dialog mit "Einstellungen öffnen"-Button
  ///
  /// @param context Für UI-Feedback (SnackBars, Dialogs)
  /// @returns true wenn Permission granted, sonst false
  Future<bool> _checkCameraPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final status = await Permission.camera.status;

    // Bereits gewährt
    if (status.isGranted) {
      return true;
    }

    // Noch nicht entschieden → Request
    if (status.isDenied) {
      final result = await Permission.camera.request();

      // Permission wurde gewährt
      if (result.isGranted) {
        return true;
      }

      // Permission wurde verweigert → User-Feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.imagePickerCameraNeeded,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: l10n.imagePickerAllowInSettings,
              textColor: Colors.white,
              onPressed: openAppSettings,
            ),
          ),
        );
      }

      return false;
    }

    // Permanent denied → Dialog
    if (status.isPermanentlyDenied && context.mounted) {
      await _showPermissionDeniedDialog(
        context,
        AppLocalizations.of(context).permissionCameraTitle,
        AppLocalizations.of(context).imagePickerCameraDeniedForever,
      );
    }

    return false;
  }

  /// Prüft die Foto-Berechtigung — **nur iOS**.
  ///
  /// Android geht seit dem 7. August 2026 ohne: Dort öffnet `image_picker`
  /// den System-Photo-Picker, der keine Berechtigung kennt. Der frühere
  /// Android-Zweig fragte `Permission.photos` ab, was auf Android 13+ auf
  /// `READ_MEDIA_IMAGES` hinausläuft — genau die Berechtigung, an der die
  /// Play-Prüfung das Update abgelehnt hat. Siehe [pickFromGallery].
  ///
  /// **iOS Limited Access:**
  /// User kann nur bestimmte Fotos freigeben → `status.isLimited` = true
  /// Wir behandeln das als granted (reicht für unseren Use-Case)
  ///
  /// **User-Feedback:**
  /// Analog zu [_checkCameraPermission] aber mit "Galerie"-Text
  ///
  /// @param context Für UI-Feedback (SnackBars, Dialogs)
  /// @returns true wenn Permission granted/limited, sonst false
  Future<bool> _checkPhotosPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    // Permission granted (oder limited auf iOS)
    if (status.isGranted || status.isLimited) {
      return true;
    }

    // Permission denied → User-Feedback
    if (status.isDenied && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.imagePickerGalleryNeeded,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: l10n.imagePickerAllowInSettings,
            textColor: Colors.white,
            onPressed: openAppSettings,
          ),
        ),
      );
      return false;
    }

    // Permanent denied → Dialog
    if (status.isPermanentlyDenied && context.mounted) {
      await _showPermissionDeniedDialog(
        context,
        AppLocalizations.of(context).permissionGalleryTitle,
        AppLocalizations.of(context).imagePickerGalleryDeniedForever,
      );
    }

    return false;
  }

  /// Zeigt Dialog wenn Permission permanent verweigert wurde
  ///
  /// **Design-Entscheidung:**
  /// SnackBar für "denied" (weniger invasiv), Dialog für "permanentlyDenied"
  /// (braucht mehr Aufmerksamkeit, da User in Einstellungen gehen muss)
  ///
  /// @param context Für Dialog
  /// @param title Dialog-Titel (z.B. "Kamera-Berechtigung")
  /// @param message Dialog-Message
  Future<void> _showPermissionDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(l10n.imagePickerOpenSettings),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // IMAGE PICKING & SAVING - Core Business Logic
  // ============================================================================

  /// Wählt Bild aus (Camera/Gallery) und speichert es
  ///
  /// **Flow:**
  /// 1. ImagePicker.pickImage() aufrufen
  /// 2. Wenn cancelled → Silent return
  /// 3. Wenn Bild gewählt → _handleImageSave aufrufen
  ///
  /// **Context-Checks:**
  /// Mehrere mounted-Checks weil async operations:
  /// - Nach pickImage (User könnte Screen verlassen haben)
  /// - Vor Save-Dialog (Context muss valid sein)
  /// - Nach Save (für SnackBars)
  ///
  /// **Logging:**
  /// Extensive logging für Debugging (war fehleranfällig in alter Version)
  ///
  /// @param context Parent-Context
  /// @param source ImageSource.camera oder ImageSource.gallery
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    logger.info(
      LogCategory.ui,
      '📸 ImagePickerHandler: Opening image picker',
      data: {'source': source.toString()},
    );

    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      logger.info(
        LogCategory.ui,
        '📸 ImagePickerHandler: Image picker returned',
        data: {'hasImage': image != null, 'contextMounted': context.mounted},
      );

      if (image != null && context.mounted) {
        await _handleImageSave(context, image);
      } else if (image == null) {
        logger.info(
          LogCategory.ui,
          '📸 ImagePickerHandler: Image selection cancelled',
        );
      } else {
        // Ein Bild ist da, aber der Context ist weg. Vorher endete dieser
        // Fall im Nichts: kein Speichern, kein Callback, keine Meldung —
        // der Mensch wählte ein Bild und bekam nichts. Genau so lief es am
        // 8. August 2026, weil der Aufrufer den Context des Blatts
        // durchreichte, das er zuvor geschlossen hatte.
        //
        // Behoben ist das an der Wurzel (`image_picker_bottom_sheet.dart`).
        // Diese Zeile ist der Riegel dahinter: Sollte je wieder ein toter
        // Context hier ankommen, steht es wenigstens im Log, statt lautlos
        // zu verschwinden.
        logger.error(
          LogCategory.ui,
          '📸 ImagePickerHandler: Bild gewählt, aber Context ist weg — '
          'es wurde nichts gespeichert',
          data: {'source': source.toString(), 'path': image.path},
        );
      }
    } catch (e) {
      logger.error(
        LogCategory.ui,
        '📸 ImagePickerHandler: Error in picker flow',
        data: {'error': e.toString()},
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imagePickerPickError(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Speichert ausgewähltes Bild mit Loading-Dialog
  ///
  /// **KRITISCHER ABSCHNITT - Context-Management:**
  ///
  /// Dieses ist der fehleranfälligste Teil des gesamten Flows!
  /// Mehrere async operations mit Context-Switches.
  ///
  /// **Timeline:**
  /// ```
  /// t0: Zeige Loading-Dialog (unawaited!)
  /// t1: Start AttachmentHelper.saveProfileAvatar (async, dauert ~1-2s)
  /// t2: ⚠️ HIER kann Parent-Context disposed werden!
  /// t3: Save complete
  /// t4: Close Loading-Dialog (via ImagePickerLoadingDialog)
  /// t5: Execute Callback (auch wenn Parent disposed!)
  /// ```
  ///
  /// **Design-Entscheidungen:**
  ///
  /// 1. **unawaited() für showDialog:**
  ///    Wir warten nicht auf Dialog-Future (die erst bei close completet).
  ///    Wir speichern nur den Dialog-Context für späteren Close.
  ///    → [ImagePickerLoadingDialog] managed den Context separat
  ///
  /// 2. **Callback immer ausführen:**
  ///    Auch wenn Parent-Context disposed → Bild ist ja gespeichert!
  ///    UI-Layer muss damit umgehen können.
  ///
  /// 3. **Loading-Dialog immer closen:**
  ///    Auch im Error-Fall! Sonst bleibt Spinner hängen.
  ///    → Deshalb try-finally-Pattern
  ///
  /// 4. **SnackBar nur wenn mounted:**
  ///    Success-Feedback optional (User sieht ja neues Bild)
  ///    Error-Feedback wichtig aber nur wenn Context noch da
  ///
  /// **Error-Recovery:**
  /// Wenn Save fehlschlägt → Loading-Dialog trotzdem closen → Error SnackBar
  ///
  /// @param context Parent-Context (kann disposed werden!)
  /// @param image XFile von ImagePicker
  Future<void> _handleImageSave(BuildContext context, XFile image) async {
    final l10n = AppLocalizations.of(context);
    logger.info(
      LogCategory.ui,
      '📸 ImagePickerHandler: Starting image save',
      data: {'imagePath': image.path},
    );

    try {
      // Zeige Loading-Dialog (unawaited!)
      if (context.mounted) {
        logger.info(
          LogCategory.ui,
          '📸 ImagePickerHandler: Showing loading dialog',
        );
        // WICHTIG: unawaited! Wir warten nicht auf Dialog-Future.
        // ImagePickerLoadingDialog speichert Context intern.
        unawaited(ImagePickerLoadingDialog.show(context));
      }

      // Speichere Bild (async, kann lange dauern!)
      final avatarPath = await AttachmentHelper.saveProfileAvatar(
        File(image.path),
      );

      logger.info(
        LogCategory.ui,
        '📸 ImagePickerHandler: Image saved',
        data: {'avatarPath': avatarPath},
      );

      // Schließe Loading-Dialog (funktioniert auch wenn Parent disposed!)
      ImagePickerLoadingDialog.close();
      logger.info(
        LogCategory.ui,
        '📸 ImagePickerHandler: Loading dialog closed',
      );

      // Debug: Log state before callback execution
      logger.debug(
        LogCategory.ui,
        '🔍 📸 Before callback execution',
        data: {
          'avatarPath': avatarPath,
          'contextMounted': context.mounted,
        },
      );

      // Execute Callback (IMMER, auch wenn Parent disposed!)
      onImagePathSelected(avatarPath);

      // Debug: Log state after callback execution
      logger.debug(
        LogCategory.ui,
        '🔍 📸 After callback execution',
        data: {
          'contextMounted': context.mounted,
        },
      );

      if (context.mounted) {
        logger.info(
          LogCategory.ui,
          '📸 ImagePickerHandler: Save complete ✅',
        );
      } else {
        logger.warning(
          LogCategory.ui,
          '📸 ImagePickerHandler: Parent context not mounted, but callback executed',
        );
      }
    } catch (e) {
      logger.error(
        LogCategory.ui,
        '📸 ImagePickerHandler: Error saving image',
        data: {'error': e.toString()},
      );

      // WICHTIG: Dialog auch im Error-Fall schließen!
      ImagePickerLoadingDialog.close();
      logger.info(
        LogCategory.ui,
        '📸 ImagePickerHandler: Loading dialog closed (error case)',
      );

      // Error-Feedback nur wenn Context mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imagePickerSaveError(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Rethrow damit Caller weiß dass es fehlgeschlagen ist
      rethrow;
    }
  }
}
