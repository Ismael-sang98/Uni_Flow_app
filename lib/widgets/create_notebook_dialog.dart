import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/student_profile.dart';
import '../providers/notes_provider.dart';

/// Affiche le dialogue de création d'un cahier (à partir d'une matière du
/// profil ou d'un nom personnalisé).
Future<void> showCreateNotebookDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;

  final settingsBox = Hive.box('settings');
  final profile = settingsBox.get('profile') as StudentProfile?;
  final profileSubjects = profile?.subjects ?? <String>[];

  final notesProvider = context.read<NotesProvider>();
  final existingNotebooks = notesProvider.notebooks;

  // Matières disponibles = matières du profil pas encore utilisées comme cahiers
  final availableSubjects = profileSubjects
      .where((subject) => !existingNotebooks.contains(subject))
      .toList();

  String? selectedSubject;
  final customNameController = TextEditingController();

  try {
    if (availableSubjects.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.notesCreateNotebook),
          content: TextField(
            controller: customNameController,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.notesNotebookName),
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
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.notesCreateNotebook),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
  } finally {
    customNameController.dispose();
  }
}
