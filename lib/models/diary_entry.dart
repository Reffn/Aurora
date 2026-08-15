import 'package:dis_app/l10n/app_texts.dart';
import 'package:hive_ce/hive.dart';

part 'diary_entry.g.dart';

/// Priority-Level für Tagebuch-Einträge
@HiveType(typeId: 10)
enum EntryPriority {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high,

  @HiveField(3)
  critical;

  String get label {
    final texts = AppTexts.current;
    switch (this) {
      case EntryPriority.low:
        return texts.diaryPriorityLow;
      case EntryPriority.medium:
        return texts.diaryPriorityMedium;
      case EntryPriority.high:
        return texts.diaryPriorityHigh;
      case EntryPriority.critical:
        return texts.diaryPriorityCritical;
    }
  }
}

/// Mood-Level für Tagebuch-Einträge
@HiveType(typeId: 25)
enum EntryMood {
  @HiveField(0)
  veryHappy,

  @HiveField(1)
  happy,

  @HiveField(2)
  neutral,

  @HiveField(3)
  sad,

  @HiveField(4)
  verySad,

  @HiveField(5)
  anxious,

  @HiveField(6)
  angry,

  @HiveField(7)
  excited;

  String get label {
    switch (this) {
      case EntryMood.veryHappy:
        return AppTexts.current.moodVeryHappy;
      case EntryMood.happy:
        return AppTexts.current.moodHappy;
      case EntryMood.neutral:
        return AppTexts.current.moodNeutral;
      case EntryMood.sad:
        return AppTexts.current.moodSad;
      case EntryMood.verySad:
        return AppTexts.current.moodVerySad;
      case EntryMood.anxious:
        return AppTexts.current.moodAnxious;
      case EntryMood.angry:
        return AppTexts.current.moodAngry;
      case EntryMood.excited:
        return AppTexts.current.moodExcited;
    }
  }

  String get emoji {
    switch (this) {
      case EntryMood.veryHappy:
        return '😊';
      case EntryMood.happy:
        return '🙂';
      case EntryMood.neutral:
        return '😐';
      case EntryMood.sad:
        return '😔';
      case EntryMood.verySad:
        return '😢';
      case EntryMood.anxious:
        return '😰';
      case EntryMood.angry:
        return '😠';
      case EntryMood.excited:
        return '🤩';
    }
  }
}

/// Tagebuch Entry Model
/// Flexibles Tagebuch mit Sichtbarkeits-Control und Mood-Tracking
@HiveType(typeId: 11)
class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.authorProfileId,
    this.imagePaths,
    this.priority = EntryPriority.medium,
    this.editedAt,
    this.visibleTo,
    this.mood,
  });

  /// Von Map erstellen
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      authorProfileId: map['authorProfileId'] as String,
      imagePaths: map['imagePaths'] != null
          ? List<String>.from(map['imagePaths'] as List)
          : null,
      priority: EntryPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => EntryPriority.medium,
      ),
      editedAt: map['editedAt'] != null
          ? DateTime.parse(map['editedAt'] as String)
          : null,
      visibleTo: map['visibleTo'] != null
          ? List<String>.from(map['visibleTo'] as List)
          : null,
      mood: map['mood'] != null
          ? EntryMood.values.firstWhere(
              (e) => e.name == map['mood'],
              orElse: () => EntryMood.neutral,
            )
          : null,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String authorProfileId;

  @HiveField(5)
  final List<String>? imagePaths;

  @HiveField(6)
  final EntryPriority priority;

  @HiveField(7)
  final DateTime? editedAt;

  /// Sichtbarkeit: Profile IDs die diesen Eintrag sehen können
  /// null oder leer = nur Autor
  /// ['*'] = alle Profile
  /// ['id1', 'id2'] = nur diese Profile + Autor
  @HiveField(8)
  final List<String>? visibleTo;

  /// Stimmung beim Erstellen des Eintrags
  @HiveField(9)
  final EntryMood? mood;

  /// Ist dieser Eintrag für alle sichtbar?
  bool get isVisibleToAll => visibleTo?.contains('*') ?? false;

  /// Ist dieser Eintrag privat (nur für Autor)?
  bool get isPrivate => visibleTo == null || visibleTo!.isEmpty;

  /// Kann das angegebene Profil diesen Eintrag sehen?
  bool canBeViewedBy(String profileId) {
    // Autor kann immer sehen
    if (profileId == authorProfileId) return true;

    // Für alle sichtbar
    if (isVisibleToAll) return true;

    // Privat
    if (isPrivate) return false;

    // Explizit für dieses Profil freigegeben
    return visibleTo!.contains(profileId);
  }

  /// Kopie mit geänderten Werten
  DiaryEntry copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    String? authorProfileId,
    List<String>? imagePaths,
    EntryPriority? priority,
    DateTime? editedAt,
    List<String>? visibleTo,
    EntryMood? mood,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      authorProfileId: authorProfileId ?? this.authorProfileId,
      imagePaths: imagePaths ?? this.imagePaths,
      priority: priority ?? this.priority,
      editedAt: editedAt ?? this.editedAt,
      visibleTo: visibleTo ?? this.visibleTo,
      mood: mood ?? this.mood,
    );
  }

  /// Zu Map konvertieren (für Logging/Debugging)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'authorProfileId': authorProfileId,
      'imagePaths': imagePaths,
      'priority': priority.name,
      'editedAt': editedAt?.toIso8601String(),
      'visibleTo': visibleTo,
      'mood': mood?.name,
    };
  }

  @override
  String toString() {
    return 'DiaryEntry(id: $id, title: $title, timestamp: $timestamp, author: $authorProfileId, mood: ${mood?.emoji ?? 'none'})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
