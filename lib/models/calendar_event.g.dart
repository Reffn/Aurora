// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarEventAdapter extends TypeAdapter<CalendarEvent> {
  @override
  final typeId = 3;

  @override
  CalendarEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarEvent(
      id: fields[0] as String,
      title: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime,
      profileIds: (fields[4] as List).cast<String>(),
      description: fields[5] as String?,
      category: fields[6] as String?,
      notes: fields[7] as String?,
      imagePaths: (fields[8] as List?)?.cast<String>(),
      notificationEnabled: fields[9] == null ? false : fields[9] as bool,
      reminderMinutesBefore: (fields[10] as num?)?.toInt(),
      latitude: (fields[11] as num?)?.toDouble(),
      longitude: (fields[12] as num?)?.toDouble(),
      locationName: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CalendarEvent obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.profileIds)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.imagePaths)
      ..writeByte(9)
      ..write(obj.notificationEnabled)
      ..writeByte(10)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(11)
      ..write(obj.latitude)
      ..writeByte(12)
      ..write(obj.longitude)
      ..writeByte(13)
      ..write(obj.locationName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
