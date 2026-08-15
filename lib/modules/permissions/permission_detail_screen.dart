import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/permission_text.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:dis_app/widgets/progress_dots.dart';
import 'package:dis_app/widgets/state_symbol.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Permission Detail Screen - Zeigt und editiert alle Berechtigungen eines Profils
class PermissionDetailScreen extends StatefulWidget {
  const PermissionDetailScreen({
    required this.profile,
    super.key,
  });
  final Profile profile;

  @override
  State<PermissionDetailScreen> createState() => _PermissionDetailScreenState();
}

class _PermissionDetailScreenState extends State<PermissionDetailScreen> {
  final _dataEntry = getIt<DataEntry>();

  /// Prüft, ob das gegebene Profil das erste (älteste) Profil ist
  bool _isFirstProfile(Profile profile) {
    final allProfiles = _dataEntry.getProfiles();
    if (allProfiles.isEmpty) return false;

    final firstProfile = allProfiles.reduce(
      (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
    );
    return profile.id == firstProfile.id;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.permissionsDetailTitle(widget.profile.name)),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.15),
      ),
      body: ValueListenableBuilder(
        valueListenable: _dataEntry.profilesBox.listenable(),
        builder: (context, box, _) {
          // Aktuelles Profil aus Box holen (für Live-Updates)
          final currentProfile =
              _dataEntry.profilesBox.get(widget.profile.id) ?? widget.profile;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profil-Header
              _ProfileHeader(profile: currentProfile, l10n: l10n),
              const SizedBox(height: 24),

              // Admin-Toggle (falls berechtigt)
              if (!currentProfile.isAdmin)
                _AdminToggle(
                  profile: currentProfile,
                  l10n: l10n,
                  onToggle: () => _makeAdmin(currentProfile, l10n),
                  isRevoke: false,
                )
              else if (currentProfile.isAdmin &&
                  !_isFirstProfile(currentProfile))
                _AdminToggle(
                  profile: currentProfile,
                  l10n: l10n,
                  onToggle: () => _revokeAdmin(currentProfile, l10n),
                  isRevoke: true,
                ),

              // Permissions nach Kategorie gruppiert
              ..._buildPermissionSections(currentProfile, l10n),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildPermissionSections(
    Profile profile,
    AppLocalizations l10n,
  ) {
    // Gruppiere alle Permissions nach Kategorie
    final grouped = Permission.values.groupByCategory();
    final sections = <Widget>[];

    // Sortierte Kategorien (System zuerst)
    final orderedCategories = [
      PermissionCategory.system,
      PermissionCategory.chat,
      PermissionCategory.calendar,
      PermissionCategory.medication,
      PermissionCategory.contacts,
      PermissionCategory.finder,
      PermissionCategory.diary,
      PermissionCategory.emergency,
      PermissionCategory.security,
    ];

    for (final category in orderedCategories) {
      final permissions = grouped[category];
      if (permissions == null || permissions.isEmpty) continue;

      sections.add(
        _PermissionSection(
          category: category,
          permissions: permissions,
          profile: profile,
          l10n: l10n,
          onToggle: (permission) =>
              _togglePermission(profile, permission, l10n),
        ),
      );
      sections.add(const SizedBox(height: 16));
    }

    return sections;
  }

  Future<void> _togglePermission(
    Profile profile,
    Permission permission,
    AppLocalizations l10n,
  ) async {
    final success = await _dataEntry.togglePermission(profile.id, permission);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.permissionsChangeError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makeAdmin(Profile profile, AppLocalizations l10n) async {
    // Bestätigungsdialog
    final confirmed = await ConfirmationDialog.showYesNo(
      context: context,
      title: l10n.permissionsMakeAdminTitle,
      message: l10n.permissionsMakeAdminMessage(profile.name),
      yesText: l10n.actionConfirm,
      noText: l10n.actionCancel,
      icon: Icons.admin_panel_settings,
    );

    if (confirmed) {
      await _dataEntry.makeAdmin(profile.id);
    }
  }

  Future<void> _revokeAdmin(Profile profile, AppLocalizations l10n) async {
    // Bestätigungsdialog
    final confirmed = await ConfirmationDialog.showYesNo(
      context: context,
      title: l10n.permissionsRevokeAdminTitle,
      message: l10n.permissionsRevokeAdminMessage(profile.name),
      yesText: l10n.actionRemove,
      noText: l10n.actionCancel,
      icon: Icons.remove_moderator,
    );

    if (confirmed) {
      final success = await _dataEntry.revokeAdmin(profile.id);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.permissionsRevokeAdminError),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

/// Profil-Header mit Avatar und Info
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.l10n});
  final Profile profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ProfileAvatar(profile: profile, size: 64),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile.age != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.profileAgeYears(profile.age!),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (profile.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.permissionsAdministrator,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      l10n.permissionsCount(profile.permissions.length),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Admin-Toggle Button
class _AdminToggle extends StatelessWidget {
  const _AdminToggle({
    required this.profile,
    required this.l10n,
    required this.onToggle,
    required this.isRevoke,
  });
  final Profile profile;
  final AppLocalizations l10n;
  final VoidCallback onToggle;
  final bool isRevoke;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = isRevoke ? Colors.orange : Colors.amber;
    final icon = isRevoke ? Icons.remove_moderator : Icons.admin_panel_settings;
    final title = isRevoke
        ? l10n.permissionsRevokeAdminTitle
        : l10n.permissionsMakeAdminButton;
    final subtitle = isRevoke
        ? l10n.permissionsRevokeAdminSubtitle
        : l10n.permissionsMakeAdminSubtitle;

    return Card(
      color: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

/// Permission-Section (eine Kategorie)
class _PermissionSection extends StatelessWidget {
  const _PermissionSection({
    required this.category,
    required this.permissions,
    required this.profile,
    required this.l10n,
    required this.onToggle,
  });
  final PermissionCategory category;
  final List<Permission> permissions;
  final Profile profile;
  final AppLocalizations l10n;
  final void Function(Permission) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeCount = permissions.where(profile.hasPermission).length;

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: category == PermissionCategory.system,
          leading: Icon(category.icon, color: category.color, size: 32),
          title: Text(
            _categoryTitle(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // Zusätzlich zur Zahl ein Punktemuster: wie viele Rechte in dieser
          // Kategorie offen sind, ist so ohne Lesen abzählbar.
          subtitle: Row(
            children: [
              ProgressDots(
                active: activeCount,
                total: permissions.length,
                color: category.color,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.permissionsActiveCount(activeCount, permissions.length),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          children: [
            ...permissions.map(
              (permission) => _PermissionTile(
                permission: permission,
                categoryColor: category.color,
                enabled: profile.isAdmin || profile.hasPermission(permission),
                isAdmin: profile.isAdmin,
                onToggle: () => onToggle(permission),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryTitle() {
    switch (category) {
      case PermissionCategory.system:
        return l10n.permissionsCategorySystem;
      case PermissionCategory.chat:
        return l10n.permissionsCategoryChat;
      case PermissionCategory.calendar:
        return l10n.permissionsCategoryCalendar;
      case PermissionCategory.medication:
        return l10n.permissionsCategoryMedication;
      case PermissionCategory.contacts:
        return l10n.permissionsCategoryContacts;
      case PermissionCategory.finder:
        return l10n.permissionsCategoryFinder;
      case PermissionCategory.diary:
        return l10n.permissionsCategoryDiary;
      case PermissionCategory.emergency:
        return l10n.permissionsCategoryEmergency;
      case PermissionCategory.security:
        return l10n.permissionsCategorySecurity;
    }
  }
}

/// Einzelne Permission-Checkbox
class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.permission,
    required this.categoryColor,
    required this.enabled,
    required this.isAdmin,
    required this.onToggle,
  });
  final Permission permission;
  final Color categoryColor;
  final bool enabled;
  final bool isAdmin;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Gefährliche Rechte tragen ihre eigene Farbe, damit sie auch dann
    // herausstechen, wenn niemand die Beschreibung liest.
    final activeColor = permission.dangerous
        ? Colors.red.shade300
        : categoryColor;

    return CheckboxListTile(
      value: enabled,
      onChanged: isAdmin
          ? null
          : (_) => onToggle(), // Admin kann nicht geändert werden
      title: Row(
        children: [
          Flexible(child: Text(permission.label(l10n))),
          if (permission.dangerous) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.warning,
              size: 16,
              color: Colors.red.shade300,
            ),
          ],
        ],
      ),
      subtitle: Text(
        permission.description(l10n),
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
      // Das Symbol trägt die Aussage: gefüllter Kreis in Farbe heißt erlaubt,
      // blasser Umriss heißt nicht erlaubt. Die Checkbox rechts sagt dasselbe
      // noch einmal – wer nicht liest, braucht nur eine der beiden.
      secondary: StateSymbol(
        icon: permission.icon,
        color: activeColor,
        active: enabled,
        badge: isAdmin ? Icons.lock : null,
      ),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
