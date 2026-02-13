import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
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

  // --- FONCTION POUR DEMANDER LA PERMISSION DE NOTIFICATION (ROBUSTE) ---
  @override
  void initState() {
    super.initState();
    _checkAndRequestNotificationPermission(); // Appel de notre fonction robuste
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    // On vérifie le statut actuel
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      // Si c'est refusé (ou pas encore demandé), on FORCE la demande
      status = await Permission.notification.request();
      //print("Résultat de la demande : $status",); // Pour voir ce qui se passe dans la console
    }

    if (status.isPermanentlyDenied) {
      // Si Android l'a bloqué définitivement, on propose d'ouvrir les paramètres
      //print("Permission bloquée définitivement par Android.");
      openAppSettings();
    }
  }

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
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  // ignore: deprecated_member_use
                  ).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.playlist_add_check_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.addTask,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.taskTitle,
                    prefixIcon: const Icon(Icons.title_rounded),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedCourseTitle,
                  decoration: InputDecoration(
                    //les textes sont désormais localisés grâce à AppLocalizations
                    labelText: l10n.mt,
                    prefixIcon: const Icon(Icons.school_rounded),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
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
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
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
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.dueDate,
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      DateFormat('dd/MM').format(selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.rejet,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  // ignore: deprecated_member_use
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ElevatedButton(
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Text(l10n.ajt),
              ),
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
          appBar: AppBar(
            backgroundColor:
                Theme.of(context).appBarTheme.backgroundColor ??
                const Color(0xFF6C63FF),
            elevation: 2,
            toolbarHeight: 80.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar + Infos
                  Expanded(
                    child: Row(
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
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white24,
                              backgroundImage:
                                  (profile?.profilePicturePath != null &&
                                      profile!.profilePicturePath!.isNotEmpty)
                                  ? FileImage(File(profile.profilePicturePath!))
                                  : null,
                              child:
                                  (profile?.profilePicturePath == null ||
                                      profile!.profilePicturePath!.isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profile != null ? profile.name : l10n.bvn,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile?.faculty ?? "",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bouton settings
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: _selectedIndex == 0
              ? const WeeklyScheduleView()
              : const TasksView(),
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
