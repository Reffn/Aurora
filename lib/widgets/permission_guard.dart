import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/permission_text.dart';
import 'package:dis_app/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Beobachtet das aktive Profil und baut neu, sobald es wechselt.
///
/// Hier steht die Berechtigungsprüfung genau einmal — samt der Entscheidung,
/// was ohne aktives Profil gilt: nichts ist erlaubt. Vorher stand diese
/// Entscheidung in jedem Wächter einzeln, und jeder hätte sie beim nächsten
/// Umbau anders treffen können.
class ActiveProfilePermission extends StatelessWidget {
  const ActiveProfilePermission({
    required this.test,
    required this.builder,
    super.key,
  });

  /// Wird gegen das aktive Profil geprüft.
  final bool Function(Profile profile) test;

  /// Bekommt das Ergebnis der Prüfung.
  final Widget Function(BuildContext context, bool granted) builder;

  @override
  Widget build(BuildContext context) {
    final dataEntry = getIt<DataEntry>();

    return ValueListenableBuilder(
      valueListenable: dataEntry.settingsBox.listenable(),
      builder: (context, _, __) {
        final profile = dataEntry.getActiveProfile();
        return builder(context, profile != null && test(profile));
      },
    );
  }
}

/// Widget das UI-Elemente basierend auf Berechtigungen anzeigt/versteckt
///
/// Verwendung:
/// ```dart
/// PermissionGuard(
///   permission: Permission.createProfiles,
///   child: FloatingActionButton(...),
///   fallback: Text('Keine Berechtigung'),
/// )
/// ```
class PermissionGuard extends StatelessWidget {
  const PermissionGuard({
    required this.permission,
    required this.child,
    super.key,
    this.fallback,
    this.disableInsteadOfHide = false,
  });

  /// Die erforderliche Berechtigung
  final Permission permission;

  /// Das Widget das angezeigt wird wenn Berechtigung vorhanden
  final Widget child;

  /// Optional: Widget das angezeigt wird wenn KEINE Berechtigung vorhanden
  /// Falls null, wird nichts angezeigt (SizedBox.shrink)
  final Widget? fallback;

  /// Optional: Deaktiviert statt versteckt (z.B. für Buttons)
  final bool disableInsteadOfHide;

  @override
  Widget build(BuildContext context) {
    return ActiveProfilePermission(
      test: (profile) => profile.hasPermission(permission),
      builder: (context, granted) {
        if (granted) {
          return child;
        }

        // Keine Berechtigung
        if (disableInsteadOfHide) {
          // Deaktiviere das Child (nur für bestimmte Widgets möglich)
          return AbsorbPointer(
            child: Opacity(
              opacity: 0.4,
              child: child,
            ),
          );
        }

        // Verstecke das Child, zeige Fallback
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Widget das mehrere Berechtigungen prüft (ALLE müssen vorhanden sein)
class MultiPermissionGuard extends StatelessWidget {
  const MultiPermissionGuard({
    required this.permissions,
    required this.child,
    super.key,
    this.fallback,
  });
  final List<Permission> permissions;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return ActiveProfilePermission(
      test: (profile) => profile.hasAllPermissions(permissions),
      builder: (context, granted) =>
          granted ? child : (fallback ?? const SizedBox.shrink()),
    );
  }
}

/// Widget das prüft ob IRGENDEINE der Berechtigungen vorhanden ist
class AnyPermissionGuard extends StatelessWidget {
  const AnyPermissionGuard({
    required this.permissions,
    required this.child,
    super.key,
    this.fallback,
  });
  final List<Permission> permissions;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return ActiveProfilePermission(
      test: (profile) => profile.hasAnyPermission(permissions),
      builder: (context, granted) =>
          granted ? child : (fallback ?? const SizedBox.shrink()),
    );
  }
}

/// Hilfsfunktion: Zeigt SnackBar wenn keine Berechtigung
void showNoPermissionSnackBar(BuildContext context, Permission permission) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.block, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.commonNoPermission,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  l10n.permissionYouNeed(permission.label(l10n)),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      duration: const Duration(seconds: 3),
    ),
  );
}
