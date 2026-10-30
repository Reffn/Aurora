// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommentAdapter extends TypeAdapter<Comment> {
  @override
  final typeId = 30;

  @override
  Comment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Comment(
      id: fields[0] as String,
      type: fields[1] as CommentableType,
      parentId: fields[2] as String,
      profileId: fields[3] as String,
      content: fields[4] as String,
      timestamp: fields[5] as DateTime,
      editedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Comment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.parentId)
      ..writeByte(3)
      ..write(obj.profileId)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.editedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommentableTypeAdapter extends TypeAdapter<CommentableType> {
  @override
  final typeId = 31;

  @override
  CommentableType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CommentableType.diary;
      case 1:
        return CommentableType.contact;
      case 2:
        return CommentableType.calendar;
      case 3:
        return CommentableType.medication;
      case 4:
        return CommentableType.finder;
      default:
        return CommentableType.diary;
    }
  }

  @override
  void write(BinaryWriter writer, CommentableType obj) {
    switch (obj) {
      case CommentableType.diary:
        writer.writeByte(0);
      case CommentableType.contact:
        writer.writeByte(1);
      case CommentableType.calendar:
        writer.writeByte(2);
      case CommentableType.medication:
        writer.writeByte(3);
      case CommentableType.finder:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentableTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
