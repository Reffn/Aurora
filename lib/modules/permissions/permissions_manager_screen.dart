import 'dart:async';

import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/part_right.dart';
import 'package:dis_app/models/part_right_text.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/permissions/permission_detail_screen.dart';
import 'package:dis_app/modules/permissions/widgets/parts_group_header.dart';
import 'package:dis_app/modules/profile/widgets/paused_parts_sheet.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// „Anteile & Rechte“: wer gerade da ist, wer pausiert, und was jeder darf.
///
/// Ersetzt sechzig Kästchen in neun rot markierten Kategorien. Ruhig mit
/// Absicht: Kräftige Farbe gehört Halt, Notfall und Hilfe (Richtlinie 4).
/// Was ein Anteil darf, zeigen gedämpfte Symbole statt einer Zahl.
class PermissionsManagerScreen extends StatelessWidget {
  const PermissionsManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataEntry = getIt<DataEntry>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.partsAndRightsTitle),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.15),
      ),
      body: ValueListenableBuilder(
        valueListenable: dataEntry.profilesBox.listenable(),
        builder: (context, _, _) {
          final active = dataEntry.getProfiles();
          final paused = dataEntry.getPausedProfiles();
          // Ohne Recht nur die Namen, kein Knopf, der scheitern müsste.
          final mayResume = dataEntry.canResumeProfiles();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PartsGroupHeader(l10n.partsActiveHeader),
              for (final profile in active)
                _ActivePartCard(
                  profile: profile,
                  onTap: () => _openDetail(context, profile),
                ),
              if (paused.isNotEmpty) ...[
                const SizedBox(height: 16),
                PartsGroupHeader(l10n.partsPausedHeader),
                for (final profile in paused)
                  _PausedPartCard(profile: profile, mayResume: mayResume),
              ],
            ],
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, Profile profile) {
    unawaited(
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => PermissionDetailScreen(profile: profile),
        ),
      ),
    );
  }
}

/// Ein aktiver Anteil: Avatar, Name und darunter, was er darf.
class _ActivePartCard extends StatelessWidget {
  const _ActivePartCard({required this.profile, required this.onTap});

  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProfileAvatar(
                profile: profile,
                size: 56,
                avatarSize: AvatarSize.small,
                showName: false,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (profile.isAdmin)
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 16,
                            color: AppColors.mist.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.rightsAdminSummary,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mist.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      _RightsIcons(profile: profile),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.mist.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Die Symbole der eingeschalteten Schalter, gedämpft. Halb gesetzte
/// zählen nicht mit, wie der Schalter selbst steht dann auf aus. Schalter
/// ohne Wirkung zeigt die Seite nicht, also hier auch kein Symbol.
class _RightsIcons extends StatelessWidget {
  const _RightsIcons({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final on = PartRight.values.where(
      (right) =>
          right.hasEffect && right.stateFor(profile) == PartRightState.on,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final right in on)
          Icon(
            right.icon,
            size: 18,
            color: AppColors.mist.withValues(alpha: 0.55),
            semanticLabel: right.label(l10n),
          ),
      ],
    );
  }
}

/// Ein pausierter Anteil: Avatar, Name und „Wieder aufnehmen“, wenn der
/// aktive Anteil das darf.
class _PausedPartCard extends StatelessWidget {
  const _PausedPartCard({required this.profile, required this.mayResume});

  final Profile profile;
  final bool mayResume;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        // Wrap statt Row: Bei großer Schrift rutscht der Knopf unter den
        // Namen, statt ihn abzuschneiden.
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileAvatar(
                  profile: profile,
                  size: 44,
                  avatarSize: AvatarSize.small,
                  showName: false,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    profile.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            if (mayResume)
              OutlinedButton.icon(
                // Zurückholen und Meldung in einem, auch wenn der Schirm
                // inzwischen weg ist.
                onPressed: () => unawaited(resumePausedPart(context, profile)),
                icon: const Icon(Icons.play_circle_outline),
                label: Text(l10n.profileResumeAction),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.paper,
                  side: BorderSide(
                    color: AppColors.paper.withValues(alpha: 0.3),
                  ),
                  minimumSize: const Size(48, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
