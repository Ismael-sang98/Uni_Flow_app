import "package:hive/hive.dart";

part 'course.g.dart';

@HiveType(typeId: 0)
class Course {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? location;
  @HiveField(3)
  final int color;
  @HiveField(4)
  final int dayOfWeeks;

  @HiveField(5)
  final DateTime startTime;
  @HiveField(6)
  final DateTime endTime;



  Course({
    required this.id,
    required this.title,
     this.location,
    required this.color,
    required this.dayOfWeeks,
    required this.startTime,
    required this.endTime,
  });
}