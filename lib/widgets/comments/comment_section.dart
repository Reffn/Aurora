import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/widgets/comments/comment_card.dart';
import 'package:dis_app/widgets/comments/comment_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Reusable Comment Section - Kommentare anzeigen + erstellen
///
/// Verwendet für: Diary, Contacts, Calendar, Medication, Finder
///
/// Features:
/// - ValueListenableBuilder für reactive UI
/// - Permission-basierte Input-Anzeige
/// - Event-driven Kommentar-Erstellung
/// - Cascade Delete via CommentService
///
/// Beispiel:
/// ```dart
/// CommentSection(
///   type: CommentableType.diary,
///   parentId: diaryEntry.id,
///   permission: Permission.commentOnDiaryEntries,
/// )
/// ```
class CommentSection extends StatefulWidget {
  const CommentSection({
    required this.type,
    required this.parentId,
    required this.permission,
    super.key,
    this.title = 'Kommentare',
  });

  final CommentableType type;
  final String parentId;
  final Permission permission;
  final String title;

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();
  final _dataEntry = getIt<DataEntry>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return;

    final comment = Comment(
      id: const Uuid().v4(),
      type: widget.type,
      parentId: widget.parentId,
      profileId: activeProfile.id,
      content: content,
      timestamp: DateTime.now(),
    );

    // DataEntry erstellt Kommentar (mit Validierung & Logging)
    await _dataEntry.createComment(comment);

    // Input-Feld leeren
    _commentController.clear();
  }

  Future<void> _deleteComment(Comment comment) async {
    // Permission Check
    final activeProfile = _dataEntry.getActiveProfile();
    if (activeProfile == null) return;

    final canDelete =
        activeProfile.isAdmin || comment.profileId == activeProfile.id;
    if (!canDelete) return;

    // DataEntry löscht Kommentar (mit Logging)
    await _dataEntry.deleteComment(
      comment.id,
      comment.type,
      comment.parentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments List
        ValueListenableBuilder(
          valueListenable: _dataEntry.commentsBox.listenable(),
          builder: (context, box, _) {
            final comments = _dataEntry.getComments(
              widget.type,
              widget.parentId,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.comment, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.title} (${comments.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (comments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        AppTexts.current.commentsNoneYet,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ...comments.map(
                    (comment) => CommentCard(
                      comment: comment,
                      onDelete: () => _deleteComment(comment),
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Input Bar
        CommentInputBar(
          controller: _commentController,
          onSend: _sendComment,
          permission: widget.permission,
        ),
      ],
    );
  }
}
