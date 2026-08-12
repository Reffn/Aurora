import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/services/emergency_message_service.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/widgets/action_button_row.dart';
import 'package:dis_app/widgets/contact_avatar.dart';
import 'package:flutter/material.dart';

/// Card-Widget für Notfallkontakte mit großen Action-Buttons
class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({
    required this.contact,
    required this.emergencyService,
    super.key,
  });

  final Contact contact;
  final EmergencyMessageService emergencyService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPhone = contact.phone != null && contact.phone!.isNotEmpty;

    return Semantics(
      label: contact.name,
      enabled: true,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar + Name + Telefonnummer
              Row(
                children: [
                  // Avatar (dreieckig)
                  ContactAvatar(
                    imagePath: contact.imagePath,
                    name: contact.name,
                    size: 56,
                    showShadow: false,
                  ),

                  const SizedBox(width: 16),

                  // Name + Telefon
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (contact.relation != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            contact.relation!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        if (hasPhone) ...[
                          const SizedBox(height: 4),
                          Text(
                            contact.phone!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons (immer alle 3 anzeigen)
              ActionButtonRow(
                height: 48, // Etwas höher für bessere Touch-Targets
                buttons: [
                  ActionButtonConfig(
                    label: l10n.emergencyCall,
                    icon: Icons.phone,
                    color: AppColors.emergencyCall,
                    filled: true,
                    tooltip: hasPhone
                        ? l10n.emergencyCallTooltip
                        : l10n.emergencyNoPhone,
                    onPressed: hasPhone ? () => _callContact(context) : null,
                  ),
                  ActionButtonConfig(
                    label: l10n.emergencySms,
                    icon: Icons.sms,
                    color: AppColors.emergencySms,
                    filled: true,
                    tooltip: hasPhone
                        ? l10n.emergencySmsTooltip
                        : l10n.emergencyNoPhone,
                    onPressed: hasPhone ? () => _sendSms(context) : null,
                  ),
                  ActionButtonConfig(
                    label: l10n.emergencyApp,
                    icon: Icons.share,
                    color: AppColors.emergencyShare,
                    filled: true,
                    tooltip: l10n.emergencyShareTooltip,
                    onPressed: () => _shareMessage(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callContact(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      await emergencyService.callContact(contact);
    } catch (e) {
      if (!context.mounted) return;
      showCustomSnackBar(
        context,
        message: l10n.emergencyErrorCall(e.toString()),
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _sendSms(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      // Zeige Loading-Indicator während Nachricht generiert wird
      if (!context.mounted) return;
      showCustomSnackBar(
        context,
        message: l10n.emergencyMessagePreparing,
        duration: const Duration(seconds: 2),
      );

      await emergencyService.sendSmsToContact(contact);
    } catch (e) {
      if (!context.mounted) return;
      showCustomSnackBar(
        context,
        message: l10n.emergencyErrorSms(e.toString()),
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _shareMessage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      // Zeige Loading-Indicator während Nachricht generiert wird
      if (!context.mounted) return;
      showCustomSnackBar(
        context,
        message: l10n.emergencyMessagePreparing,
        duration: const Duration(seconds: 2),
      );

      await emergencyService.shareMessage();
    } catch (e) {
      if (!context.mounted) return;
      showCustomSnackBar(
        context,
        message: l10n.emergencyErrorShare(e.toString()),
        type: SnackBarType.error,
      );
    }
  }
}
