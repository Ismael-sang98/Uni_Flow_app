import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/notes_provider.dart';
import '../screens/notebook_notes_page.dart';
import 'create_notebook_dialog.dart';

class NotesLibraryView extends StatelessWidget {
  const NotesLibraryView({super.key});

  Future<void> _deleteNotebookDialog(BuildContext context, String name) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<NotesProvider>();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmSupprTitle),
        content: Text(l10n.notesDeleteNotebookPrompt(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'cancel'),
            child: Text(l10n.rejet),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'keep_pages'),
            child: Text(l10n.notesDeleteNotebookKeepPages),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, 'delete_all'),
            child: Text(l10n.notesDeleteNotebookDeleteAll),
          ),
        ],
      ),
    );

    if (result == null || result == 'cancel') return;
    await provider.deleteNotebook(name, deletePages: result == 'delete_all');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        final notebooks = provider.notebooks;
        if (notebooks.isEmpty) {
          final colorScheme = Theme.of(context).colorScheme;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 72,
                  // ignore: deprecated_member_use
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.notesNoNotebook,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => showCreateNotebookDialog(context),
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: Text(l10n.notesCreateNotebook),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          itemCount: notebooks.length + 1,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return OutlinedButton.icon(
                onPressed: () => showCreateNotebookDialog(context),
                icon: const Icon(Icons.create_new_folder_outlined),
                label: Text(l10n.notesCreateNotebook),
              );
            }

            final notebook = notebooks[index - 1];
            final pagesCount = provider.notesByNotebook(notebook).length;

            return Container(
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotebookNotesPage(notebookName: notebook),
                  ),
                ),
                title: Text(
                  notebook,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 14),
                    const SizedBox(width: 6),
                    Text(l10n.notesPagesCount(pagesCount)),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteNotebookDialog(context, notebook),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
