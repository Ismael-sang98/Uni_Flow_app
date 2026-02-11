import 'package:hive/hive.dart';

part 'todo_task.g.dart';

@HiveType(typeId: 2) // ID 0 pour Course, 1 pour Profile, 2 pour Task
class TodoTask {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime dueDate;

  @HiveField(3)
  final bool isDone;

  @HiveField(4)
  final String? relatedCourseTitle; // Pour lier un devoir à une matière

  TodoTask({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isDone = false,
    this.relatedCourseTitle,
  });
}