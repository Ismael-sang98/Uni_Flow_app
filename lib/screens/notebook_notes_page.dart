import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/study_note.dart';
import '../providers/notes_provider.dart';
import '../utils/notebook_color.dart';
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

                final accentColor = notebookColorFor(widget.notebookName);

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: filteredNotes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final provider = context.read<NotesProvider>();
                    return _NoteCard(
                      note: note,
                      accentColor: accentColor,
                      l10n: l10n,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteDetailsPage(note: note),
                        ),
                      ),
                      onTogglePin: () => provider.togglePin(note.id),
                      onDelete: () {
                        provider.softDeleteNote(note.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.noteMovedToTrashMessage),
                            action: SnackBarAction(
                              label: l10n.undo,
                              onPressed: () => provider.restoreNote(note.id),
                            ),
                          ),
                        );
                      },
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

/// Carte de note façon "page de cahier" : liseré de couleur du cahier,
/// aperçu du contenu, tags, date et pièces jointes — remplace l'ancien
/// ListTile brut pour un rendu plus proche d'un vrai carnet de notes.
class _NoteCard extends StatelessWidget {
  final StudyNote note;
  final Color accentColor;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.accentColor,
    required this.l10n,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasAttachments =
        note.imagePaths.isNotEmpty || note.attachmentPaths.isNotEmpty;
    final dateLabel = DateFormat('dd/MM/yyyy').format(note.createdAt);

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.borderRadius16),
        // Material transparent : le Container ci-dessus a un `color` opaque,
        // donc sans ce Material intermédiaire l'InkWell peindrait son splash
        // sur le Material ancêtre le plus proche (sous ce Container), le
        // rendant invisible.
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: accentColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  note.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (note.isPinned)
                                Icon(
                                  Icons.push_pin,
                                  size: UIConstants.iconSize16,
                                  color: accentColor,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(alpha: UIConstants.opacity70),
                              fontSize: UIConstants.fontSize12 + 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                dateLabel,
                                style: TextStyle(
                                  fontSize: UIConstants.fontSize12,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: UIConstants.opacity60),
                                ),
                              ),
                              if (note.tags.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: note.tags
                                        .take(3)
                                        .map(
                                          (tag) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: accentColor.withValues(
                                                alpha: UIConstants.opacity12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize:
                                                    UIConstants.fontSize12,
                                                color: accentColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                              if (hasAttachments) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.attach_file,
                                  size: UIConstants.iconSize16,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: UIConstants.opacity60),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'pin') {
                        onTogglePin();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(
                          note.isPinned ? l10n.noteUnpin : l10n.notePin,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.moveToTrash),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
