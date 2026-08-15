import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/aurora_text_field.dart';
import 'package:dis_app/widgets/image_picker/image_picker_bottom_sheet.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Widget für Identitäts-Eingaben beim Profil erstellen/bearbeiten
/// Enthält: Name, Avatar, optionales Passwort
class ProfileIdentitySection extends StatefulWidget {
  const ProfileIdentitySection({
    required this.nameController,
    required this.selectedColor,
    required this.selectedAvatarPath,
    required this.onAvatarPathSelected,
    required this.passwordController,
    required this.passwordConfirmController,
    this.isEditMode = false,
    this.showPasswordFields = true,
    this.nameFocusNode,
    super.key,
  });

  final TextEditingController nameController;

  /// Erlaubt dem Eltern-Screen, den Fokus auf das Namensfeld zu setzen.
  ///
  /// Ohne das erscheint der Hinweis „Bitte Name eingeben" zwar am Feld, aber
  /// wer unten auf „Weiter" tippt, schaut nicht nach oben — für ihn passiert
  /// scheinbar nichts.
  final FocusNode? nameFocusNode;
  final Color selectedColor;
  final String? selectedAvatarPath;
  final void Function(String? avatarPath) onAvatarPathSelected;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final bool isEditMode;
  final bool showPasswordFields;

  @override
  State<ProfileIdentitySection> createState() => _ProfileIdentitySectionState();
}

class _ProfileIdentitySectionState extends State<ProfileIdentitySection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + Name
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar-Auswahl
            GestureDetector(
              onTap: () {
                ImagePickerBottomSheet.show(
                  context,
                  title: l10n.profilePickImage,
                  onImagePathSelected: widget.onAvatarPathSelected,
                  // Nur beim Anteil: Alle teilen einen Körper, ein Foto zeigt
                  // immer denselben. Gemalt zeigt, wer jemand ist.
                  showDoodleOption: true,
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: widget.selectedColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // Derselbe Rueckfall wie ueberall sonst in der App.
                      //
                      // Hier stand ein eigenes `fallbackWidget`: die Initialen
                      // in `Colors.white`, ohne Kontur. Der Kasten darunter
                      // traegt die Profilfarbe — bei einem hellen Profil stand
                      // damit Weiss auf Weiss, und die Flaeche sah leer aus.
                      // `ProfileImageWidget` setzt seine Initialen mit
                      // schwarzer Kontur; deshalb bleiben sie dort auf jedem
                      // Untergrund lesbar. Wer den gemeinsamen Weg umgeht,
                      // verliert lautlos, was der gemeinsame Weg zusagt.
                      child: ProfileImageWidget(
                        avatarPath: widget.selectedAvatarPath,
                        size: 100,
                        profileName: widget.nameController.text,
                        profileColor: widget.selectedColor,
                        maxInitialChars: 2,
                      ),
                    ),
                  ),
                  // Kamera-Icon Overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.ink,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Name-Eingabe
            Expanded(
              child: AuroraTextField(
                label: l10n.fieldName,
                controller: widget.nameController,
                focusNode: widget.nameFocusNode,
                hint: l10n.fieldNameHint,
                textCapitalization: TextCapitalization.words,
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validationNameRequired;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        // Passwort-Felder (optional, nur wenn showPasswordFields = true)
        if (widget.showPasswordFields) ...[
          const SizedBox(height: 20),

          // Info-Text
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: 18,
                color: AppColors.paper.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isEditMode
                      ? l10n.profilePasswordOptional
                      : l10n.profilePasswordOptionalMin,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.paper.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Passwort-Eingabe
          AuroraTextField(
            label: l10n.fieldPassword,
            controller: widget.passwordController,
            obscure: true,
            hint: l10n.fieldPasswordHint,
            icon: Icons.lock,
            validator: (value) {
              // Passwort ist optional
              if (value == null || value.isEmpty) {
                return null;
              }
              if (value.length < 4) {
                return l10n.validationPasswordLength;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Passwort bestätigen
          AuroraTextField(
            label: l10n.pwResetConfirmPassword,
            controller: widget.passwordConfirmController,
            obscure: true,
            icon: Icons.lock_outline,
            validator: (value) {
              final password = widget.passwordController.text;
              // Wenn kein Passwort gesetzt, ist Bestätigung auch optional
              if (password.isEmpty && (value == null || value.isEmpty)) {
                return null;
              }
              // Wenn Passwort gesetzt, muss Bestätigung passen
              if (password.isNotEmpty && value != password) {
                return l10n.pwResetMismatch;
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
