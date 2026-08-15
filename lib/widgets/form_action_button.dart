import 'package:dis_app/utils/app_spacing.dart';
import 'package:flutter/material.dart';

/// Großer Action-Button für Form-Screens (Speichern/Erstellen/Löschen)
///
/// Bietet konsistentes Styling über alle Form-Screens:
/// - Full Width
/// - 56px Höhe
/// - 16px Border Radius
/// - elevation: 0
/// - Material 3 (FilledButton)
/// - Optional: Icon + Loading State
///
/// Verwendung:
/// ```dart
/// FormActionButton(
///   label: 'Speichern',
///   onPressed: _saveForm,
/// )
///
/// // Mit Icon:
/// FormActionButton(
///   label: 'Speichern',
///   icon: Icons.save,
///   onPressed: _saveForm,
/// )
///
/// // Mit Loading State:
/// FormActionButton(
///   label: 'Speichern',
///   loading: _isSaving,
///   onPressed: _saveForm,
/// )
/// ```
class FormActionButton extends StatelessWidget {
  const FormActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.loading = false,
  });

  /// Button-Text (z.B. "Speichern", "Erstellen", "Löschen")
  final String label;

  /// Callback wenn Button gedrückt wird (wird disabled wenn loading = true)
  final VoidCallback? onPressed;

  /// Optional: Icon das links vom Text angezeigt wird
  final IconData? icon;

  /// Optional: Hintergrundfarbe (default: Theme primary color)
  final Color? backgroundColor;

  /// Optional: Textfarbe (default: white)
  final Color? foregroundColor;

  /// Loading-State: Zeigt Spinner und disabled Button
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: icon != null
          ? FilledButton.icon(
              onPressed: loading ? null : onPressed,
              icon: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: _buttonStyle(context),
            )
          : FilledButton(
              onPressed: loading ? null : onPressed,
              style: _buttonStyle(context),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return FilledButton.styleFrom(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      elevation: 0,
    );
  }
}
