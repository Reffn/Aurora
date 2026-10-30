// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_switch_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileSwitchEventAdapter extends TypeAdapter<ProfileSwitchEvent> {
  @override
  final typeId = 24;

  @override
  ProfileSwitchEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileSwitchEvent(
      id: fields[0] as String,
      toProfileId: fields[2] as String,
      timestamp: fields[3] as DateTime,
      fromProfileId: fields[1] as String?,
      latitude: (fields[4] as num?)?.toDouble(),
      longitude: (fields[5] as num?)?.toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, ProfileSwitchEvent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromProfileId)
      ..writeByte(2)
      ..write(obj.toProfileId)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileSwitchEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
