import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/student_profile.dart';
import '../providers/notes_provider.dart';
import '../screens/notebook_notes_page.dart';

class NotesLibraryView extends StatelessWidget {
  const NotesLibraryView({super.key});

  Future<void> _createNotebookDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Get available subjects from profile
    final settingsBox = Hive.box('settings');
    final profile = settingsBox.get('profile') as StudentProfile?;
    final profileSubjects = profile?.subjects ?? <String>[];

    // Get existing notebooks
    final notesProvider = context.read<NotesProvider>();
    final existingNotebooks = notesProvider.notebooks;

    // Available subjects = profile subjects not yet used as notebooks
    final availableSubjects = profileSubjects
        .where((subject) => !existingNotebooks.contains(subject))
        .toList();

    String? selectedSubject;
    final customNameController = TextEditingController();

    if (availableSubjects.isEmpty) {
      // No subjects available - show simple text input
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.notesCreateNotebook),
          content: TextField(
            controller: customNameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.notesNotebookName,
              hintText: 'Mon cahier...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.rejet),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = customNameController.text.trim();
                if (name.isEmpty) return;
                await context.read<NotesProvider>().createNotebook(name);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.ajt),
            ),
          ],
        ),
      );
    } else {
      // Show selection dialog with subjects first
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.notesCreateNotebook),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show available subjects
                Text(
                  '${l10n.notesNotebook} (${l10n.suggested})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSubjects.map((subject) {
                    final isSelected = selectedSubject == subject;
                    return ChoiceChip(
                      label: Text(subject),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedSubject = selected ? subject : null;
                          customNameController.clear();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                // Or custom name
                Text(
                  l10n.notesOrCustomName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: customNameController,
                  autofocus: selectedSubject == null,
                  onChanged: (_) {
                    setState(() => selectedSubject = null);
                  },
                  decoration: InputDecoration(
                    labelText: l10n.notesNotebookName,
                    hintText: 'Mon cahier perso...',
                    enabled: selectedSubject == null,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.rejet),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = (selectedSubject ?? customNameController.text)
                      .trim();
                  if (name.isEmpty) return;
                  await context.read<NotesProvider>().createNotebook(name);
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                },
                child: Text(l10n.ajt),
              ),
            ],
          ),
        ),
      );
    }
  }

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
                  color: colorScheme.primary.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.notesNoNotebook,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _createNotebookDialog(context),
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
                onPressed: () => _createNotebookDialog(context),
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
                    color: Colors.black.withOpacity(0.04),
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
