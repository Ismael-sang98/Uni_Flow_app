import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/course_provider.dart';
import '../services/api_config_service.dart';
import '../services/course_reminder_scheduler.dart';
import '../services/full_sync_service.dart';
import '../services/sync_error_localizer.dart';
import '../widgets/api_credentials_fields.dart';

class ApiSettingsPage extends StatefulWidget {
  const ApiSettingsPage({super.key});

  @override
  State<ApiSettingsPage> createState() => _ApiSettingsPageState();
}

class _ApiSettingsPageState extends State<ApiSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiConfigService _apiConfigService = ApiConfigService();
  final FullSyncService _fullSyncService = FullSyncService();

  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController();
    _apiKeyController = TextEditingController();
    _loadConfig();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    try {
      final baseUrl = await _apiConfigService.getBaseUrl();
      final apiKey = await _apiConfigService.getApiKey();
      if (!mounted) return;
      setState(() {
        _baseUrlController.text = baseUrl ?? '';
        _apiKeyController.text = apiKey ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.apiSettingsLoadError('$e'))));
    }
  }

  Future<void> _saveConfig() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _apiConfigService.setBaseUrl(_baseUrlController.text.trim());
      await _apiConfigService.setApiKey(_apiKeyController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.apiSettingsSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.apiSettingsSaveError('$e'))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isTestingConnection = true);
    final baseUrl = _stripTrailingSlash(_baseUrlController.text.trim());
    final apiKey = _apiKeyController.text.trim();

    try {
      final uri = Uri.parse('$baseUrl/status');
      final response = await http
          .get(uri, headers: {'X-API-Key': apiKey})
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      if (response.statusCode == 200) {
        _showSnackBarMessage(l10n.apiSettingsTestSuccess, isError: false);
      } else if (response.statusCode == 401) {
        _showSnackBarMessage(l10n.apiSettingsTestInvalidKey, isError: true);
      } else {
        _showSnackBarMessage(
          l10n.apiSettingsTestHttpError(response.statusCode),
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBarMessage(
        l10n.apiSettingsTestNetworkError('$e'),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isTestingConnection = false);
    }
  }

  void _showSnackBarMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _syncAll() async {
    final l10n = AppLocalizations.of(context)!;

    // `_fullSyncService.currentStep` pilote déjà l'état visuel du bouton
    // (voir build()) : pas besoin d'un booléen local ici.
    final result = await _fullSyncService.syncAll();
    if (!mounted) return;

    context.read<CourseProvider>().loadCourses();

    // Programme (ou reprogramme) le rappel de chaque cours créé/mis à jour :
    // FullSyncService lui-même ne le fait pas, faute d'accès à
    // AppLocalizations pour construire le texte de la notification.
    final coursesToRemind = [
      ...result.createdCourses,
      ...result.updatedCourses,
    ];
    if (coursesToRemind.isNotEmpty) {
      await Future.wait(
        coursesToRemind.map((course) => scheduleCourseReminder(course, l10n)),
      );
    }

    final lines = <String>[
      result.profileUpdated
          ? l10n.fullSyncProfileUpdated
          : l10n.fullSyncProfileNotUpdated,
      l10n.fullSyncSubjectsCount(result.subjectsCount),
      l10n.fullSyncCoursesCount(result.coursesCreated, result.coursesUpdated),
    ];
    if (result.coursesSkipped > 0) {
      lines.add(l10n.scheduleSyncSkippedInfo(result.coursesSkipped));
    }
    if (result.hasErrors) {
      lines.addAll(result.errors.map((e) => describeSyncError(l10n, e)));
    }

    _showSnackBarMessage(lines.join('\n'), isError: result.hasErrors);

    if (result.sampleSkippedCourseEntry != null) {
      _showSkippedSampleDialog(result.sampleSkippedCourseEntry!);
    }
  }

  String _syncStepLabel(AppLocalizations l10n, SyncStep step) {
    switch (step) {
      case SyncStep.profile:
        return l10n.syncProgressProfile;
      case SyncStep.subjects:
        return l10n.syncProgressSubjects;
      case SyncStep.schedule:
        return l10n.syncProgressSchedule;
      case SyncStep.idle:
        return l10n.fullSyncButton;
    }
  }

  String _stripTrailingSlash(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  void _showSkippedSampleDialog(String sampleJson) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.scheduleSyncSampleDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.scheduleSyncSampleDialogHint,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                sampleJson,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.apiSettingsTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ApiCredentialsFields(
                      baseUrlController: _baseUrlController,
                      apiKeyController: _apiKeyController,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveConfig,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(l10n.save),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isTestingConnection
                            ? null
                            : _testConnection,
                        icon: _isTestingConnection
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.wifi_tethering),
                        label: Text(l10n.apiSettingsTestButton),
                      ),
                    ),
                    SizedBox(height: UIConstants.spacing12),
                    ValueListenableBuilder<SyncStep>(
                      valueListenable: _fullSyncService.currentStep,
                      builder: (context, step, _) {
                        final isSyncing = step != SyncStep.idle;
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: isSyncing ? null : _syncAll,
                            icon: isSyncing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.sync),
                            label: AnimatedSwitcher(
                              duration: UIConstants.animationDuration,
                              child: Text(
                                _syncStepLabel(l10n, step),
                                key: ValueKey(step),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
