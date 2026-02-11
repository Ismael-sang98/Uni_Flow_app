import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mon_temps/screens/home_page.dart';
import 'package:provider/provider.dart';
import '../models/student_profile.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- ÉTAT ---
  bool _isEditing = false;
  bool _isFirstTime = false;

  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de texte
  late TextEditingController _nameController;
  late TextEditingController _classController;
  late TextEditingController _schoolController;
  late TextEditingController _facultyController;
  final TextEditingController _subjectInputController =
      TextEditingController(); // Pour ajouter une matière

  String? _profileImagePath;

  // Liste locale des matières pour l'édition
  List<String> _subjects = [];

  final Box _settingsBox = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _classController = TextEditingController();
    _schoolController = TextEditingController();
    _facultyController = TextEditingController();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = _settingsBox.get('profile') as StudentProfile?;

    if (profile != null) {
      // Profil existant
      _nameController.text = profile.name;
      _classController.text = profile.className;
      _schoolController.text = profile.schoolName;
      _facultyController.text = profile.faculty;
      _profileImagePath = profile.profilePicturePath;

      // On charge les matières existantes
      _subjects = List.from(profile.subjects);

      setState(() {
        _isEditing = false;
        _isFirstTime = false;
      });
    } else {
      // Premier lancement
      setState(() {
        _isEditing = true;
        _isFirstTime = true;
        // On peut mettre des matières par défaut pour aider l'utilisateur];
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _schoolController.dispose();
    _facultyController.dispose();
    _subjectInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImagePath = image.path);
    }
  }

  // Ajouter une matière à la liste
  void _addSubject() {
    final text = _subjectInputController.text.trim();
    if (text.isNotEmpty && !_subjects.contains(text)) {
      setState(() {
        _subjects.add(text);
        _subjectInputController.clear();
      });
    }
  }

  // Supprimer une matière
  void _removeSubject(String subject) {
    setState(() {
      _subjects.remove(subject);
    });
  }

  void _saveProfile() {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_subjects.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ajoutMatiereErreur)));
        return;
      }

      final newProfile = StudentProfile(
        name: _nameController.text,
        className: _classController.text,
        schoolName: _schoolController.text,
        profilePicturePath: _profileImagePath ?? '',
        faculty: _facultyController.text,
        subjects: _subjects, // On sauvegarde la liste
      );

      _settingsBox.put('profile', newProfile);

      if (_isFirstTime) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      } else {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(
          context,
          //message de confirmation après enregistrement du profil
        ).showSnackBar(SnackBar(content: Text(l10n.profilEnregistre)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return _buildEditMode();
    } else {
      return _buildViewMode();
    }
  }

  // --- VUE 1 : MODE LECTURE ---
  Widget _buildViewMode() {
    // Pour adapter certains éléments au thème actuel
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      //theme de fond adapté au thème actuel
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.labProfil,
          //style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        //theme de l'appbar adapté au thème actuel
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          // --- BOUTON DE CHANGEMENT DE THÈME ---
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 20),
              Switch(
                value: isDark,
                activeThumbColor: const Color(0xFF6C63FF),
                onChanged: (val) {
                  context.read<ThemeProvider>().toggleTheme(val);
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        (_profileImagePath != null &&
                            _profileImagePath!.isNotEmpty)
                        ? FileImage(File(_profileImagePath!))
                        : null,
                    child:
                        (_profileImagePath == null ||
                            _profileImagePath!.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.school, size: 16),
                        label: Text(_schoolController.text),
                      ),

                      Chip(
                        avatar: const Icon(Icons.curtains_closed, size: 16),
                        label: Text(_facultyController.text),
                      ),
                      Chip(
                        avatar: const Icon(Icons.class_, size: 16),
                        label: Text(_classController.text),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    //label " titre Matières"
                    l10n.labMatiere,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _subjects.isEmpty
                      ? Text(l10n.aucuneMatiere)
                      : Wrap(
                          spacing: 8,
                          children: _subjects
                              .map(
                                (sub) => Chip(
                                  label: Text(sub),
                                  backgroundColor: Theme.of(context).cardColor,
                                  labelStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- VUE 2 : MODE ÉDITION (Formulaire) ---
  Widget _buildEditMode() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isFirstTime ? l10n.labCrPr : l10n.labMdPr),
        leading: _isFirstTime
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: _loadProfile,
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.indigo.shade100,
                  backgroundImage:
                      (_profileImagePath != null &&
                          _profileImagePath!.isNotEmpty)
                      ? FileImage(File(_profileImagePath!))
                      : null,
                  child: const Icon(Icons.camera_alt, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.labNom,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _facultyController,
                decoration: InputDecoration(
                  labelText: l10n.labFkt,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _classController,
                decoration: InputDecoration(
                  labelText: l10n.labCl,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(
                  labelText: l10n.labEc,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              // --- GESTION DES MATIÈRES ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  //label "Matières scolaires"
                  l10n.labSsMat,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              // Zone d'ajout
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subjectInputController,
                      decoration: InputDecoration(
                        // exemple: "Ajouter une matière"
                        hintText: l10n.hintAjoutMatiere,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) =>
                          _addSubject(), // Ajout avec la touche Entrée
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Liste des matières ajoutées (Supprimables)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: _subjects
                      .map(
                        (sub) => Chip(
                          label: Text(sub),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeSubject(sub),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.btnEnregistrerProfil),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
