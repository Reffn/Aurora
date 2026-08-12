// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finder_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinderItemAdapter extends TypeAdapter<FinderItem> {
  @override
  final typeId = 15;

  @override
  FinderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinderItem(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[3] as FinderItemType,
      tags: (fields[9] as List).cast<String>(),
      createdAt: fields[10] as DateTime,
      createdByProfileId: fields[11] as String,
      description: fields[2] as String?,
      location: fields[4] as String?,
      address: fields[5] as String?,
      latitude: (fields[6] as num?)?.toDouble(),
      longitude: (fields[7] as num?)?.toDouble(),
      imagePath: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FinderItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.createdByProfileId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FinderItemTypeAdapter extends TypeAdapter<FinderItemType> {
  @override
  final typeId = 16;

  @override
  FinderItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FinderItemType.location;
      case 1:
        return FinderItemType.item;
      default:
        return FinderItemType.location;
    }
  }

  @override
  void write(BinaryWriter writer, FinderItemType obj) {
    switch (obj) {
      case FinderItemType.location:
        writer.writeByte(0);
      case FinderItemType.item:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinderItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
