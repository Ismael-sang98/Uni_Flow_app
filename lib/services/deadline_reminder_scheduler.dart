import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/deadline.dart';
import 'notification_service.dart';

/// Programme (ou reprogramme — un même id remplace la programmation
/// précédente) un rappel ponctuel pour une [Deadline], [deadline.reminderMinutesBefore]
/// minutes avant [Deadline.dueAt]. Contrairement aux rappels de cours, ce
/// n'est jamais récurrent : une seule notification à un instant précis.
///
/// N'appelle pas [NotificationService.scheduleNotification] si
/// [Deadline.reminderMinutesBefore] est null (pas de rappel voulu) ou si le
/// moment calculé est déjà passé (la méthode l'ignore de toute façon, mais
/// on évite l'appel réseau/permission inutile).
Future<void> scheduleDeadlineReminder(
  Deadline deadline,
  AppLocalizations l10n,
) async {
  final minutesBefore = deadline.reminderMinutesBefore;
  if (minutesBefore == null) return;

  try {
    await NotificationService().requestPermissions();

    final reminderTime = deadline.dueAt.subtract(
      Duration(minutes: minutesBefore),
    );
    if (reminderTime.isBefore(DateTime.now())) return;

    final notificationId = NotificationService.notificationIdFromDeadlineId(
      deadline.id,
    );
    final dueLabel = DateFormat('dd/MM/yyyy HH:mm').format(deadline.dueAt);

    await NotificationService().scheduleNotification(
      id: notificationId,
      title: l10n.deadlineNotificationTitle(deadline.title),
      body: l10n.deadlineNotificationBody(dueLabel),
      scheduledDate: reminderTime,
    );
  } catch (e) {
    debugPrint('scheduleDeadlineReminder error for deadline ${deadline.id}: $e');
  }
}
