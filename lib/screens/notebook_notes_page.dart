import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/study_note.dart';
import '../providers/notes_provider.dart';
import 'add_note_page.dart';
import 'note_details_page.dart';

// ignore_for_file: deprecated_member_use

class NotebookNotesPage extends StatefulWidget {
  final String notebookName;

  const NotebookNotesPage({super.key, required this.notebookName});

  @override
  State<NotebookNotesPage> createState() => _NotebookNotesPageState();
}

class _NotebookNotesPageState extends State<NotebookNotesPage> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  /// Filtre les notes selon la recherche (titre + contenu + tags)
  List<StudyNote> _filterNotes(List<StudyNote> notes) {
    if (_searchQuery.isEmpty) {
      return notes;
    }

    return notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(_searchQuery);
      final contentMatch = note.content.toLowerCase().contains(_searchQuery);
      final tagsMatch = note.tags.any(
        (tag) => tag.toLowerCase().contains(_searchQuery),
      );

      return titleMatch || contentMatch || tagsMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notebookName),
        actions: [
          IconButton(
            tooltip: l10n.addNote,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddNotePage(initialNotebook: widget.notebookName),
              ),
            ),
            icon: const Icon(Icons.note_add_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // 📝 Liste des notes
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, provider, child) {
                final allNotes = provider.notesByNotebook(widget.notebookName);
                final filteredNotes = _filterNotes(allNotes);

                if (allNotes.isEmpty) {
                  return Center(child: Text(l10n.notesEmpty));
                }

                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.notesSearchEmpty,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: filteredNotes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing:
                            note.imagePaths.isNotEmpty ||
                                note.attachmentPaths.isNotEmpty
                            ? const Icon(Icons.attach_file)
                            : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteDetailsPage(note: note),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddNotePage(initialNotebook: widget.notebookName),
          ),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.addNote),
      ),
    );
  }
}
