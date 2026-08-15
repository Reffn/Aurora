import 'package:dis_app/core/events/app_event.dart';
import 'package:dis_app/models/comment.dart';

/// Event wenn ein neuer Kommentar erstellt wurde
class CommentCreatedEvent extends AppEvent {
  CommentCreatedEvent(this.comment);

  final Comment comment;

  @override
  String toString() =>
      'CommentCreatedEvent(comment: ${comment.id}, type: ${comment.type})';
}

/// Event wenn ein Kommentar aktualisiert wurde
class CommentUpdatedEvent extends AppEvent {
  CommentUpdatedEvent(this.comment);

  final Comment comment;

  @override
  String toString() =>
      'CommentUpdatedEvent(comment: ${comment.id}, type: ${comment.type})';
}

/// Event wenn ein Kommentar gelöscht wurde
class CommentDeletedEvent extends AppEvent {
  CommentDeletedEvent({
    required this.commentId,
    required this.type,
    required this.parentId,
  });

  final String commentId;
  final CommentableType type;
  final String parentId;

  @override
  String toString() =>
      'CommentDeletedEvent(id: $commentId, type: $type, parent: $parentId)';
}
