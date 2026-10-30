// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final typeId = 13;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contact(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[7] as ContactCategory,
      createdByProfileId: fields[8] as String,
      createdAt: fields[9] as DateTime,
      defaultRating: (fields[10] as num).toInt(),
      relation: fields[2] as String?,
      phone: fields[3] as String?,
      email: fields[4] as String?,
      notes: fields[5] as String?,
      imagePath: fields[6] as String?,
      latitude: (fields[11] as num?)?.toDouble(),
      longitude: (fields[12] as num?)?.toDouble(),
      address: fields[13] as String?,
      isEmergencyContact: fields[14] == null ? false : fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.relation)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.createdByProfileId)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.defaultRating)
      ..writeByte(11)
      ..write(obj.latitude)
      ..writeByte(12)
      ..write(obj.longitude)
      ..writeByte(13)
      ..write(obj.address)
      ..writeByte(14)
      ..write(obj.isEmergencyContact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContactCategoryAdapter extends TypeAdapter<ContactCategory> {
  @override
  final typeId = 14;

  @override
  ContactCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ContactCategory.family;
      case 1:
        return ContactCategory.friends;
      case 2:
        return ContactCategory.therapists;
      case 3:
        return ContactCategory.doctors;
      case 4:
        return ContactCategory.emergency;
      case 5:
        return ContactCategory.other;
      default:
        return ContactCategory.family;
    }
  }

  @override
  void write(BinaryWriter writer, ContactCategory obj) {
    switch (obj) {
      case ContactCategory.family:
        writer.writeByte(0);
      case ContactCategory.friends:
        writer.writeByte(1);
      case ContactCategory.therapists:
        writer.writeByte(2);
      case ContactCategory.doctors:
        writer.writeByte(3);
      case ContactCategory.emergency:
        writer.writeByte(4);
      case ContactCategory.other:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
