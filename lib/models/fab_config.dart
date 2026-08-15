import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/widgets/permission_aware_fab.dart';
import 'package:flutter/material.dart';

/// Konfiguration für FloatingActionButton pro Screen
/// Verwendet im MainScreen um FABs zentral zu verwalten
class FABConfig {
  const FABConfig({
    required this.permission,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isExtended = true,
  });

  /// Erforderliche Permission für diesen FAB
  final Permission permission;

  /// Icon des FAB
  final IconData icon;

  /// Beschriftung des FAB, gelesen beim Bauen.
  ///
  /// Die Konfigurationen entstehen beim App-Start, angezeigt werden sie
  /// später und womöglich in einer anderen Sprache. Deshalb steht hier
  /// nicht das Wort, sondern der Weg zu ihm.
  final String Function(AppLocalizations) label;

  /// Callback wenn FAB getapped wird (mit Permission)
  final VoidCallback onPressed;

  /// Ob extended FAB verwendet werden soll (mit Label)
  final bool isExtended;

  /// Baut den PermissionAwareFAB basierend auf dieser Config
  Widget build(BuildContext context) {
    return PermissionAwareFAB(
      permission: permission,
      icon: icon,
      label: label(AppLocalizations.of(context)),
      onPressed: onPressed,
      isExtended: isExtended,
    );
  }
}
