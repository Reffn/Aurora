import 'package:dis_app/core/events/app_event.dart';
import 'package:dis_app/models/diary_comment.dart';
import 'package:dis_app/models/diary_entry.dart';

/// Event: Neuer Tagebuch-Eintrag wurde erstellt
class DiaryEntryCreatedEvent extends AppEvent {
  DiaryEntryCreatedEvent(this.entry);
  final DiaryEntry entry;
}

/// Event: Tagebuch-Eintrag wurde aktualisiert
class DiaryEntryUpdatedEvent extends AppEvent {
  DiaryEntryUpdatedEvent(this.entry);
  final DiaryEntry entry;
}

/// Event: Tagebuch-Eintrag wurde gelöscht
class DiaryEntryDeletedEvent extends AppEvent {
  DiaryEntryDeletedEvent(this.entryId);
  final String entryId;
}

/// Event: Neuer Kommentar wurde erstellt
class DiaryCommentCreatedEvent extends AppEvent {
  DiaryCommentCreatedEvent(this.comment);
  final DiaryComment comment;
}

/// Event: Kommentar wurde aktualisiert
class DiaryCommentUpdatedEvent extends AppEvent {
  DiaryCommentUpdatedEvent(this.comment);
  final DiaryComment comment;
}

/// Event: Kommentar wurde gelöscht
class DiaryCommentDeletedEvent extends AppEvent {
  DiaryCommentDeletedEvent(this.commentId);
  final String commentId;
}
