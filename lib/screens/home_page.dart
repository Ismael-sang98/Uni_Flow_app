import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mon_temps/screens/add_note_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mon_temps/models/student_profile.dart';
import 'package:mon_temps/models/study_note.dart';
import 'package:mon_temps/providers/notes_provider.dart';
import 'package:mon_temps/screens/add_course_page.dart';
import 'package:mon_temps/screens/profile_page.dart';
import 'package:mon_temps/widgets/notes_library_view.dart';
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

  // Boîte de dialogue pour ajouter une nouvelle note
  // ignore: unused_element
  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();
    String? selectedSubject;
    final List<String> imagePaths = [];

    final settingsBox = Hive.box('settings');
    final profile = settingsBox.get('profile') as StudentProfile?;
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
                  l10n.addNote,
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
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.noteTitle,
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
                  initialValue: selectedSubject,
                  decoration: InputDecoration(
                    labelText: l10n.noteSubject,
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
                      setDialogState(() => selectedSubject = val),
                  hint: availableSubjects.isEmpty
                      ? Text(l10n.noSubjectsDefined)
                      : null,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: contentController,
                  textInputAction: TextInputAction.newline,
                  minLines: 4,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: l10n.noteContent,
                    prefixIcon: const Icon(Icons.notes_rounded),
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
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: tagsController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.noteTags,
                    helperText: l10n.noteTagsHelp,
                    prefixIcon: const Icon(Icons.sell_rounded),
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
                ),
                const SizedBox(height: 14),
                _buildImagesSection(context, l10n, imagePaths, setDialogState),
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
                  if (titleController.text.trim().isEmpty ||
                      contentController.text.trim().isEmpty) {
                    return;
                  }
                  final rawTags = tagsController.text.split(',');
                  final tags = rawTags
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList();

                  final newNote = StudyNote(
                    id: const Uuid().v4(),
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    subject: selectedSubject,
                    createdAt: DateTime.now(),
                    tags: tags,
                    imagePaths: imagePaths,
                  );
                  context.read<NotesProvider>().addNote(newNote);
                  Navigator.pop(context);
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

  Widget _buildImagesSection(
    BuildContext context,
    AppLocalizations l10n,
    List<String> imagePaths,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.noteImages,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final newImages = await _pickImagesFromGallery();
                if (newImages.isEmpty) return;
                setDialogState(() => imagePaths.addAll(newImages));
              },
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(l10n.addFromGallery),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: l10n.addFromCamera,
              onPressed: () async {
                final newImage = await _pickImageFromCamera();
                if (newImage == null) return;
                setDialogState(() => imagePaths.add(newImage));
              },
              icon: const Icon(Icons.photo_camera_outlined),
            ),
          ],
        ),
        if (imagePaths.isEmpty)
          Text(
            l10n.noImagesYet,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: imagePaths
                .map(
                  (path) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(path),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () =>
                              setDialogState(() => imagePaths.remove(path)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Future<List<String>> _pickImagesFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return [];
    return _copyImagesToAppDir(picked);
  }

  Future<String?> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;
    final copied = await _copyImagesToAppDir([picked]);
    return copied.isEmpty ? null : copied.first;
  }

  Future<List<String>> _copyImagesToAppDir(List<XFile> files) async {
    final directory = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${directory.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }

    final List<String> paths = [];
    for (final file in files) {
      final fileName = file.path.split('/').last;
      final newPath =
          '${notesDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final saved = await File(file.path).copy(newPath);
      paths.add(saved.path);
    }
    return paths;
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
              : const NotesLibraryView(),
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
                    icon: Icon(Icons.note_alt),
                    selectedIcon: Icon(
                      Icons.note_alt,
                      color: Color(0xFF6C63FF),
                    ),
                    label: l10n.notesLibrary,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNotePage()),
                );
              }
            },
            child: const Icon(Icons.add, size: 32),
          ),
        );
      },
    );
  }
}
