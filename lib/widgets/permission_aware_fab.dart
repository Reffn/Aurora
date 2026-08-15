import 'package:dis_app/models/permission.dart';
import 'package:dis_app/widgets/permission_guard.dart';
import 'package:flutter/material.dart';

/// FloatingActionButton der immer sichtbar ist, aber disabled wenn Permission fehlt
///
/// - Mit Permission: Normaler aktiver FAB
/// - Ohne Permission: Grauer FAB + Tap zeigt SnackBar mit Erklärung
///
/// Verwendung:
/// ```dart
/// PermissionAwareFAB(
///   permission: Permission.manageContacts,
///   icon: Icons.add,
///   label: 'Kontakt',
///   onPressed: () => navigateToContactForm(),
/// )
/// ```
class PermissionAwareFAB extends StatelessWidget {
  const PermissionAwareFAB({
    required this.permission,
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
    this.isExtended = true,
  });

  /// Erforderliche Permission
  final Permission permission;

  /// FAB Icon
  final IconData icon;

  /// FAB Label (für extended FAB)
  final String label;

  /// Callback wenn FAB mit Permission getapped wird
  final VoidCallback onPressed;

  /// Ob extended FAB mit Label verwendet werden soll
  final bool isExtended;

  @override
  Widget build(BuildContext context) {
    return ActiveProfilePermission(
      test: (profile) => profile.hasPermission(permission),
      builder: (context, granted) {
        if (granted) {
          return _buildFAB(context: context, onPressed: onPressed);
        }

        // Ohne Berechtigung blass, aber weiterhin antippbar — der Tipp
        // erklärt dann, welche Berechtigung fehlt, statt ins Leere zu gehen.
        return Opacity(
          opacity: 0.4,
          child: _buildFAB(
            context: context,
            onPressed: () => showNoPermissionSnackBar(context, permission),
          ),
        );
      },
    );
  }

  /// Baut den FAB (normal oder extended)
  Widget _buildFAB({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    if (isExtended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    } else {
      return FloatingActionButton(
        onPressed: onPressed,
        child: Icon(icon),
      );
    }
  }
}
