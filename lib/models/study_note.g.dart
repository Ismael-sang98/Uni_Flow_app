// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyNoteAdapter extends TypeAdapter<StudyNote> {
  @override
  final int typeId = 3;

  @override
  StudyNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyNote(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      subject: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime?,
      tags: (fields[6] as List).cast<String>(),
      imagePaths: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StudyNote obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.subject)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.imagePaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
