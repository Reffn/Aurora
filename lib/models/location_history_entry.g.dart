// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationHistoryEntryAdapter extends TypeAdapter<LocationHistoryEntry> {
  @override
  final typeId = 23;

  @override
  LocationHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationHistoryEntry(
      id: fields[0] as String,
      profileId: fields[1] as String,
      latitude: (fields[2] as num).toDouble(),
      longitude: (fields[3] as num).toDouble(),
      timestamp: fields[4] as DateTime,
      accuracy: (fields[5] as num?)?.toDouble(),
      address: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationHistoryEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.accuracy)
      ..writeByte(6)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
