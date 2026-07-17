import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';
import '../models/course.dart';
import 'notification_service.dart';

/// Calcule la prochaine occurrence du jour/heure d'un [Course] et programme
/// (ou reprogramme — un même `id` remplace la programmation précédente pour
/// cet id) son rappel hebdomadaire [Course.reminderMinutesBefore] minutes
/// avant le début, via [NotificationService]. Même algorithme de date que
/// `AddCoursePage._adjustToNextSelectedDay` (création manuelle d'un cours).
///
/// Contrairement au flux de création manuelle, n'affiche aucune notification
/// instantanée de confirmation : appelé en boucle après une synchronisation
/// qui peut créer/mettre à jour des dizaines de cours d'un coup, une
/// confirmation par cours spammerait l'utilisateur.
///
/// Ne programme rien si le rappel calculé tombe déjà dans le passé
/// (`NotificationService.scheduleWeeklyNotification` l'ignore silencieusement
/// dans ce cas). N'importe quel échec (permission refusée, etc.) est capturé
/// et journalisé sans se propager : l'appelant boucle sur plusieurs cours et
/// un échec isolé ne doit jamais interrompre les autres.
Future<void> scheduleCourseReminder(
  Course course,
  AppLocalizations l10n,
) async {
  try {
    await NotificationService().requestPermissions();

    final now = DateTime.now();
    final nextOccurrence = _nextOccurrence(
      now,
      course.dayOfWeeks,
      course.startTime,
    );
    final notificationTime = nextOccurrence.subtract(
      Duration(minutes: course.reminderMinutesBefore),
    );

    final notificationId = NotificationService.notificationIdFromCourseId(
      course.id,
    );
    final locationSuffix = (course.location?.isNotEmpty ?? false)
        ? l10n.courseReminderLocationSuffix(course.location!)
        : '';

    await NotificationService().scheduleWeeklyNotification(
      id: notificationId,
      title: l10n.courseReminderTitle,
      body: l10n.courseReminderBody(
        course.title,
        locationSuffix,
        course.reminderMinutesBefore,
      ),
      scheduledDate: notificationTime,
    );
  } catch (e) {
    debugPrint('scheduleCourseReminder error for course ${course.id}: $e');
  }
}

/// Prochaine date/heure (à partir de [now]) où [dayOfWeeks] (1=lundi..7=dimanche)
/// et l'heure de [timeOfDay] coïncident.
DateTime _nextOccurrence(DateTime now, int dayOfWeeks, DateTime timeOfDay) {
  final todayAtTime = DateTime(
    now.year,
    now.month,
    now.day,
    timeOfDay.hour,
    timeOfDay.minute,
  );
  int daysUntil = (dayOfWeeks - now.weekday + 7) % 7;
  if (daysUntil == 0 && todayAtTime.isBefore(now)) {
    daysUntil = 7;
  }
  return todayAtTime.add(Duration(days: daysUntil));
}
