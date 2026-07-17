import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/deadline.dart';
import '../services/notification_service.dart';

class DeadlinesProvider with ChangeNotifier {
  final Box<Deadline> _box = Hive.box<Deadline>('deadlines');

  List<Deadline> _deadlines = [];
  List<Deadline> get deadlines => _deadlines;

  /// Non terminées, triées par échéance la plus proche en premier.
  List<Deadline> get upcoming =>
      _deadlines.where((d) => !d.isCompleted && !_isLate(d)).toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  /// Non terminées et déjà passées.
  List<Deadline> get late =>
      _deadlines.where((d) => !d.isCompleted && _isLate(d)).toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  /// Terminées, les plus récemment échues en premier.
  List<Deadline> get completed =>
      _deadlines.where((d) => d.isCompleted).toList()
        ..sort((a, b) => b.dueAt.compareTo(a.dueAt));

  bool _isLate(Deadline d) => d.dueAt.isBefore(DateTime.now());

  void loadDeadlines() {
    _deadlines = _box.values.toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    notifyListeners();
  }

  Future<void> addDeadline(Deadline deadline) async {
    await _box.put(deadline.id, deadline);
    loadDeadlines();
  }

  Future<void> updateDeadline(Deadline deadline) async {
    await _box.put(deadline.id, deadline);
    loadDeadlines();
  }

  Future<void> toggleCompleted(String id) async {
    final deadline = _box.get(id);
    if (deadline == null) return;
    await _box.put(id, deadline.copyWith(isCompleted: !deadline.isCompleted));
    loadDeadlines();
  }

  Future<void> deleteDeadline(String id) async {
    await NotificationService().cancelNotification(
      NotificationService.notificationIdFromDeadlineId(id),
    );
    await _box.delete(id);
    loadDeadlines();
  }
}
