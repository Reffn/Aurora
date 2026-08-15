import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/events/comment_events.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/comment.dart';
import 'package:hive_ce/hive.dart';

/// Unified Comment Service - Verwaltet Kommentare für alle Module
/// Ersetzt separate DiaryCommentService und ContactCommentService
/// Verwendet event-driven architecture für konsistentes Verhalten
class CommentService extends BaseService {
  CommentService(super.eventBus);

  late Box<Comment> _commentsBox;

  @override
  Future<void> openBoxes() async {
    _commentsBox = await Hive.openBox<Comment>(HiveBoxNames.comments);
    logger.info(
      LogCategory.service,
      'Comment service initialized',
      data: {'commentCount': _commentsBox.length},
    );
  }

  @override
  void subscribeToEvents() {
    eventBus.on<CommentCreatedEvent>().listen(_handleCommentCreated);
    eventBus.on<CommentUpdatedEvent>().listen(_handleCommentUpdated);
    eventBus.on<CommentDeletedEvent>().listen(_handleCommentDeleted);
  }

  @override
  Future<void> closeBoxes() async {
    await _commentsBox.close();
  }

  // ==================== Public API ====================

  /// Zugriff auf Comments-Box für ValueListenable (reactive UI)
  Box<Comment> get commentsBox => _commentsBox;

  /// Alle Kommentare für ein bestimmtes Parent-Objekt abrufen
  /// Sortiert nach Timestamp (älteste zuerst)
  List<Comment> getComments(CommentableType type, String parentId) {
    final list = _commentsBox.values
        .where(
          (comment) => comment.type == type && comment.parentId == parentId,
        )
        .toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  /// Anzahl der Kommentare für ein Parent-Objekt
  int getCommentCount(CommentableType type, String parentId) {
    return _commentsBox.values
        .where(
          (comment) => comment.type == type && comment.parentId == parentId,
        )
        .length;
  }

  /// Alle Kommentare eines bestimmten Profils abrufen
  List<Comment> getCommentsByProfile(String profileId) {
    final list = _commentsBox.values
        .where((comment) => comment.profileId == profileId)
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Einzelnen Kommentar nach ID abrufen
  Comment? getCommentById(String commentId) {
    try {
      return _commentsBox.values.firstWhere(
        (comment) => comment.id == commentId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Cascade Delete: Löscht alle Kommentare für ein Parent-Objekt
  /// Wird aufgerufen wenn z.B. ein DiaryEntry, Contact oder CalendarEvent gelöscht wird
  Future<void> deleteCommentsForParent(
    CommentableType type,
    String parentId,
  ) async {
    try {
      final commentKeysToDelete = _commentsBox.keys.where((key) {
        final comment = _commentsBox.get(key);
        return comment != null &&
            comment.type == type &&
            comment.parentId == parentId;
      }).toList();

      for (final key in commentKeysToDelete) {
        await _commentsBox.delete(key);
      }

      logger.info(
        LogCategory.service,
        'Cascade deleted comments for parent',
        data: {
          'type': type.name,
          'parentId': parentId,
          'deletedCount': commentKeysToDelete.length,
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error cascade deleting comments',
        data: {
          'type': type.name,
          'parentId': parentId,
          'error': e.toString(),
        },
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Event Handlers ====================

  /// Kommentar-Erstellung
  void _handleCommentCreated(CommentCreatedEvent event) {
    try {
      _commentsBox.add(event.comment);
      logger.info(
        LogCategory.service,
        'Comment created',
        data: {
          'commentId': event.comment.id,
          'type': event.comment.type.name,
          'parentId': event.comment.parentId,
          'profileId': event.comment.profileId,
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error creating comment',
        data: {
          'commentId': event.comment.id,
          'error': e.toString(),
        },
        stackTrace: stackTrace,
      );
    }
  }

  /// Kommentar-Aktualisierung
  void _handleCommentUpdated(CommentUpdatedEvent event) {
    try {
      final commentKey = _commentsBox.keys.firstWhere(
        (key) => _commentsBox.get(key)?.id == event.comment.id,
      );
      _commentsBox.put(commentKey, event.comment);
      logger.info(
        LogCategory.service,
        'Comment updated',
        data: {
          'commentId': event.comment.id,
          'type': event.comment.type.name,
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error updating comment',
        data: {
          'commentId': event.comment.id,
          'error': e.toString(),
        },
        stackTrace: stackTrace,
      );
    }
  }

  /// Kommentar-Löschung
  void _handleCommentDeleted(CommentDeletedEvent event) {
    try {
      final commentKey = _commentsBox.keys.firstWhere(
        (key) => _commentsBox.get(key)?.id == event.commentId,
      );
      _commentsBox.delete(commentKey);
      logger.info(
        LogCategory.service,
        'Comment deleted',
        data: {
          'commentId': event.commentId,
          'type': event.type.name,
          'parentId': event.parentId,
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error deleting comment',
        data: {
          'commentId': event.commentId,
          'error': e.toString(),
        },
        stackTrace: stackTrace,
      );
    }
  }

  /// Alle Kommentare löschen (Debug-Option)
  Future<void> clearAll() async {
    await _commentsBox.clear();
    logger.warning(
      LogCategory.service,
      'All comments cleared (debug operation)',
    );
  }
}
