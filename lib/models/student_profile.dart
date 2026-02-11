import 'package:hive/hive.dart';

part 'student_profile.g.dart';

@HiveType(typeId: 1)
class StudentProfile {
  @HiveField(0)
  String name;

  @HiveField(1)
  String className;

  @HiveField(2)
  String schoolName;

  @HiveField(3)
  String faculty;

  @HiveField(4) // <--- NOUVEAU CHAMP : La liste des matières
  final List<String> subjects;

  @HiveField(5)
  final String? profilePicturePath;

  StudentProfile({
    required this.name,
    required this.className,
    required this.schoolName,
    this.profilePicturePath,
    required this.faculty,
    this.subjects = const [],
  });
}
