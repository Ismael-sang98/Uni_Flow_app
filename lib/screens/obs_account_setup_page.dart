import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../l10n/app_localizations.dart';
import '../models/student_profile.dart';
import '../services/api_config_service.dart';
import '../services/course_reminder_scheduler.dart';
import '../services/full_sync_service.dart';
import '../services/sync_error_localizer.dart';
import '../widgets/api_credentials_fields.dart';
import 'complete_profile_page.dart';

/// Onboarding "Configurer depuis mon compte OBS" : saisie de l'URL backend
/// et de la clé API, puis synchronisation complète (profil + matières +
/// emploi du temps) avant de terminer sur [CompleteProfilePage].
class ObsAccountSetupPage extends StatefulWidget {
  const ObsAccountSetupPage({super.key});

  @override
  State<ObsAccountSetupPage> createState() => _ObsAccountSetupPageState();
}

class _ObsAccountSetupPageState extends State<ObsAccountSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiConfigService _apiConfigService = ApiConfigService();
  final FullSyncService _fullSyncService = FullSyncService();

  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  bool _isSyncing = false;

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _connectAndSync() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSyncing = true);
    try {
      await _apiConfigService.setBaseUrl(_baseUrlController.text.trim());
      await _apiConfigService.setApiKey(_apiKeyController.text.trim());

      final result = await _fullSyncService.syncAll();
      if (!mounted) return;

      // Programme le rappel de chaque cours importé, comme le fait
      // ApiSettingsPage pour une resynchro ultérieure.
      final coursesToRemind = [
        ...result.createdCourses,
        ...result.updatedCourses,
      ];
      if (coursesToRemind.isNotEmpty) {
        await Future.wait(
          coursesToRemind.map((course) => scheduleCourseReminder(course, l10n)),
        );
        if (!mounted) return;
      }

      final syncedProfile =
          Hive.box('settings').get('profile') as StudentProfile?;

      if (syncedProfile == null) {
        final message = result.errors.isNotEmpty
            ? result.errors.map((e) => describeSyncError(l10n, e)).join('\n')
            : l10n.obsSetupNoProfileError;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompleteProfilePage(syncedProfile: syncedProfile),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.obsSetupTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.obsSetupDescription,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ApiCredentialsFields(
                baseUrlController: _baseUrlController,
                apiKeyController: _apiKeyController,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSyncing ? null : _connectAndSync,
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(l10n.obsSetupConnectButton),
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
