import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/widgets/image_picker/image_picker_handler.dart';
import 'package:flutter/material.dart';

/// # Image Picker Bottom Sheet - UI Layer
///
/// Minimalistisches Bottom Sheet für Bild-Auswahl.
/// Reine UI-Komponente ohne Business-Logik.
///
/// ## Architektur-Entscheidung:
///
/// Diese Klasse wurde aus ProfileAvatarPickerBottomSheet extrahiert (426 Zeilen)
/// als Teil einer Modularisierung in 3 separate Komponenten:
///
/// ```
/// Alte Architektur (❌ monolithisch):
/// ProfileAvatarPickerBottomSheet (426 Zeilen)
///   ├─ UI (Bottom Sheet, ListTiles)
///   ├─ Business Logic (Permissions, Image Picking, Saving)
///   └─ Dialog Management (Loading-Dialog mit Context-Problemen)
///
/// Neue Architektur (✅ modular):
/// ImagePickerBottomSheet (100 Zeilen) ← UI Layer
///   └─ nutzt ImagePickerHandler ← Business Logic Layer
///       └─ nutzt ImagePickerLoadingDialog ← Helper Layer
/// ```
///
/// ## Vorteile der Modularisierung:
///
/// 1. **Separation of Concerns:**
///    - UI-Logik isoliert (einfach zu testen, einfach zu stylen)
///    - Business-Logik wiederverwendbar (nicht UI-gebunden)
///
/// 2. **Reduzierte Komplexität:**
///    - Von 426 Zeilen → ~100 Zeilen (75% Reduktion)
///    - Keine Context-Management-Probleme in UI-Schicht
///    - Keine Permission-Handling-Logik in UI
///
/// 3. **Bessere Wartbarkeit:**
///    - Bug-Fixes nur in einer Schicht nötig
///    - Klare Verantwortlichkeiten
///    - Einfacher zu dokumentieren
///
/// 4. **Wiederverwendbarkeit:**
///    - ImagePickerHandler kann ohne Bottom Sheet genutzt werden
///    - Alternative UI-Komponenten können selben Handler nutzen
///
/// ## Verwendungszweck:
///
/// Dieses Widget wird verwendet für:
/// - **Profile:** Avatar-Auswahl bei Profil-Erstellung/Bearbeitung
/// - **Kontakte:** Kontaktbild-Auswahl
/// - **Finder:** Foto-Auswahl für Finder-Einträge
///
/// **Name-Rationale:**
/// Obwohl hauptsächlich für Avatare verwendet, ist "ImagePicker" generischer
/// und reflektiert die breite Verwendung besser als "ProfileAvatarPicker".
///
/// ## Context-Management:
///
/// **Wichtig:** Bottom Sheet schließt sich **SOFORT** nach Auswahl!
///
/// ```dart
/// User tappt "Kamera"
///   → _onCameraPressed()
///   → Navigator.pop(context)  // ✅ Bottom Sheet sofort schließen
///   → handler.pickFromCamera(context)  // ✅ Nutzt Parent-Context
///       → Kamera-App öffnet
///       → Bottom-Sheet-Context ist weg (disposed) ✅ OK!
///       → ImagePickerHandler managed Context separat ✅
/// ```
///
/// **Design-Entscheidung:**
/// Bottom Sheet muss geschlossen werden **bevor** Kamera/Gallery öffnet,
/// sonst bleibt Bottom Sheet im Hintergrund wenn User zurückkommt.
///
/// ## Usage Pattern:
///
/// ```dart
/// // Von beliebigem Widget:
/// final result = await ImagePickerBottomSheet.show(
///   context,
///   title: 'Profilbild wählen',
///   onImagePathSelected: (path) {
///     setState(() {
///       _avatarPath = path;
///     });
///   },
/// );
/// ```
///
/// **Callback-Execution:**
/// Der Callback wird ausgeführt **nachdem** Bottom Sheet geschlossen ist!
/// Das ist OK weil Parent-Context (Form-Screen) noch existiert.
///
/// ## UI-Design:
///
/// - **3 Optionen:** Kamera, Galerie, Tier-Avatar
/// - **Icons:** Farbcodiert (blue/green/orange) für bessere UX
/// - **Optional Title:** Kann angepasst werden je nach Context
/// - **Bottom Sheet Style:** Rounded corners, standard Material Design
///
/// ## Known Limitations:
///
/// - Kein "Abbrechen"-Button (User kann durch Swipe-Down schließen)
/// - Keine Option zum Entfernen des Bildes (muss im Parent-Screen sein)
/// - Keine Vorschau des aktuellen Bildes (würde UI zu komplex machen)
///
/// @author Claude Code
/// @version 1.0.0
/// Was im Blatt gewählt wurde.
///
/// Das Blatt **wählt nur**, es handelt nicht. Warum, steht bei
/// [ImagePickerBottomSheet.choose].
enum ImagePickerChoice { camera, gallery, animal, doodle }

