import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/diary_entry.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/modules/diary/entry_form_screen.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:dis_app/widgets/comments/comment_section.dart';
import 'package:dis_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

/// Entry Detail Screen - Zeigt vollständige Eintrags-Details mit Kommentaren
class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({
    required this.entryId,
    super.key,
  });
  final String entryId;

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late final DataEntry _dataEntry;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dataEntry = getIt<DataEntry>();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder(
      valueListenable: _dataEntry.diaryBox.listenable(),
      builder: (context, box, _) {
        final entry = _dataEntry.getDiaryEntryById(widget.entryId);

        if (entry == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.diaryEntryNotFound)),
            body: Center(child: Text(l10n.diaryEntryNotFoundMessage)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.diaryEntryDetailTitle),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            actions: [
              _buildEditButton(entry),
              _buildDeleteButton(entry),
            ],
          ),
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _EntryDetailCard(entry: entry),
              const SizedBox(height: 24),
              CommentSection(
                type: CommentableType.diary,
                parentId: entry.id,
                permission: Permission.commentOnDiaryEntries,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditButton(DiaryEntry entry) {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return const SizedBox.shrink();

    final canEdit =
        activeProfile.isAdmin ||
        activeProfile.hasPermission(Permission.editAllDiaryEntries) ||
        (activeProfile.hasPermission(Permission.editOwnDiaryEntries) &&
            entry.authorProfileId == activeProfile.id);

    if (!canEdit) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => EntryFormScreen(entry: entry),
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton(DiaryEntry entry) {
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return const SizedBox.shrink();

    final canDelete =
        activeProfile.isAdmin ||
        (activeProfile.hasPermission(Permission.deleteOwnDiaryEntries) &&
            entry.authorProfileId == activeProfile.id);

    if (!canDelete) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => _deleteEntry(entry),
    );
  }

  Future<void> _deleteEntry(DiaryEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: l10n.diaryEntryDeleteTitle,
      message: l10n.diaryEntryDeleteMessage,
      actionText: l10n.actionDelete,
    );

    if (confirmed) {
      try {
        await _dataEntry.deleteDiaryEntry(entry.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.diaryEntryDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorWithDetail(e.toString()))),
          );
        }
      }
    }
  }
}

/// Entry Detail Card - Zeigt vollständige Eintrags-Info
class _EntryDetailCard extends StatelessWidget {
  const _EntryDetailCard({required this.entry});
  final DiaryEntry entry;

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Autor + Zeit
            Row(
              children: [
                ProfileAvatar(profile: author, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        timeFormat.format(entry.timestamp),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      if (entry.editedAt != null)
                        Text(
                          '${l10n.commonEdited}: ${timeFormat.format(entry.editedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),
                _PriorityBadge(priority: entry.priority),
              ],
            ),

            const Divider(height: 32),

            // Titel
            Text(
              entry.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Beschreibung
            Text(
              entry.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),

            // Bilder
            if (entry.imagePaths != null && entry.imagePaths!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _ImageGallery(imagePaths: entry.imagePaths!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Priority Badge - Identisch zu EntryCard
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

/// Image Gallery Widget
class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.imagePaths});
  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 48),
            ),
          );
        },
      ),
    );
  }
}
