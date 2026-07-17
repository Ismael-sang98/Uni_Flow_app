import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/student_profile.dart';
import '../providers/course_provider.dart';
import 'home_page.dart';

/// Dernière étape de l'onboarding "Configurer depuis mon compte OBS" :
/// école et classe restent toujours saisies manuellement, jamais
/// synchronisées automatiquement.
class CompleteProfilePage extends StatefulWidget {
  final StudentProfile syncedProfile;

  const CompleteProfilePage({super.key, required this.syncedProfile});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _schoolController;
  late final TextEditingController _classController;

  @override
  void initState() {
    super.initState();
    _schoolController = TextEditingController(
      text: widget.syncedProfile.schoolName,
    );
    _classController = TextEditingController(
      text: widget.syncedProfile.className,
    );
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;

    final finalProfile = StudentProfile(
      name: widget.syncedProfile.name,
      className: _classController.text.trim(),
      schoolName: _schoolController.text.trim(),
      faculty: widget.syncedProfile.faculty,
      profilePicturePath: widget.syncedProfile.profilePicturePath,
      subjects: widget.syncedProfile.subjects,
      department: widget.syncedProfile.department,
    );
    await Hive.box('settings').put('profile', finalProfile);
    if (!mounted) return;

    context.read<CourseProvider>().loadCourses();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.completeProfileTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.completeProfileDescription,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(
                  labelText: l10n.labEc,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(Icons.school),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classController,
                decoration: InputDecoration(
                  labelText: l10n.labCl,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(Icons.class_),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.completeProfileContinueButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
