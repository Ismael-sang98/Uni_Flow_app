import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mon_temps/models/student_profile.dart';
import 'package:mon_temps/screens/add_course_page.dart';
import 'package:mon_temps/screens/profile_page.dart';
import 'package:mon_temps/widgets/notes_library_view.dart';
import 'package:mon_temps/widgets/weekly_schedule_view.dart';
import '../l10n/app_localizations.dart';
import '../widgets/create_notebook_dialog.dart';
import '../widgets/deadlines_view.dart';
import '../widgets/update_dialog.dart';
import 'add_deadline_page.dart';

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
    _checkForUpdates(); // Vérifier les mises à jour
  }

  /// Vérifie automatiquement les mises à jour au démarrage
  Future<void> _checkForUpdates() async {
    // Attendre 2 secondes pour laisser l'app se charger
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await UpdateDialog.checkAndShow(context);
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

  Widget _buildAppBarTitle(BuildContext context, AppLocalizations l10n) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, _) {
        final profile = box.get('profile') as StudentProfile?;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avatar + Infos
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
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
                          profile?.department ?? "",
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
              icon: const Icon(Icons.settings, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          child: _buildAppBarTitle(context, l10n),
        ),
      ),
      body: switch (_selectedIndex) {
        0 => const WeeklyScheduleView(),
        1 => const DeadlinesView(),
        _ => const NotesLibraryView(),
      },
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withValues(alpha: 0.05),
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
            indicatorColor: const Color(0xFF6C63FF).withValues(alpha: 0.1),
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
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event, color: Color(0xFF6C63FF)),
                label: l10n.deadlinesTabLabel,
              ),
              NavigationDestination(
                icon: Icon(Icons.note_alt),
                selectedIcon: Icon(Icons.note_alt, color: Color(0xFF6C63FF)),
                label: l10n.notesLibrary,
              ),
            ],
          ),
        ),
      ),
      // endFloat plutôt que centerDocked : avec 3 onglets, un FAB centré
      // recouvre directement l'icône de l'onglet du milieu (Échéances) —
      // en bas à droite, il ne chevauche plus aucun onglet.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          switch (_selectedIndex) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCoursePage()),
              );
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDeadlinePage()),
              );
            default:
              showCreateNotebookDialog(context);
          }
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
