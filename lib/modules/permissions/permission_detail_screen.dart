import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/part_right.dart';
import 'package:dis_app/models/part_right_text.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/permissions/widgets/parts_group_header.dart';
import 'package:dis_app/modules/profile/widgets/pause_profile_dialog.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Was ein Anteil darf: für einen Admin eine ruhige Karte, sonst die
/// Schalter, die etwas bewirken (`PartRight.hasEffect`), in ihren Gruppen.
///
/// Angeboten wird nur, was gelingt („errorless“): Admin-Knöpfe nur für einen
/// aktiven Admin, Abgeben nur, wo der Dienst es zulässt, Pausieren nur mit
/// Recht.
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
  final DataEntry _dataEntry = getIt<DataEntry>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.partsAndRightsTitle),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.15),
      ),
      body: ValueListenableBuilder(
        valueListenable: _dataEntry.profilesBox.listenable(),
        builder: (context, _, _) {
          // Aus dem Bestand statt aus dem Widget, damit jeder Schalter sofort
          // zeigt, was gespeichert ist.
          final profile =
              _dataEntry.getProfileById(widget.profile.id) ?? widget.profile;
          final active = _dataEntry.getActiveProfile();
          final activeIsAdmin = active?.isAdmin == true;
          final isSelf = active?.id == profile.id;
          final mayGrant =
              active?.hasPermission(Permission.managePermissions) == true;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(profile: profile),
              const SizedBox(height: 24),
              if (profile.isAdmin) ...[
                const _AdminCard(),
                if (_dataEntry.canRevokeAdmin(profile.id))
                  Card(
                    margin: const EdgeInsets.only(top: 12),
                    clipBehavior: Clip.antiAlias,
                    child: _ActionTile(
                      icon: Icons.remove_moderator_outlined,
                      label: l10n.rightsRevokeAdmin,
                      onTap: () => _revokeAdmin(profile),
                    ),
                  ),
              ] else
                for (final group in PartRightGroup.values)
                  _RightsGroup(
                    group: group,
                    profile: profile,
                    rights: [
                      for (final right in PartRight.values)
                        // Nur Schalter, die etwas bewirken (Regel 32). Auf
                        // der eigenen Seite fehlt „Rechte vergeben“: Sonst
                        // sperrt sich ein Nicht-Admin mit einem Tipp selbst
                        // aus.
                        if (right.group == group &&
                            right.hasEffect &&
                            !(isSelf && right == PartRight.grantRights))
                          right,
                    ],
                    onChanged: mayGrant
                        ? (right, {required on}) =>
                              _setRight(profile, right, on: on)
                        : null,
                    trailing:
                        group == PartRightGroup.management && activeIsAdmin
                        ? _ActionTile(
                            icon: Icons.admin_panel_settings_outlined,
                            label: l10n.permissionsMakeAdminButton,
                            onTap: () => _makeAdmin(profile),
                          )
                        : null,
                  ),
              if (_dataEntry.canPauseProfile(profile.id)) ...[
                const SizedBox(height: 8),
                // Ruhiger Textknopf: Pausieren nimmt nichts weg, der Rückweg
                // steht unter „Pausiert“.
                Center(
                  child: TextButton.icon(
                    onPressed: () => _pause(profile),
                    icon: const Icon(Icons.pause_circle_outline),
                    label: Text(l10n.partsPauseNamed(profile.name)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mist,
                      minimumSize: const Size(48, 48),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _setRight(
    Profile profile,
    PartRight right, {
    required bool on,
  }) async {
    final l10n = AppLocalizations.of(context);
    final ok = await _dataEntry.setPartRight(profile.id, right, on: on);
    // Angeboten wird der Schalter nur mit Recht. Hier landet nur, wem es
    // zwischen Anzeigen und Tippen genommen wurde.
    if (!ok && mounted) {
      showCustomSnackBar(context, message: l10n.commonNoPermission);
    }
  }

  Future<void> _makeAdmin(Profile profile) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.showYesNo(
      context: context,
      title: l10n.permissionsMakeAdminTitle,
      message: l10n.permissionsMakeAdminMessage(profile.name),
      yesText: l10n.actionConfirm,
      noText: l10n.actionCancel,
      icon: Icons.admin_panel_settings_outlined,
    );
    if (!confirmed) return;

    final ok = await _dataEntry.makeAdmin(profile.id);
    if (!ok && mounted) {
      showCustomSnackBar(context, message: l10n.commonNoPermission);
    }
  }

  Future<void> _revokeAdmin(Profile profile) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.showYesNo(
      context: context,
      title: l10n.rightsRevokeAdmin,
      message: l10n.permissionsRevokeAdminMessage(profile.name),
      yesText: l10n.actionConfirm,
      noText: l10n.actionCancel,
      icon: Icons.remove_moderator_outlined,
    );
    if (!confirmed) return;

    final ok = await _dataEntry.revokeAdmin(profile.id);
    if (!ok && mounted) {
      showCustomSnackBar(context, message: l10n.commonNoPermission);
    }
  }

  Future<void> _pause(Profile profile) async {
    await showPauseProfileDialog(context, profile);
    if (!mounted) return;
    // Pausiert gibt es hier nichts mehr zu schalten. Zurück zur Liste, dort
    // steht der Anteil unter „Pausiert“ mit dem Rückweg.
    if (_dataEntry.getProfileById(profile.id)?.isActive == false) {
      Navigator.pop(context);
    }
  }
}

/// Kopf: Avatar, Name und Alter.
class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final age = profile.age;

    return Row(
      children: [
        ProfileAvatar(profile: profile, size: 72, showName: false),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (age != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.profileAgeYears(age),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mist.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Für einen Admin statt einer Liste gesperrter Kästchen: eine Zeile.
class _AdminCard extends StatelessWidget {
  const _AdminCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: AppColors.mist,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.rightsAdminSummary,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Eine Gruppe mit Überschrift und ihren Schaltern, höchstens fünf
/// (Richtlinie 3).
class _RightsGroup extends StatelessWidget {
  const _RightsGroup({
    required this.group,
    required this.profile,
    required this.rights,
    required this.onChanged,
    this.trailing,
  });

  final PartRightGroup group;
  final Profile profile;
  final List<PartRight> rights;

  /// `null`, wenn der aktive Anteil keine Rechte vergeben darf: Dann sind
  /// die Schalter nur zu lesen.
  final void Function(PartRight right, {required bool on})? onChanged;

  /// Eine Zeile am Ende der Gruppe, etwa „Zum Administrator machen“.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final change = onChanged;

    // Keine Überschrift über einer leeren Karte.
    if (rights.isEmpty && trailing == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PartsGroupHeader(group.label(l10n)),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, right) in rights.indexed) ...[
                  if (index > 0) const Divider(height: 1),
                  _RightSwitch(
                    right: right,
                    state: right.stateFor(profile),
                    onChanged: change == null
                        ? null
                        : (on) => change(right, on: on),
                  ),
                ],
                if (trailing case final row?) ...[
                  const Divider(height: 1),
                  row,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ein Schalter mit Symbol und Wort, ohne Beschreibung. Halb gesetzt steht
/// er auf aus und sagt es; Einschalten setzt dann alle seine Rechte.
class _RightSwitch extends StatelessWidget {
  const _RightSwitch({
    required this.right,
    required this.state,
    required this.onChanged,
  });

  final PartRight right;
  final PartRightState state;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SwitchListTile(
      secondary: Icon(right.icon, color: AppColors.mist),
      title: Text(right.label(l10n)),
      subtitle: state == PartRightState.partly
          ? Text(
              l10n.rightsPartly,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mist.withValues(alpha: 0.8),
              ),
            )
          : null,
      value: state == PartRightState.on,
      onChanged: onChanged,
    );
  }
}

/// Eine ruhige Zeile für eine Handlung mit Bestätigung.
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.mist),
      title: Text(label),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.mist.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}
