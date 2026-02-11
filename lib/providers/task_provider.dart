import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_task.dart';

class TaskProvider with ChangeNotifier {
  // On récupère la boîte Hive dédiée aux tâches
  final Box<TodoTask> _taskBox = Hive.box<TodoTask>('tasks');
  List<TodoTask> _tasks = [];

  List<TodoTask> get tasks => _tasks;

  // Charger les tâches depuis la base de données
  void loadTasks() {
    _tasks = _taskBox.values.toList();

    // On trie : les tâches non faites en premier, puis par date
    _tasks.sort((a, b) {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    notifyListeners();
  }

  // Ajouter une tâche
  Future<void> addTask(TodoTask task) async {
    await _taskBox.put(task.id, task);
    loadTasks();
  }

  // Changer le statut (Fait / À faire)
  Future<void> toggleTaskStatus(TodoTask task) async {
    final updatedTask = TodoTask(
      id: task.id,
      title: task.title,
      dueDate: task.dueDate,
      isDone: !task.isDone,
      relatedCourseTitle: task.relatedCourseTitle,
    );
    await _taskBox.put(task.id, updatedTask);
    loadTasks();
  }

  // Supprimer une tâche
  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
    loadTasks();
  }
}
