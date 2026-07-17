import 'package:hive/hive.dart';

part 'deadline.g.dart';

/// Type d'échéance ponctuelle — distinct des [Course] récurrents
/// hebdomadaires : un [Deadline] a une seule date/heure précise (examen,
/// devoir à rendre, ou autre échéance).
@HiveType(typeId: 4)
enum DeadlineType {
  @HiveField(0)
  exam,
  @HiveField(1)
  homework,
  @HiveField(2)
  other,
}

@HiveType(typeId: 2)
class Deadline {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DeadlineType type;

  @HiveField(3)
  final DateTime dueAt;

  @HiveField(4)
  final String? subject;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final bool isCompleted;

  /// Délai de rappel avant [dueAt], en minutes (ex: 60 = 1h avant, 1440 = 1
  /// jour avant). Null = pas de rappel programmé.
  @HiveField(7)
  final int? reminderMinutesBefore;

  Deadline({
    required this.id,
    required this.title,
    required this.type,
    required this.dueAt,
    this.subject,
    this.notes,
    this.isCompleted = false,
    this.reminderMinutesBefore,
  });

  Deadline copyWith({
    String? id,
    String? title,
    DeadlineType? type,
    DateTime? dueAt,
    String? subject,
    String? notes,
    bool? isCompleted,
    int? reminderMinutesBefore,
  }) {
    return Deadline(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dueAt: dueAt ?? this.dueAt,
      subject: subject ?? this.subject,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }
}
