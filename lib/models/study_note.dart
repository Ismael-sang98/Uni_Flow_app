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

  // defaultValue is required here so notes saved before this field existed
  // (which have no byte 10/11 at all) deserialize as false instead of
  // crashing on a null-as-bool cast.
  @HiveField(10, defaultValue: false)
  final bool isPinned;

  @HiveField(11, defaultValue: false)
  final bool isDeleted;

  @HiveField(12)
  final DateTime? deletedAt;

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
    this.isPinned = false,
    this.isDeleted = false,
    this.deletedAt,
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
    bool? isPinned,
    bool? isDeleted,
    DateTime? deletedAt,
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
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
