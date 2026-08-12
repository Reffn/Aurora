// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transmission_log_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransmissionLogEntryAdapter extends TypeAdapter<TransmissionLogEntry> {
  @override
  final typeId = 34;

  @override
  TransmissionLogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransmissionLogEntry(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      channel: fields[2] as TransmissionChannel,
      payloadText: fields[3] as String,
      status: fields[4] as TransmissionStatus,
      errorMessage: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransmissionLogEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.channel)
      ..writeByte(3)
      ..write(obj.payloadText)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.errorMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransmissionLogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransmissionStatusAdapter extends TypeAdapter<TransmissionStatus> {
  @override
  final typeId = 33;

  @override
  TransmissionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransmissionStatus.pending;
      case 1:
        return TransmissionStatus.sent;
      case 2:
        return TransmissionStatus.failed;
      default:
        return TransmissionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TransmissionStatus obj) {
    switch (obj) {
      case TransmissionStatus.pending:
        writer.writeByte(0);
      case TransmissionStatus.sent:
        writer.writeByte(1);
      case TransmissionStatus.failed:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransmissionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransmissionChannelAdapter extends TypeAdapter<TransmissionChannel> {
  @override
  final typeId = 32;

  @override
  TransmissionChannel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransmissionChannel.feedback;
      case 1:
        return TransmissionChannel.telemetry;
      default:
        return TransmissionChannel.feedback;
    }
  }

  @override
  void write(BinaryWriter writer, TransmissionChannel obj) {
    switch (obj) {
      case TransmissionChannel.feedback:
        writer.writeByte(0);
      case TransmissionChannel.telemetry:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransmissionChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
