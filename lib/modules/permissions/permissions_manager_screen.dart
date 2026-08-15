import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/permissions/permission_detail_screen.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Permissions Manager - Zeigt alle Profile und deren Berechtigungen
/// Nur für Admins zugänglich
class PermissionsManagerScreen extends StatelessWidget {
  const PermissionsManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataEntry = getIt<DataEntry>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.permissionsTitle),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.15),
      ),
      body: ValueListenableBuilder(
        valueListenable: dataEntry.profilesBox.listenable(),
        builder: (context, box, _) {
          final profiles = dataEntry.getAllProfiles();

          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.permissionsNoProfiles,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info-Card
              Card(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.permissionsInfoText,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Profile-Liste
              ...profiles.map(
                (profile) => _ProfileCard(
                  profile: profile,
                  l10n: l10n,
                  onTap: () => _openPermissionDetail(context, profile),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openPermissionDetail(BuildContext context, Profile profile) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PermissionDetailScreen(profile: profile),
      ),
    );
  }
}

/// Card für ein einzelnes Profil
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.l10n,
    required this.onTap,
  });
  final Profile profile;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final permissionCount = profile.isAdmin
        ? l10n.permissionsAllRightsAdmin
        : l10n.permissionsCount(profile.permissions.length);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              ProfileAvatar(
                profile: profile,
                size: 56,
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile.isAdmin) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.amber,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.permissionsAdminBadge,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Bereichs-Symbole statt reiner Zahl: farbig heißt, dieser
                    // Anteil hat hier etwas, blass heißt nichts. Damit ist auf
                    // einen Blick lesbar, was jemand darf – ganz ohne Text.
                    _CategoryStrip(profile: profile),
                    const SizedBox(height: 4),
                    Text(
                      permissionCount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (profile.age != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.profileAgeYears(profile.age!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Pfeil
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reihe der Bereichs-Symbole für ein Profil
///
/// Ein Symbol je Kategorie. Farbig, wenn dieser Anteil in dem Bereich
/// mindestens ein Recht hat; blass, wenn nicht. Admins haben überall etwas.
class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final grouped = Permission.values.groupByCategory();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: PermissionCategory.values.map((category) {
        final permissions = grouped[category] ?? const <Permission>[];
        final has = permissions.any(profile.hasPermission);

        return Icon(
          category.icon,
          size: 18,
          color: has ? category.color : category.color.withValues(alpha: 0.22),
        );
      }).toList(),
    );
  }
}
