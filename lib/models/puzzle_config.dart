import 'package:dis_app/l10n/app_texts.dart';
import 'package:hive_ce/hive.dart';

part 'puzzle_config.g.dart';

/// Typ des Puzzles
@HiveType(typeId: 19)
enum PuzzleType {
  @HiveField(0)
  jigsaw, // Klassisches Puzzle mit Drag & Drop

  @HiveField(1)
  sliding; // Schiebepuzzle (15-Puzzle Style)

  /// Human-readable Label für UI
  String get label {
    switch (this) {
      case PuzzleType.jigsaw:
        return AppTexts.current.puzzleTypeJigsaw;
      case PuzzleType.sliding:
        return AppTexts.current.puzzleTypeSliding;
    }
  }

  /// Beschreibung für UI
  String get description {
    switch (this) {
      case PuzzleType.jigsaw:
        return AppTexts.current.puzzleDragHint;
      case PuzzleType.sliding:
        return AppTexts.current.puzzleTapHint;
    }
  }

  /// Icon für UI
  String get iconName {
    switch (this) {
      case PuzzleType.jigsaw:
        return 'extension';
      case PuzzleType.sliding:
        return 'grid_on';
    }
  }
}

/// Quelle des Puzzle-Bildes
@HiveType(typeId: 20)
enum PuzzleImageSource {
  @HiveField(0)
  gallery, // Bild aus Galerie

  @HiveField(1)
  camera, // Bild von Kamera

  @HiveField(2)
  online; // Bild von Online-API (z.B. Unsplash)

  /// Human-readable Label für UI
  String get label {
    switch (this) {
      case PuzzleImageSource.gallery:
        return AppTexts.current.puzzleImageSourceGallery;
      case PuzzleImageSource.camera:
        return AppTexts.current.puzzleImageSourceCamera;
      case PuzzleImageSource.online:
        return AppTexts.current.puzzleImageSourceOnline;
    }
  }

  /// Icon für UI
  String get iconName {
    switch (this) {
      case PuzzleImageSource.gallery:
        return 'photo_library';
      case PuzzleImageSource.camera:
        return 'camera_alt';
      case PuzzleImageSource.online:
        return 'cloud_download';
    }
  }
}

/// Schwierigkeitsgrad des Puzzles
@HiveType(typeId: 21)
enum PuzzleDifficulty {
  @HiveField(0)
  easy, // 3x3 Grid (9 Teile)

  @HiveField(1)
  medium, // 4x4 Grid (16 Teile)

  @HiveField(2)
  hard; // 5x5 Grid (25 Teile)

  /// Human-readable Label für UI
  String get label {
    switch (this) {
      case PuzzleDifficulty.easy:
        return AppTexts.current.puzzleDifficultyEasy;
      case PuzzleDifficulty.medium:
        return AppTexts.current.puzzleDifficultyMedium;
      case PuzzleDifficulty.hard:
        return AppTexts.current.puzzleDifficultyHard;
    }
  }

  /// Grid-Größe (z.B. 3 für 3x3)
  int get gridSize {
    switch (this) {
      case PuzzleDifficulty.easy:
        return 3;
      case PuzzleDifficulty.medium:
        return 4;
      case PuzzleDifficulty.hard:
        return 5;
    }
  }

  /// Anzahl der Puzzle-Teile
  int get pieceCount => gridSize * gridSize;

  /// Beschreibung für UI
  String get description {
    return '$gridSize×$gridSize Grid ($pieceCount Teile)';
  }
}

/// Puzzle-Konfiguration
/// Speichert die Einstellungen für ein Puzzle zur Entspannung
@HiveType(typeId: 22)
class PuzzleConfig {
  PuzzleConfig({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.imageSource,
    required this.createdAt,
    required this.createdByProfileId,
    this.imagePath,
    this.imageUrl,
    this.completedAt,
    this.moveCount = 0,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final PuzzleType type;

  @HiveField(2)
  final PuzzleDifficulty difficulty;

  @HiveField(3)
  final PuzzleImageSource imageSource;

  @HiveField(4)
  final String? imagePath; // Lokaler Pfad (Galerie/Kamera)

  @HiveField(5)
  final String? imageUrl; // Online-URL

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final String createdByProfileId;

  @HiveField(8)
  final DateTime? completedAt; // Wann wurde es gelöst

  @HiveField(9)
  final int moveCount; // Anzahl der Züge (nur für Statistik, keine Wertung!)

  /// Kopie mit geänderten Werten
  PuzzleConfig copyWith({
    String? id,
    PuzzleType? type,
    PuzzleDifficulty? difficulty,
    PuzzleImageSource? imageSource,
    String? imagePath,
    String? imageUrl,
    DateTime? createdAt,
    String? createdByProfileId,
    DateTime? completedAt,
    int? moveCount,
  }) {
    return PuzzleConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      imageSource: imageSource ?? this.imageSource,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      createdByProfileId: createdByProfileId ?? this.createdByProfileId,
      completedAt: completedAt ?? this.completedAt,
      moveCount: moveCount ?? this.moveCount,
    );
  }

  /// Ist das Puzzle abgeschlossen?
  bool get isCompleted => completedAt != null;

  /// Zu Map konvertieren (für Logging/Debugging)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'imageSource': imageSource.name,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'createdByProfileId': createdByProfileId,
      'completedAt': completedAt?.toIso8601String(),
      'moveCount': moveCount,
    };
  }

  @override
  String toString() {
    return 'PuzzleConfig(id: $id, type: ${type.label}, difficulty: ${difficulty.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PuzzleConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
