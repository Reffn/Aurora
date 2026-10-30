// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final typeId = 6;

  @override
  Medication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medication(
      id: fields[0] as String,
      name: fields[1] as String,
      dosage: fields[2] as String,
      timesOfDay: (fields[3] as List).cast<String>(),
      profileIds: (fields[4] as List).cast<String>(),
      createdAt: fields[9] as DateTime,
      notes: fields[5] as String?,
      type: fields[12] == null
          ? MedicationType.daily
          : fields[12] as MedicationType,
      isActive: fields[6] == null ? true : fields[6] as bool,
      startDate: fields[7] as DateTime?,
      endDate: fields[8] as DateTime?,
      imagePath: fields[10] as String?,
      description: fields[11] as String?,
      maxDailyDoses: (fields[13] as num?)?.toInt(),
      minIntervalHours: (fields[14] as num?)?.toInt(),
      remindersEnabled: fields[15] == null ? true : fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Medication obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.timesOfDay)
      ..writeByte(4)
      ..write(obj.profileIds)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.imagePath)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.type)
      ..writeByte(13)
      ..write(obj.maxDailyDoses)
      ..writeByte(14)
      ..write(obj.minIntervalHours)
      ..writeByte(15)
      ..write(obj.remindersEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicationLogAdapter extends TypeAdapter<MedicationLog> {
  @override
  final typeId = 7;

  @override
  MedicationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationLog(
      id: fields[0] as String,
      medicationId: fields[1] as String,
      takenAt: fields[2] as DateTime,
      profileId: fields[3] as String,
      status: fields[4] as MedicationStatus,
      confirmedAt: fields[5] as DateTime?,
      note: fields[6] as String?,
      snoozedUntil: fields[7] as DateTime?,
      refusalNote: fields[8] as String?,
      feedback: fields[9] as String?,
      scheduledTime: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationLog obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicationId)
      ..writeByte(2)
      ..write(obj.takenAt)
      ..writeByte(3)
      ..write(obj.profileId)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.confirmedAt)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.snoozedUntil)
      ..writeByte(8)
      ..write(obj.refusalNote)
      ..writeByte(9)
      ..write(obj.feedback)
      ..writeByte(10)
      ..write(obj.scheduledTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicationTypeAdapter extends TypeAdapter<MedicationType> {
  @override
  final typeId = 9;

  @override
  MedicationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MedicationType.daily;
      case 1:
        return MedicationType.asNeeded;
      default:
        return MedicationType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, MedicationType obj) {
    switch (obj) {
      case MedicationType.daily:
        writer.writeByte(0);
      case MedicationType.asNeeded:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicationStatusAdapter extends TypeAdapter<MedicationStatus> {
  @override
  final typeId = 8;

  @override
  MedicationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MedicationStatus.taken;
      case 1:
        return MedicationStatus.refused;
      case 2:
        return MedicationStatus.snoozed;
      case 3:
        return MedicationStatus.skipped;
      default:
        return MedicationStatus.taken;
    }
  }

  @override
  void write(BinaryWriter writer, MedicationStatus obj) {
    switch (obj) {
      case MedicationStatus.taken:
        writer.writeByte(0);
      case MedicationStatus.refused:
        writer.writeByte(1);
      case MedicationStatus.snoozed:
        writer.writeByte(2);
      case MedicationStatus.skipped:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
