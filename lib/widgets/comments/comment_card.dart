import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable Comment Card - Zeigt einen einzelnen Kommentar an
/// Verwendet für: Diary, Contacts, Calendar, Medication, Finder
class CommentCard extends StatelessWidget {
  const CommentCard({
    required this.comment,
    super.key,
    this.onDelete,
  });

  final Comment comment;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dataEntry = getIt<DataEntry>();
    final author = dataEntry.getAllProfiles().firstWhere(
      (p) => p.id == comment.profileId,
      orElse: () => dataEntry.getAllProfiles().first, // Fallback
    );

    final timeFormat = DateFormat('dd.MM.yyyy • HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(profile: author, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        timeFormat.format(comment.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.editedAt != null)
                  Text(
                    'Bearbeitet',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red.withValues(alpha: 0.7),
                    tooltip: AppTexts.current.actionDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
