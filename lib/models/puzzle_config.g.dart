// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PuzzleConfigAdapter extends TypeAdapter<PuzzleConfig> {
  @override
  final typeId = 22;

  @override
  PuzzleConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PuzzleConfig(
      id: fields[0] as String,
      type: fields[1] as PuzzleType,
      difficulty: fields[2] as PuzzleDifficulty,
      imageSource: fields[3] as PuzzleImageSource,
      createdAt: fields[6] as DateTime,
      createdByProfileId: fields[7] as String,
      imagePath: fields[4] as String?,
      imageUrl: fields[5] as String?,
      completedAt: fields[8] as DateTime?,
      moveCount: fields[9] == null ? 0 : (fields[9] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, PuzzleConfig obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.difficulty)
      ..writeByte(3)
      ..write(obj.imageSource)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.createdByProfileId)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.moveCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PuzzleConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PuzzleTypeAdapter extends TypeAdapter<PuzzleType> {
  @override
  final typeId = 19;

  @override
  PuzzleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PuzzleType.jigsaw;
      case 1:
        return PuzzleType.sliding;
      default:
        return PuzzleType.jigsaw;
    }
  }

  @override
  void write(BinaryWriter writer, PuzzleType obj) {
    switch (obj) {
      case PuzzleType.jigsaw:
        writer.writeByte(0);
      case PuzzleType.sliding:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PuzzleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PuzzleImageSourceAdapter extends TypeAdapter<PuzzleImageSource> {
  @override
  final typeId = 20;

  @override
  PuzzleImageSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PuzzleImageSource.gallery;
      case 1:
        return PuzzleImageSource.camera;
      case 2:
        return PuzzleImageSource.online;
      default:
        return PuzzleImageSource.gallery;
    }
  }

  @override
  void write(BinaryWriter writer, PuzzleImageSource obj) {
    switch (obj) {
      case PuzzleImageSource.gallery:
        writer.writeByte(0);
      case PuzzleImageSource.camera:
        writer.writeByte(1);
      case PuzzleImageSource.online:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PuzzleImageSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PuzzleDifficultyAdapter extends TypeAdapter<PuzzleDifficulty> {
  @override
  final typeId = 21;

  @override
  PuzzleDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PuzzleDifficulty.easy;
      case 1:
        return PuzzleDifficulty.medium;
      case 2:
        return PuzzleDifficulty.hard;
      default:
        return PuzzleDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, PuzzleDifficulty obj) {
    switch (obj) {
      case PuzzleDifficulty.easy:
        writer.writeByte(0);
      case PuzzleDifficulty.medium:
        writer.writeByte(1);
      case PuzzleDifficulty.hard:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PuzzleDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