class ImagePickerBottomSheet extends StatelessWidget {
  const ImagePickerBottomSheet({
    super.key,
    this.title,
    this.showAnimalOption = true,
    this.showDoodleOption = false,
  });

  /// Optional: Titel über den Optionen
  ///
  /// **Beispiele:**
  /// - "Profilbild wählen"
  /// - "Kontaktbild wählen"
  /// - "Foto hinzufügen"
  ///
  /// Wenn null: Kein Titel angezeigt
  final String? title;

  /// Ob die Tier-Avatar Option angezeigt werden soll
  ///
  /// **Default:** true (Backward Compatibility)
  ///
  /// **Use Cases:**
  /// - true: Profile, Kontakte, Finder (Assets OK)
  /// - false: Feedback (nur uploadbare Dateien)
  ///
  /// **Hintergrund:**
  /// Asset-Pfade (`assets/images/Hund.png`) können nicht
  /// direkt hochgeladen werden. Feedback benötigt nur
  /// echte Dateien von Camera/Gallery.
  final bool showAnimalOption;

  /// Ob die Option „Selbst malen" angezeigt werden soll
  ///
  /// **Default:** false
  ///
  /// **Use Cases:**
  /// - true: Profile (ein Anteil malt sich selbst)
  /// - false: Kontakte, Finder, Feedback
  ///
  /// **Hintergrund:**
  /// Alle Anteile teilen einen Körper — ein Foto zeigt immer denselben.
  /// Ein gemaltes Bild zeigt, wer jemand ist. Für einen Kontakt oder einen
  /// Fundort ist das nicht die Frage, deshalb steht die Option dort nicht.
  ///
  /// Sie steht **hinten**, nicht vorn: Wer die Reihenfolge kennt, greift nach
  /// Ort statt nach Wort, und eine neue Zeile darf keine alte verschieben.
  final bool showDoodleOption;

  /// Zeigt Image Picker Bottom Sheet an
  ///
  /// **Modal Bottom Sheet:**
  /// - Blockiert Interaktion mit Parent-Screen
  /// - Kann durch Swipe-Down geschlossen werden
  /// - Rounded corners oben
  ///
  /// **Return Value:**
  /// Future<void> die completet wenn Bottom Sheet geschlossen wird.
  /// (Nicht wenn Bild ausgewählt wurde!)
  ///
  /// **Context:**
  /// Muss valid sein zum Zeitpunkt des Aufrufs.
  /// Parent-Context wird an Handler weitergegeben für:
  /// - Permission-Dialogs
  /// - Loading-Dialogs
  /// - Error-SnackBars
  ///
  /// @param context Parent-Context (z.B. Form-Screen)
  /// @param onImagePathSelected Callback für gewählten Pfad
  /// @param title Optional: Titel im Bottom Sheet
  /// @param showAnimalOption Optional: Tier-Avatar Option zeigen (default: true)
  /// @returns Future die completet wenn der Vorgang abgeschlossen ist
  static Future<void> show(
    BuildContext context, {
    required void Function(String) onImagePathSelected,
    String? title,
    bool showAnimalOption = true,
    bool showDoodleOption = false,
  }) async {
    final choice = await choose(
      context,
      title: title,
      showAnimalOption: showAnimalOption,
      showDoodleOption: showDoodleOption,
    );
    if (choice == null || !context.mounted) return;

    final handler = ImagePickerHandler(
      onImagePathSelected: onImagePathSelected,
    );
    switch (choice) {
      case ImagePickerChoice.camera:
        await handler.pickFromCamera(context);
      case ImagePickerChoice.gallery:
        await handler.pickFromGallery(context);
      case ImagePickerChoice.animal:
        await handler.pickAnimalAvatar(context);
      case ImagePickerChoice.doodle:
        await handler.pickDoodle(context);
    }
  }

