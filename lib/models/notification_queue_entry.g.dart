// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_queue_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationQueueEntryAdapter
    extends TypeAdapter<NotificationQueueEntry> {
  @override
  final typeId = 26;

  @override
  NotificationQueueEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationQueueEntry(
      id: fields[0] as String,
      scheduledTime: fields[1] as DateTime,
      type: fields[2] as String,
      referenceId: fields[3] as String,
      status: fields[4] as String,
      title: fields[5] as String,
      body: fields[6] as String,
      platformNotificationId: (fields[7] as num).toInt(),
      payload: (fields[8] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[9] as DateTime?,
      sentAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationQueueEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scheduledTime)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.referenceId)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.body)
      ..writeByte(7)
      ..write(obj.platformNotificationId)
      ..writeByte(8)
      ..write(obj.payload)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.sentAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationQueueEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
