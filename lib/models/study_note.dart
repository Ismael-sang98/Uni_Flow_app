import 'package:hive/hive.dart';

part 'study_note.g.dart';

@HiveType(typeId: 3)
class StudyNote {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String? subject;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime? updatedAt;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final List<String> imagePaths;

  StudyNote({
    required this.id,
    required this.title,
    required this.content,
    this.subject,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    List<String>? imagePaths,
  }) : imagePaths = imagePaths ?? const [];
}
