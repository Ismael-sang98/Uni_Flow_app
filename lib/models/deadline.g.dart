// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deadline.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeadlineAdapter extends TypeAdapter<Deadline> {
  @override
  final int typeId = 2;

  @override
  Deadline read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Deadline(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as DeadlineType,
      dueAt: fields[3] as DateTime,
      subject: fields[4] as String?,
      notes: fields[5] as String?,
      isCompleted: fields[6] as bool,
      reminderMinutesBefore: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Deadline obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.dueAt)
      ..writeByte(4)
      ..write(obj.subject)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.reminderMinutesBefore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeadlineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeadlineTypeAdapter extends TypeAdapter<DeadlineType> {
  @override
  final int typeId = 4;

  @override
  DeadlineType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeadlineType.exam;
      case 1:
        return DeadlineType.homework;
      case 2:
        return DeadlineType.other;
      default:
        return DeadlineType.exam;
    }
  }

  @override
  void write(BinaryWriter writer, DeadlineType obj) {
    switch (obj) {
      case DeadlineType.exam:
        writer.writeByte(0);
        break;
      case DeadlineType.homework:
        writer.writeByte(1);
        break;
      case DeadlineType.other:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeadlineTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