  /// Zeigt das Blatt und gibt zurück, was gewählt wurde. `null` heißt
  /// weggewischt.
  ///
  /// **Das Blatt handelt nicht selbst, und das ist der Kern.** Vorher rief es
  /// den Handler mit seinem eigenen Context auf, nachdem es sich per
  /// `Navigator.pop` geschlossen hatte. Solange nur ein Dialog folgte, ging
  /// das gut. Sobald aber die Systemauswahl dazwischenlag — Kamera oder
  /// Photo-Picker —, war dieser Context bei der Rückkehr längst weg:
  /// `image_picker_handler.dart` prüft `context.mounted`, fand ihn tot und
  /// stieg aus. Ohne Fehler, ohne Meldung, ohne Bild. Am Gerät belegt am
  /// 8. August 2026, siehe
  /// `docs/superpowers/specs/2026-08-08-geraetedurchlauf-3016-s24.md`.
  ///
  /// Jetzt gehört der Context dem Formular, das die Auswahl angestoßen hat.
  /// Das Blatt ist zu diesem Zeitpunkt zu, das Formular steht noch — und
  /// steht auch noch, wenn der Mensch aus der Systemauswahl zurückkommt.
  ///
  /// Getrennt von [show], damit der Weg prüfbar ist, ohne Kamera und Galerie
  /// zu brauchen.
  @visibleForTesting
  static Future<ImagePickerChoice?> choose(
    BuildContext context, {
    String? title,
    bool showAnimalOption = true,
    bool showDoodleOption = false,
  }) {
    return showModalBottomSheet<ImagePickerChoice>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => ImagePickerBottomSheet(
        title: title,
        showAnimalOption: showAnimalOption,
        showDoodleOption: showDoodleOption,
      ),
    );
  }

  // ============================================================================
  // UI BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Optional: Titel
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            // Jede Zeile schließt das Blatt und gibt die Wahl zurück.
            // Gehandelt wird eine Ebene höher — siehe [choose].

            // Option 1: Kamera
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: Text(l10n.imagePickerOpenCamera),
              onTap: () => Navigator.pop(context, ImagePickerChoice.camera),
            ),

            // Option 2: Galerie
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: Text(l10n.imagePickerFromGallery),
              onTap: () => Navigator.pop(context, ImagePickerChoice.gallery),
            ),

            // Option 3: Tier-Avatar (conditional)
            if (showAnimalOption)
              ListTile(
                leading: const Icon(Icons.pets, color: Colors.orange),
                title: Text(l10n.imagePickerAnimalAvatar),
                onTap: () => Navigator.pop(context, ImagePickerChoice.animal),
              ),

            // Option 4: Selbst malen (conditional)
            if (showDoodleOption)
              ListTile(
                leading: const Icon(Icons.brush, color: Colors.purple),
                title: Text(l10n.imagePickerDrawYourself),
                onTap: () => Navigator.pop(context, ImagePickerChoice.doodle),
              ),
          ],
        ),
      ),
    );
  }
}
