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

  @HiveField(8)
  final List<String> attachmentPaths;

  @HiveField(9)
  final Map<String, String> imageCaptions;

  StudyNote({
    required this.id,
    required this.title,
    required this.content,
    this.subject,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    List<String>? imagePaths,
    List<String>? attachmentPaths,
    Map<String, String>? imageCaptions,
  }) : imagePaths = imagePaths ?? const [],
       attachmentPaths = attachmentPaths ?? const [],
       imageCaptions = imageCaptions ?? const {};

  StudyNote copyWith({
    String? id,
    String? title,
    String? content,
    String? subject,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    List<String>? imagePaths,
    List<String>? attachmentPaths,
    Map<String, String>? imageCaptions,
  }) {
    return StudyNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      imagePaths: imagePaths ?? this.imagePaths,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      imageCaptions: imageCaptions ?? this.imageCaptions,
    );
  }
}
