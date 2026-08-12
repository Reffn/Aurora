import 'package:dis_app/core/base_service.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/events/diary_events.dart';
import 'package:dis_app/core/hive_box_names.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/models/comment.dart';
import 'package:dis_app/models/diary_comment.dart';
import 'package:dis_app/models/diary_entry.dart';
import 'package:dis_app/services/comment_service.dart';
import 'package:hive_ce/hive.dart';

/// Diary Service - Verwaltet Tagebuch-Einträge mit Kommentaren und Sichtbarkeits-Control
/// Verwendet Hive ValueListenable für reaktive UI-Updates
class DiaryService extends BaseService {
  DiaryService(super.eventBus);
  late Box<DiaryEntry> _entriesBox;
  late Box<DiaryComment> _commentsBox;

  @override
  Future<void> openBoxes() async {
    // PARALLEL: Öffne beide Boxes gleichzeitig für bessere Performance
    final results = await Future.wait([
      Hive.openBox<DiaryEntry>(HiveBoxNames.diaryEntries),
      Hive.openBox<DiaryComment>(HiveBoxNames.diaryComments),
    ]);

    _entriesBox = results[0] as Box<DiaryEntry>;
    _commentsBox = results[1] as Box<DiaryComment>;
  }

  @override
  void subscribeToEvents() {
    // Entry Events
    eventBus.on<DiaryEntryCreatedEvent>().listen(_handleEntryCreated);
    eventBus.on<DiaryEntryUpdatedEvent>().listen(_handleEntryUpdated);
    eventBus.on<DiaryEntryDeletedEvent>().listen(_handleEntryDeleted);

    // Comment Events
    eventBus.on<DiaryCommentCreatedEvent>().listen(_handleCommentCreated);
    eventBus.on<DiaryCommentUpdatedEvent>().listen(_handleCommentUpdated);
    eventBus.on<DiaryCommentDeletedEvent>().listen(_handleCommentDeleted);
  }

  @override
  Future<void> closeBoxes() async {
    await _entriesBox.close();
    await _commentsBox.close();
  }

  // ==================== Entries ====================

  /// Zugriff auf Entries-Box für ValueListenable
  Box<DiaryEntry> get entriesBox => _entriesBox;

  /// Alle Einträge abrufen (sortiert nach Datum, neueste zuerst)
  List<DiaryEntry> get entries {
    final list = _entriesBox.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(list);
  }

