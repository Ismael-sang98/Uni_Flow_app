import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/student_profile.dart';
import '../providers/notes_provider.dart';

/// Affiche le dialogue de création d'un cahier (à partir d'une matière du
/// profil ou d'un nom personnalisé).
Future<void> showCreateNotebookDialog(BuildContext context) async {
  final settingsBox = Hive.box('settings');
  final profile = settingsBox.get('profile') as StudentProfile?;
  final profileSubjects = profile?.subjects ?? <String>[];

  final notesProvider = context.read<NotesProvider>();
  final existingNotebooks = notesProvider.notebooks;

  // Matières disponibles = matières du profil pas encore utilisées comme cahiers
  final availableSubjects = profileSubjects
      .where((subject) => !existingNotebooks.contains(subject))
      .toList();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) =>
        _CreateNotebookDialog(availableSubjects: availableSubjects),
  );
}

/// Widget (et non simple fonction+`showDialog`) afin que le
/// `TextEditingController` soit créé/détruit via le cycle de vie normal de
/// [State] : le disposer manuellement juste après `await showDialog(...)`
/// entre en course avec l'animation de fermeture du dialogue (qui reconstruit
/// encore le champ pendant quelques frames), et provoque une erreur
/// "TextEditingController was used after being disposed".
class _CreateNotebookDialog extends StatefulWidget {
  final List<String> availableSubjects;

  const _CreateNotebookDialog({required this.availableSubjects});

  @override
  State<_CreateNotebookDialog> createState() => _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends State<_CreateNotebookDialog> {
  late final TextEditingController _customNameController;
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _customNameController = TextEditingController();
  }

  @override
  void dispose() {
    _customNameController.dispose();
    super.dispose();
  }

  Future<void> _submit(String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) return;
    await context.read<NotesProvider>().createNotebook(name);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.availableSubjects.isEmpty) {
      return AlertDialog(
        title: Text(l10n.notesCreateNotebook),
        content: TextField(
          controller: _customNameController,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.notesNotebookName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.rejet),
          ),
          ElevatedButton(
            onPressed: () => _submit(_customNameController.text),
            child: Text(l10n.ajt),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(l10n.notesCreateNotebook),
      content: SingleChildScrollView(
        child: Column(
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
              children: widget.availableSubjects.map((subject) {
                final isSelected = _selectedSubject == subject;
                return ChoiceChip(
                  label: Text(subject),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSubject = selected ? subject : null;
                      _customNameController.clear();
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
              controller: _customNameController,
              autofocus: _selectedSubject == null,
              onChanged: (_) {
                setState(() => _selectedSubject = null);
              },
              decoration: InputDecoration(
                labelText: l10n.notesNotebookName,
                enabled: _selectedSubject == null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.rejet),
        ),
        ElevatedButton(
          onPressed: () =>
              _submit(_selectedSubject ?? _customNameController.text),
          child: Text(l10n.ajt),
        ),
      ],
    );
  }
}
