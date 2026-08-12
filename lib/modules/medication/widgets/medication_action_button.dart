import 'package:flutter/material.dart';

/// Wiederverwendbarer Action-Button für Medikation (gefüllt oder outlined)
///
/// **DEPRECATED**: Use [ActionButtonRow] with [ActionButtonConfig] instead.
/// This widget uses the deprecated [ElevatedButton] (Material 2) instead of
/// [FilledButton] (Material 3) and will be removed in a future version.
///
/// Migration example:
/// ```dart
/// // Old:
/// MedicationActionButton(
///   label: 'Genommen',
///   icon: Icons.check,
///   color: Colors.green,
///   filled: true,
///   onPressed: onTap,
/// )
///
/// // New:
/// ActionButtonRow(
///   buttons: [
///     ActionButtonConfig(
///       label: 'Genommen',
///       icon: Icons.check,
///       color: AppColors.medicationTaken,
///       filled: true,
///       onPressed: onTap,
///     ),
///   ],
/// )
/// ```
@Deprecated(
  'Use ActionButtonRow with ActionButtonConfig instead. '
  'This widget will be removed in a future version.',
)
class MedicationActionButton extends StatelessWidget {
  const MedicationActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.filled = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
