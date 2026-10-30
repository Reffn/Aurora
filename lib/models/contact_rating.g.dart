// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_rating.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactRatingAdapter extends TypeAdapter<ContactRating> {
  @override
  final typeId = 17;

  @override
  ContactRating read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactRating(
      id: fields[0] as String,
      contactId: fields[1] as String,
      profileId: fields[2] as String,
      rating: (fields[3] as num).toInt(),
      createdAt: fields[4] as DateTime,
      editedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ContactRating obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactId)
      ..writeByte(2)
      ..write(obj.profileId)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.editedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactRatingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
