import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/study_note.dart';
import '../providers/notes_provider.dart';
import '../services/confirm_deletion.dart';
import '../utils/notebook_color.dart';

/// Corbeille des notes : les notes supprimées y restent [kTrashRetentionDuration]
/// avant purge automatique (voir NotesProvider._purgeExpiredTrash), le temps
/// pour l'utilisateur de les restaurer en cas d'erreur.
class NotesTrashPage extends StatelessWidget {
  const NotesTrashPage({super.key});

  Future<void> _confirmEmptyTrash(
    BuildContext context,
    AppLocalizations l10n,
    int count,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmSupprTitle),
        content: Text(l10n.notesEmptyTrashPrompt(count)),
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
            child: Text(l10n.supp),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await context.read<NotesProvider>().emptyTrash();
  }

  String _daysLeftLabel(AppLocalizations l10n, StudyNote note) {
    final deletedAt = note.deletedAt;
    if (deletedAt == null) return '';
    final elapsed = DateTime.now().difference(deletedAt);
    final remaining = kTrashRetentionDuration - elapsed;
    final daysLeft = remaining.inDays.clamp(0, kTrashRetentionDuration.inDays);
    return l10n.notesTrashDaysLeft(daysLeft);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notesTrashTitle),
        actions: [
          Consumer<NotesProvider>(
            builder: (context, provider, _) {
              final count = provider.deletedNotes.length;
              return IconButton(
                tooltip: l10n.notesEmptyTrash,
                onPressed: count == 0
                    ? null
                    : () => _confirmEmptyTrash(context, l10n, count),
                icon: const Icon(Icons.delete_sweep_outlined),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          final deleted = provider.deletedNotes;
          if (deleted.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacing24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: UIConstants.emptyStateIconSize,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: UIConstants.spacing12),
                    Text(
                      l10n.notesTrashEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: UIConstants.fontSize15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: deleted.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: UIConstants.spacing8),
            itemBuilder: (context, index) {
              final note = deleted[index];
              final color = notebookColorFor(note.subject);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: color,
                    ),
                  ),
                  title: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _daysLeftLabel(l10n, note),
                    style: TextStyle(
                      fontSize: UIConstants.fontSize12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity60),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n.notesRestoreNote,
                        icon: const Icon(Icons.restore_outlined),
                        onPressed: () =>
                            context.read<NotesProvider>().restoreNote(note.id),
                      ),
                      IconButton(
                        tooltip: l10n.supp,
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          final confirmed = await confirmDeletion(
                            context,
                            note.title,
                          );
                          if (!confirmed || !context.mounted) return;
                          await context.read<NotesProvider>().deleteNote(
                            note.id,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
