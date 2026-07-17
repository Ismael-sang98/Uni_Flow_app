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

  /// Département (ex: "Yazılım Mühendisliği"), distinct de [faculty] (ex:
  /// "Müh-Mim. Fak."). Renseigné uniquement via la synchro OBS (champ
  /// `departement` de `GET /profil`) — jamais saisi manuellement, donc null
  /// pour un profil créé sans compte OBS.
  @HiveField(6)
  final String? department;

  StudentProfile({
    required this.name,
    required this.className,
    required this.schoolName,
    this.profilePicturePath,
    required this.faculty,
    this.subjects = const [],
    this.department,
  });
}
