// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentProfileAdapter extends TypeAdapter<StudentProfile> {
  @override
  final int typeId = 1;

  @override
  StudentProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudentProfile(
      name: fields[0] as String,
      className: fields[1] as String,
      schoolName: fields[2] as String,
      profilePicturePath: fields[5] as String?,
      faculty: fields[3] as String,
      subjects: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StudentProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.className)
      ..writeByte(2)
      ..write(obj.schoolName)
      ..writeByte(3)
      ..write(obj.faculty)
      ..writeByte(4)
      ..write(obj.subjects)
      ..writeByte(5)
      ..write(obj.profilePicturePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
