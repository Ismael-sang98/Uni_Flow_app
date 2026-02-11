// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoTaskAdapter extends TypeAdapter<TodoTask> {
  @override
  final int typeId = 2;

  @override
  TodoTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoTask(
      id: fields[0] as String,
      title: fields[1] as String,
      dueDate: fields[2] as DateTime,
      isDone: fields[3] as bool,
      relatedCourseTitle: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TodoTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dueDate)
      ..writeByte(3)
      ..write(obj.isDone)
      ..writeByte(4)
      ..write(obj.relatedCourseTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
