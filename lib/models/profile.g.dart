// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final typeId = 0;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      id: fields[0] as String,
      nameRaw: fields[1] as String,
      preferredColorValue: (fields[3] as num).toInt(),
      createdAt: fields[6] as DateTime,
      avatarPath: fields[2] as String?,
      age: (fields[4] as num?)?.toInt(),
      description: fields[5] as String?,
      isAdmin: fields[7] == null ? false : fields[7] as bool,
      permissions: fields[8] == null ? [] : (fields[8] as List).cast<String>(),
      preferredLanguage: fields[9] as String?,
      isActive: fields[10] == null ? true : fields[10] as bool,
      passwordHash: fields[11] as String?,
      resetCode: fields[12] as String?,
      pendingPasswordHash: fields[13] as String?,
      securityQuestions: (fields[14] as List?)?.cast<String>(),
      securityAnswersHashed: (fields[15] as List?)?.cast<String>(),
      hasSeenPostLoginWelcome: fields[16] == null ? false : fields[16] as bool,
      colorPickerPositionX: (fields[17] as num?)?.toDouble(),
      colorPickerPositionY: (fields[18] as num?)?.toDouble(),
      resetStartedAt: fields[19] as DateTime?,
      resetEndsAt: fields[20] as DateTime?,
      resetDurationHours: (fields[21] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameRaw)
      ..writeByte(2)
      ..write(obj.avatarPath)
      ..writeByte(3)
      ..write(obj.preferredColorValue)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isAdmin)
      ..writeByte(8)
      ..write(obj.permissions)
      ..writeByte(9)
      ..write(obj.preferredLanguage)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.passwordHash)
      ..writeByte(12)
      ..write(obj.resetCode)
      ..writeByte(13)
      ..write(obj.pendingPasswordHash)
      ..writeByte(14)
      ..write(obj.securityQuestions)
      ..writeByte(15)
      ..write(obj.securityAnswersHashed)
      ..writeByte(16)
      ..write(obj.hasSeenPostLoginWelcome)
      ..writeByte(17)
      ..write(obj.colorPickerPositionX)
      ..writeByte(18)
      ..write(obj.colorPickerPositionY)
      ..writeByte(19)
      ..write(obj.resetStartedAt)
      ..writeByte(20)
      ..write(obj.resetEndsAt)
      ..writeByte(21)
      ..write(obj.resetDurationHours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
