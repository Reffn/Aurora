import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/delete_all_data.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/settings/sections/settings_section_parts.dart';
import 'package:dis_app/services/navigation_service.dart';
import 'package:dis_app/services/password_reset_service.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Debug-Optionen. Erscheint nur in Entwicklungsbauten; das entscheidet
/// `SettingsScreen`.
class SettingsDebugSection extends StatefulWidget {
  const SettingsDebugSection({super.key});

  @override
  State<SettingsDebugSection> createState() => _SettingsDebugSectionState();
}

class _SettingsDebugSectionState extends State<SettingsDebugSection>
    with AutomaticKeepAliveClientMixin {
  // Die Liste baut weit entfernte Abschnitte ab. Laufende Abläufe,
  // geladene Zahlen und Schalterzustände sollen das überleben.
  @override
  bool get wantKeepAlive => true;

  late final _navigationService = getIt<NavigationService>();
  bool _isDeleting = false;

  Future<void> _showDeleteConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: l10n.settingsDeleteConfirmTitle,
      message: l10n.settingsDeleteConfirmMessage,
      actionText: l10n.settingsDeleteAll,
    );

    if (confirmed) {
      await _deleteAllData();
    }
  }

  Future<void> _deleteAllData() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isDeleting = true;
    });

    try {
      // Ein einziger Löschweg für Einstellungen und Notfall-Reset. Vorher
      // stand hier eine eigene Fassung, die Boxen und Anhänge kannte, den
      // Standortverlauf und das Übertragungsprotokoll aber nicht — und die
      // Löschfehler verschluckte, um danach Erfolg zu melden.
      final ergebnis = await deleteAllLocalData();
      await _navigationService.clearAll();

      if (mounted) {
        showCustomSnackBar(
          context,
          message: ergebnis.isComplete
              ? l10n.settingsAllDataDeleted
              : l10n.settingsDeleteIncomplete,
          type: ergebnis.isComplete ? SnackBarType.success : SnackBarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.errorWithDetail(e.toString()),
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
          l10n.settingsSectionDebug,
          color: Colors.orange,
        ),
        SettingsSectionNote(l10n.settingsDebugInfo),
        const SizedBox(height: 8),
        // Debug-Button: Reset-Timer auf 20s setzen
        ValueListenableBuilder(
          valueListenable: getIt<DataEntry>().profilesBox.listenable(),
          builder: (context, Box<Profile> box, _) {
            final passwordResetService = getIt<PasswordResetService>();
            // Fristen sitzen am Profil; für den Debug-Sprung zählt der
            // erste noch laufende Reset.
            final laufend = box.values
                .where((p) => p.hasActiveReset && !p.isResetExpired)
                .toList();

            if (laufend.isEmpty) {
              return const SizedBox.shrink();
            }

            final profile = laufend.first;
            final profileName = profile.name;
            final rest = profile.resetEndsAt!.difference(DateTime.now());

            final timeText = rest.inHours > 0
                ? '${rest.inHours}h ${rest.inMinutes.remainder(60)}m'
                : rest.inMinutes > 0
                ? '${rest.inMinutes}m ${rest.inSeconds.remainder(60)}s'
                : '${rest.inSeconds.clamp(0, 60)}s';

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              color: Colors.orange.shade900.withValues(alpha: 0.3),
              child: ListTile(
                leading: const Icon(
                  Icons.fast_forward,
                  color: Colors.orange,
                  size: 32,
                ),
                title: Text(
                  l10n.settingsDebugSkipCooldown,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  l10n.settingsResetPendingFor(profileName, timeText),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  // Hol context vor dem await
                  final snackContext = context;
                  final success = await passwordResetService
                      .skipToLastTwentySeconds(profile.id);
                  if (mounted && snackContext.mounted) {
                    showCustomSnackBar(
                      snackContext,
                      message: success
                          ? l10n.settingsDebugCooldownSet
                          : l10n.settingsDebugCooldownError,
                      type: success ? SnackBarType.warning : SnackBarType.error,
                    );
                  }
                },
              ),
            );
          },
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.red.shade900.withValues(alpha: 0.3),
          child: ListTile(
            leading: _isDeleting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 32,
                  ),
            title: Text(
              l10n.settingsDeleteAllData,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            subtitle: Text(
              l10n.settingsDeleteAllDataSubtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: _isDeleting
                ? null
                : const Icon(Icons.arrow_forward_ios, size: 16),
            enabled: !_isDeleting,
            onTap: _isDeleting ? null : _showDeleteConfirmation,
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }
}
