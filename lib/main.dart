import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mon_temps/my_app.dart';
import 'package:mon_temps/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';

import 'models/course.dart';
import 'models/student_profile.dart';
import 'models/todo_task.dart';
import 'providers/course_provider.dart';
import 'providers/task_provider.dart';

// --- POINT D'ENTRÉE DE L'APPLICATION ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    //Initialisation de la base de données Hive et enregistrement des adaptateurs
    Hive.registerAdapter(CourseAdapter());
    Hive.registerAdapter(StudentProfileAdapter());
    Hive.registerAdapter(TodoTaskAdapter());

    await Hive.openBox('settings');
    await Hive.openBox<Course>('courses');
    await Hive.openBox<TodoTask>('tasks');

    await NotificationService().init();
    // Demande des permissions de notification au démarrage
    await NotificationService().requestPermissions();
  } catch (e) {
    debugPrint('Erreur initialisation: $e');
  }

  runApp(
    //  Providers pour la gestion d'état avec Provider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()..loadCourses()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
