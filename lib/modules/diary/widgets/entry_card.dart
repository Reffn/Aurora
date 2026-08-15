import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/diary_entry.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

/// Entry Card Widget - Zeigt einen Notfall-Tagebuch Eintrag in der Timeline an
class EntryCard extends StatelessWidget {
  const EntryCard({
    required this.entry,
    required this.onTap,
    super.key,
  });
  final DiaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataEntry = getIt<DataEntry>();
    final author = dataEntry.getProfileById(entry.authorProfileId);

    if (author == null) {
      return const SizedBox.shrink();
    }

    final timeFormat = DateFormat('dd.MM.yyyy • HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Autor + Zeit
              Row(
                children: [
                  ProfileAvatar(profile: author, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Tooltip(
                          message: timeFormat.format(entry.timestamp),
                          child: Text(
                            _getRelativeTime(
                              entry.timestamp,
                              l10n,
                              Localizations.localeOf(context).toLanguageTag(),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Priority Badge
                  _PriorityBadge(priority: entry.priority),
                ],
              ),

              const SizedBox(height: 12),

              // Titel
              Text(
                entry.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Beschreibung (gekürzt)
              Text(
                entry.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),

              // Bilder-Vorschau
              if (entry.imagePaths != null && entry.imagePaths!.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.imagePaths!.length > 4
                        ? 4
                        : entry.imagePaths!.length,
                    itemBuilder: (context, index) {
                      if (index == 3 && entry.imagePaths!.length > 4) {
                        // "+X mehr" Badge
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+${entry.imagePaths!.length - 3}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 32),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Footer: Kommentare + Edited
              const SizedBox(height: 12),
              ValueListenableBuilder(
                valueListenable: dataEntry.commentsBox.listenable(),
                builder: (context, box, _) {
                  final commentCount = dataEntry.getCommentCount(
                    CommentableType.diary,
                    entry.id,
                  );

                  return Row(
                    children: [
                      // Kommentar-Zähler
                      Icon(
                        Icons.comment_outlined,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$commentCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),

                      const Spacer(),

                      // "Bearbeitet" Hinweis
                      if (entry.editedAt != null)
                        Text(
                          l10n.commonEdited,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formatiert Zeit relativ (z.B. "vor 5 Minuten")
String _getRelativeTime(
  DateTime timestamp,
  AppLocalizations l10n,
  String locale,
) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inSeconds < 60) {
    return l10n.timeJustNow;
  } else if (difference.inMinutes < 60) {
    return l10n.timeMinutesAgo(difference.inMinutes);
  } else if (difference.inHours < 24) {
    return l10n.timeHoursAgo(difference.inHours);
  } else if (difference.inDays < 7) {
    return l10n.timeDaysAgo(difference.inDays);
  } else {
    // Über 7 Tage: Absolutes Datum
    return DateFormat.yMd(locale).format(timestamp);
  }
}

/// Priority Badge Widget
class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final EntryPriority priority;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (priority) {
      case EntryPriority.low:
        color = Colors.green;
        icon = Icons.arrow_downward;
      case EntryPriority.medium:
        color = Colors.orange;
        icon = Icons.remove;
      case EntryPriority.high:
        color = Colors.red;
        icon = Icons.arrow_upward;
      case EntryPriority.critical:
        color = Colors.red.shade900;
        icon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
