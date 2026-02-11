import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/course.dart';
import '../models/student_profile.dart'; // Pour lire les matières
import '../providers/course_provider.dart';
import '../l10n/app_localizations.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();

  // On n'a plus besoin de _titleController car c'est un dropdown
  final _locationController = TextEditingController();

  int _selectedDay = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  int _selectedColor = 0xFF2196F3;

  String? _selectedSubject; // La matière choisie
  List<String> _availableSubjects = []; // La liste venant du profil

  final List<int> _colors = [
    0xFFF44336, // Red
    0xFFE91E63, // Pink
    0xFF9C27B0, // Purple
    0xFF673AB7, // Deep Purple
    0xFF3F51B5, // Indigo
    0xFF2196F3, // Blue
    0xFF00BCD4, // Cyan
    0xFF009688, // Teal
    0xFF4CAF50, // Green
    0xFF8BC34A, // Light Green
    0xFFFFC107, // Amber
    0xFFFF9800, // Orange
    0xFFFF5722, // Deep Orange
    0xFF795548, // Brown
  ];

  @override
  void initState() {
    super.initState();
    _loadSubjectsFromProfile();
  }

  // C'est ici qu'on récupère les matières du profil
  void _loadSubjectsFromProfile() {
    final box = Hive.box('settings');
    final profile = box.get('profile') as StudentProfile?;

    if (profile != null && profile.subjects.isNotEmpty) {
      setState(() {
        _availableSubjects = profile.subjects;
        _selectedSubject =
            _availableSubjects[0]; // Sélectionner le premier par défaut
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveCourse() {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_selectedSubject == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectASubject)));
        return;
      }

      final now = DateTime.now();
      final startDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _startTime.hour,
        _startTime.minute,
      );
      final endDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _endTime.hour,
        _endTime.minute,
      );

      // Vérification basique des heures
      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.endTimeMustBeAfterStartTime)),
        );
        return;
      }

      final newCourse = Course(
        id: const Uuid().v4(),
        title: _selectedSubject!, // On utilise la sélection
        location: _locationController.text,
        dayOfWeeks: _selectedDay,
        color: _selectedColor,
        startTime: startDateTime,
        endTime: endDateTime,
      );

      Provider.of<CourseProvider>(context, listen: false).addCourse(newCourse);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pour la localisation
    final l10n = AppLocalizations.of(context)!;
    // Si l'utilisateur n'a pas défini de matières, on lui dit d'aller le faire
    if (_availableSubjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addCourse)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.noSubjectMnessage,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Explication supplémentaire
                Text(l10n.noSubjectExplanation, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.goBack),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      // ajout d'un DropdownButtonFormField pour les matières
      appBar: AppBar(title: Text(l10n.addCourse)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LISTE DÉROULANTE DES MATIÈRES (Au lieu du TextField)
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: InputDecoration(
                  //Matiere
                  labelText: l10n.mt,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                items: _availableSubjects.map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSubject = val),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: l10n.location,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              // Sélecteur de jour de la semaine
              DropdownButtonFormField<int>(
                initialValue: _selectedDay,
                decoration: InputDecoration(
                  labelText: l10n.day,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: [
                  // Les jours de la semaine
                  DropdownMenuItem(value: 1, child: Text(l10n.j1)),
                  DropdownMenuItem(value: 2, child: Text(l10n.j2)),
                  DropdownMenuItem(value: 3, child: Text(l10n.j3)),
                  DropdownMenuItem(value: 4, child: Text(l10n.j4)),
                  DropdownMenuItem(value: 5, child: Text(l10n.j5)),
                  DropdownMenuItem(value: 6, child: Text(l10n.j6)),
                  DropdownMenuItem(value: 7, child: Text(l10n.j7)),
                ],
                onChanged: (v) => setState(() => _selectedDay = v!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(l10n.startLab),
                      subtitle: Text(_startTime.format(context)),
                      leading: const Icon(Icons.access_time),
                      onTap: () => _selectTime(true),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListTile(
                      title: Text(l10n.endLab),
                      subtitle: Text(_endTime.format(context)),
                      leading: const Icon(Icons.access_time_filled),
                      onTap: () => _selectTime(false),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Section de sélection de couleur
              Text(
                l10n.selectColor,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 5,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: CircleAvatar(
                      backgroundColor: Color(color),
                      radius: 25,
                      child: _selectedColor == color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveCourse,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.savePlan),
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
