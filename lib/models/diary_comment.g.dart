// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_comment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryCommentAdapter extends TypeAdapter<DiaryComment> {
  @override
  final typeId = 12;

  @override
  DiaryComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryComment(
      id: fields[0] as String,
      entryId: fields[1] as String,
      profileId: fields[2] as String,
      content: fields[3] as String,
      timestamp: fields[4] as DateTime,
      editedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DiaryComment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entryId)
      ..writeByte(2)
      ..write(obj.profileId)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.editedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
