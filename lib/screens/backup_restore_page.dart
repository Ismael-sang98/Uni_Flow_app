import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/course_provider.dart';
import '../providers/deadlines_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../services/course_reminder_scheduler.dart';
import '../services/deadline_reminder_scheduler.dart';

/// Écran de sauvegarde/restauration locale : exporte toutes les données
/// (profil, cours, notes, fichiers) dans une archive zip partageable
/// n'importe où (Drive, email...), et permet de restaurer depuis une telle
/// archive. Volontairement 100% gratuit — aucun service cloud impliqué.
class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final BackupService _backupService = BackupService();
  bool _isExporting = false;
  bool _isImporting = false;

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: UIConstants.snackBarDuration),
    );
  }

  Future<void> _exportBackup() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isExporting = true);
    try {
      final zipFile = await _backupService.exportBackup();
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(zipFile.path)],
        text: l10n.backupExportShareText,
      );
    } catch (e) {
      _showSnackBar(l10n.backupExportError('$e'));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _pickAndImportBackup() async {
    final l10n = AppLocalizations.of(context)!;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backupImportConfirmTitle),
        content: Text(l10n.backupImportConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.rejet),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.backupImportConfirmButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isImporting = true);
    try {
      final summary = await _backupService.importBackup(File(path));
      if (!mounted) return;

      final courseProvider = context.read<CourseProvider>();
      courseProvider.loadCourses();
      context.read<NotesProvider>().loadNotes();
      final deadlinesProvider = context.read<DeadlinesProvider>();
      deadlinesProvider.loadDeadlines();

      final isDarkMode =
          Hive.box('settings').get('isDarkMode', defaultValue: false) as bool;
      if (!mounted) return;
      context.read<ThemeProvider>().toggleTheme(isDarkMode);

      // Reprogramme les rappels des cours et échéances restaurés : ils ont
      // été annulés avant l'import (voir BackupService.importBackup), et les
      // anciens ids de notification ne correspondent plus à rien après un
      // remplacement complet des données.
      for (final course in courseProvider.courses) {
        await scheduleCourseReminder(course, l10n);
      }
      for (final deadline in deadlinesProvider.deadlines) {
        await scheduleDeadlineReminder(deadline, l10n);
      }
      if (!mounted) return;

      _showSnackBar(
        l10n.backupImportSuccess(
          summary.coursesImported,
          summary.notesImported,
          summary.deadlinesImported,
        ),
      );
    } catch (e) {
      _showSnackBar(l10n.backupImportError('$e'));
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupRestoreTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.upload_outlined,
              title: l10n.backupExportButton,
              description: l10n.backupExportDescription,
              buttonLabel: l10n.backupExportButton,
              isLoading: _isExporting,
              onPressed: _isExporting ? null : _exportBackup,
            ),
            const SizedBox(height: UIConstants.spacing24),
            _buildSection(
              icon: Icons.download_outlined,
              title: l10n.backupImportButton,
              description: l10n.backupImportDescription,
              buttonLabel: l10n.backupImportButton,
              isLoading: _isImporting,
              onPressed: _isImporting ? null : _pickAndImportBackup,
              isDestructiveAction: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
    required String buttonLabel,
    required bool isLoading,
    required VoidCallback? onPressed,
    bool isDestructiveAction = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacing16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(UIConstants.borderRadius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: UIConstants.opacity04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6C63FF)),
              const SizedBox(width: UIConstants.spacing8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: UIConstants.fontSize15 + 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacing8),
          Text(
            description,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity70),
              fontSize: UIConstants.fontSize12 + 1,
            ),
          ),
          const SizedBox(height: UIConstants.spacing16),
          SizedBox(
            width: double.infinity,
            height: UIConstants.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              style: isDestructiveAction
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    )
                  : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
