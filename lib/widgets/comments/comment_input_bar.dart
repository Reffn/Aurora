import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/permission.dart';
import 'package:flutter/material.dart';

/// Reusable Comment Input Bar - Input-Feld für neue Kommentare
/// Permission-basiert: Nur sichtbar wenn User Berechtigung hat
class CommentInputBar extends StatelessWidget {
  const CommentInputBar({
    required this.controller,
    required this.onSend,
    required this.permission,
    super.key,
    this.hintText,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final Permission permission;

  /// Bleibt offen, wenn nichts uebergeben wird: der Standardtext kommt aus
  /// der Sprache und braucht dafuer den Kontext — ein Vorgabewert im
  /// Konstruktor waere fest verdrahtet.
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final activeProfile = getIt<DataEntry>().getActiveProfile();
    if (activeProfile == null) return const SizedBox.shrink();

    // Permission Check
    final canComment =
        activeProfile.isAdmin || activeProfile.hasPermission(permission);
    if (!canComment) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText:
                    hintText ??
                    AppLocalizations.of(context).commentWritePlaceholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send, size: 18, color: Colors.white),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
