import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mon_temps/models/student_profile.dart';
import 'package:mon_temps/models/todo_task.dart';
import 'package:mon_temps/providers/task_provider.dart';
import 'package:mon_temps/screens/add_course_page.dart';
import 'package:mon_temps/screens/profile_page.dart';
import 'package:mon_temps/widgets/tasks_view.dart';
import 'package:mon_temps/widgets/weekly_schedule_view.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';

// --- PAGE D'ACCUEIL PRINCIPALE ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index de l'onglet sélectionné dans la barre de navigation
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Boîte de dialogue pour ajouter une nouvelle tâche
  void _showAddTaskDialog(BuildContext context) {
    // Contrôleur pour le champ de texte du titre
    final titleController = TextEditingController();
    // Date sélectionnée par défaut (aujourd'hui)
    DateTime selectedDate = DateTime.now();
    // Matière sélectionnée par défaut
    String? selectedCourseTitle;

    // --- CORRECTION : Récupérer les matières depuis le Profil (Hive) ---
    final settingsBox = Hive.box('settings');
    final profile = settingsBox.get('profile') as StudentProfile?;
    // On utilise la liste 'subjects' du profil, ou une liste vide si rien n'est trouvé
    final List<String> availableSubjects = profile?.subjects ?? [];

    // Affichage de la boîte de dialogue

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text(
            l10n.addTask,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l10n.taskTitle,
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: selectedCourseTitle,
                  decoration: InputDecoration(
                    //les textes sont désormais localisés grâce à AppLocalizations
                    labelText: l10n.mt,
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  // Si aucune matière n'est définie, on affiche un message dans le dropdown ou on le laisse vide
                  items: availableSubjects.isEmpty
                      ? null
                      : availableSubjects
                            .map(
                              (title) => DropdownMenuItem(
                                value: title,
                                child: Text(title),
                              ),
                            )
                            .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedCourseTitle = val),
                  // Petit message d'aide si la liste est vide
                  hint: availableSubjects.isEmpty
                      //pas de leçons définies
                      ? Text(l10n.noSubjectsDefined)
                      : null,
                ),
                const SizedBox(height: 15),
                ListTile(
                  tileColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  leading: const Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFF6C63FF),
                  ),
                  title: Text(l10n.dueDate),
                  trailing: Text(
                    DateFormat('dd/MM').format(selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.rejet, style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newTask = TodoTask(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    dueDate: selectedDate,
                    relatedCourseTitle: selectedCourseTitle,
                  );
                  context.read<TaskProvider>().addTask(newTask);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.ajt),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, _) {
        final profile = box.get('profile') as StudentProfile?;

        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 100.0,
                floating: false,
                pinned: true,
                snap: false,
                backgroundColor: const Color(0xFF6C63FF),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ?Theme.of(context).appBarTheme.backgroundColor,
                          Color(0xFF8E84FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfilePage(),
                                ),
                              ),
                              child: Hero(
                                tag: 'profile_pic',
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.white24,
                                    backgroundImage:
                                        (profile?.profilePicturePath != null &&
                                            profile!
                                                .profilePicturePath!
                                                .isNotEmpty)
                                        ? FileImage(
                                            File(profile.profilePicturePath!),
                                          )
                                        : null,
                                    child:
                                        (profile?.profilePicturePath == null ||
                                            profile!
                                                .profilePicturePath!
                                                .isEmpty)
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 35,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    profile != null
                                        //  --- CORRECTION : Affichage du prénom si disponible ---
                                        ? profile.name
                                        //.split(' ')[0]
                                        //  sinon "Bienvenue"
                                        : l10n.bvn,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    profile?.faculty ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  // --- BOUTON DE PARAMÈTRES ---
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
              // --- CONTENU PRINCIPAL : PLANNING OU TÂCHES ---
              SliverFillRemaining(
                child: _selectedIndex == 0
                    // --- VUE DU PLANNING HEBDOMADAIRE ---
                    ? const WeeklyScheduleView()
                    // --- VUE DES TÂCHES ---
                    : const TasksView(),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: NavigationBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                height: 70,
                elevation: 0,
                selectedIndex: _selectedIndex,
                // ignore: deprecated_member_use
                indicatorColor: const Color(0xFF6C63FF).withOpacity(0.1),
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0);
                  }
                },
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(
                      Icons.calendar_month,
                      color: Color(0xFF6C63FF),
                    ),
                    label: l10n.planning,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.task_alt_outlined),
                    selectedIcon: Icon(
                      Icons.task_alt,
                      color: Color(0xFF6C63FF),
                    ),
                    label: l10n.tasks,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            elevation: 4,
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () {
              if (_selectedIndex == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCoursePage()),
                );
              } else {
                _showAddTaskDialog(context);
              }
            },
            child: const Icon(Icons.add, size: 32),
          ),
        );
      },
    );
  }
}
