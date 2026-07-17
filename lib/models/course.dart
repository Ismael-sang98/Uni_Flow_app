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

  /// Code externe optionnel (identifiant de cours renvoyé par un backend de
  /// synchronisation), distinct du [title] affiché. Null pour les cours créés
  /// manuellement dans l'app.
  @HiveField(7)
  final String? externalCode;

  /// Délai du rappel avant le début du cours, en minutes. defaultValue: 10
  /// préserve le comportement des cours créés avant l'ajout de ce champ
  /// (le rappel était alors fixé en dur à 10 minutes).
  @HiveField(8, defaultValue: 10)
  final int reminderMinutesBefore;

  Course({
    required this.id,
    required this.title,
    this.location,
    required this.color,
    required this.dayOfWeeks,
    required this.startTime,
    required this.endTime,
    this.externalCode,
    this.reminderMinutesBefore = 10,
  });
}
