// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryEntryAdapter extends TypeAdapter<DiaryEntry> {
  @override
  final typeId = 11;

  @override
  DiaryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryEntry(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      timestamp: fields[3] as DateTime,
      authorProfileId: fields[4] as String,
      imagePaths: (fields[5] as List?)?.cast<String>(),
      priority: fields[6] == null
          ? EntryPriority.medium
          : fields[6] as EntryPriority,
      editedAt: fields[7] as DateTime?,
      visibleTo: (fields[8] as List?)?.cast<String>(),
      mood: fields[9] as EntryMood?,
    );
  }

  @override
  void write(BinaryWriter writer, DiaryEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.authorProfileId)
      ..writeByte(5)
      ..write(obj.imagePaths)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.editedAt)
      ..writeByte(8)
      ..write(obj.visibleTo)
      ..writeByte(9)
      ..write(obj.mood);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EntryPriorityAdapter extends TypeAdapter<EntryPriority> {
  @override
  final typeId = 10;

  @override
  EntryPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EntryPriority.low;
      case 1:
        return EntryPriority.medium;
      case 2:
        return EntryPriority.high;
      case 3:
        return EntryPriority.critical;
      default:
        return EntryPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, EntryPriority obj) {
    switch (obj) {
      case EntryPriority.low:
        writer.writeByte(0);
      case EntryPriority.medium:
        writer.writeByte(1);
      case EntryPriority.high:
        writer.writeByte(2);
      case EntryPriority.critical:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EntryMoodAdapter extends TypeAdapter<EntryMood> {
  @override
  final typeId = 25;

  @override
  EntryMood read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EntryMood.veryHappy;
      case 1:
        return EntryMood.happy;
      case 2:
        return EntryMood.neutral;
      case 3:
        return EntryMood.sad;
      case 4:
        return EntryMood.verySad;
      case 5:
        return EntryMood.anxious;
      case 6:
        return EntryMood.angry;
      case 7:
        return EntryMood.excited;
      default:
        return EntryMood.veryHappy;
    }
  }

  @override
  void write(BinaryWriter writer, EntryMood obj) {
    switch (obj) {
      case EntryMood.veryHappy:
        writer.writeByte(0);
      case EntryMood.happy:
        writer.writeByte(1);
      case EntryMood.neutral:
        writer.writeByte(2);
      case EntryMood.sad:
        writer.writeByte(3);
      case EntryMood.verySad:
        writer.writeByte(4);
      case EntryMood.anxious:
        writer.writeByte(5);
      case EntryMood.angry:
        writer.writeByte(6);
      case EntryMood.excited:
        writer.writeByte(7);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryMoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