  /// Einträge die für ein Profil sichtbar sind
  /// Berücksichtigt: Autor, visibleTo, Admin-Rechte
  List<DiaryEntry> getEntriesVisibleToProfile(
    String profileId, {
    bool isAdmin = false,
  }) {
    // Admin sieht alles
    if (isAdmin) return entries;

    // Filtere nach Sichtbarkeit
    final list = _entriesBox.values
        .where((entry) => entry.canBeViewedBy(profileId))
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Einzelnen Eintrag nach ID abrufen
  DiaryEntry? getEntryById(String id) {
    try {
      return _entriesBox.values.firstWhere(
        (entry) => entry.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Einträge nach Autor abrufen
  List<DiaryEntry> getEntriesByAuthor(String profileId) {
    final list = _entriesBox.values
        .where((entry) => entry.authorProfileId == profileId)
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Einträge nach Stimmung filtern
  List<DiaryEntry> getEntriesByMood(EntryMood mood) {
    final list = _entriesBox.values
        .where((entry) => entry.mood == mood)
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Einträge nach Priorität filtern
  List<DiaryEntry> getEntriesByPriority(EntryPriority priority) {
    final list = _entriesBox.values
        .where((entry) => entry.priority == priority)
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Private Einträge eines Profils
  List<DiaryEntry> getPrivateEntries(String profileId) {
    final list = _entriesBox.values
        .where((entry) => entry.authorProfileId == profileId && entry.isPrivate)
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Geteilte Einträge (für alle sichtbar)
  List<DiaryEntry> getSharedEntries() {
    final list = _entriesBox.values
        .where((entry) => entry.isVisibleToAll)
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Entry-Erstellung
  void _handleEntryCreated(DiaryEntryCreatedEvent event) {
    try {
      _entriesBox.add(event.entry);
      logger.info(
        LogCategory.service,
        'Diary entry created',
        data: {
          'entryId': event.entry.id,
          'author': event.entry.authorProfileId,
          'isPrivate': event.entry.isPrivate,
          'visibleToAll': event.entry.isVisibleToAll,
          'mood': event.entry.mood?.name,
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error creating diary entry',
        data: {'entryId': event.entry.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Entry-Aktualisierung
  void _handleEntryUpdated(DiaryEntryUpdatedEvent event) {
    try {
      final entryKey = _entriesBox.keys.firstWhere(
        (key) => _entriesBox.get(key)?.id == event.entry.id,
      );
      _entriesBox.put(entryKey, event.entry);
      logger.info(
        LogCategory.service,
        'Diary entry updated',
        data: {'entryId': event.entry.id},
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error updating diary entry',
        data: {'entryId': event.entry.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Entry-Löschung (löscht auch alle zugehörigen Kommentare)
  void _handleEntryDeleted(DiaryEntryDeletedEvent event) {
    try {
      // Eintrag löschen
      final entryKey = _entriesBox.keys.firstWhere(
        (key) => _entriesBox.get(key)?.id == event.entryId,
      );
      _entriesBox.delete(entryKey);

      // Alle ALTEN DiaryComments zu diesem Eintrag löschen (legacy data)
      final commentKeysToDelete = _commentsBox.keys.where((key) {
        final comment = _commentsBox.get(key);
        return comment?.entryId == event.entryId;
      }).toList();

      for (final key in commentKeysToDelete) {
        _commentsBox.delete(key);
      }

      // Alle NEUEN unified Comments löschen (cascade delete)
      final commentService = getIt<CommentService>();
      commentService.deleteCommentsForParent(
        CommentableType.diary,
        event.entryId,
      );

      logger.info(
        LogCategory.service,
        'Diary entry deleted',
        data: {
          'entryId': event.entryId,
          'legacyCommentsDeleted': commentKeysToDelete.length,
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error deleting diary entry',
        data: {'entryId': event.entryId, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Comments ====================

  /// Zugriff auf Comments-Box für ValueListenable
  Box<DiaryComment> get commentsBox => _commentsBox;

  /// Alle Kommentare abrufen
  List<DiaryComment> get comments =>
      List.unmodifiable(_commentsBox.values.toList());

  /// Kommentare für einen bestimmten Eintrag abrufen (sortiert nach Zeit)
  List<DiaryComment> getCommentsForEntry(String entryId) {
    final list = _commentsBox.values
        .where((comment) => comment.entryId == entryId)
        .toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  /// Anzahl der Kommentare für einen Eintrag
  int getCommentCount(String entryId) {
    return _commentsBox.values
        .where((comment) => comment.entryId == entryId)
        .length;
  }

  /// Kommentar-Erstellung
  void _handleCommentCreated(DiaryCommentCreatedEvent event) {
    try {
      _commentsBox.add(event.comment);
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error creating diary comment',
        data: {'commentId': event.comment.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Kommentar-Aktualisierung
  void _handleCommentUpdated(DiaryCommentUpdatedEvent event) {
    try {
      final commentKey = _commentsBox.keys.firstWhere(
        (key) => _commentsBox.get(key)?.id == event.comment.id,
      );
      _commentsBox.put(commentKey, event.comment);
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error updating diary comment',
        data: {'commentId': event.comment.id, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Kommentar-Löschung
  void _handleCommentDeleted(DiaryCommentDeletedEvent event) {
    try {
      final commentKey = _commentsBox.keys.firstWhere(
        (key) => _commentsBox.get(key)?.id == event.commentId,
      );
      _commentsBox.delete(commentKey);
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Error deleting diary comment',
        data: {'commentId': event.commentId, 'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
  }

  /// Alle Daten löschen (Debug-Option)
  Future<void> clearAll() async {
    await _entriesBox.clear();
    await _commentsBox.clear();
  }
}
