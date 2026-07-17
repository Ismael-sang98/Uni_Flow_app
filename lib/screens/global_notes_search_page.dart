import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/notes_provider.dart';
import '../utils/notebook_color.dart';
import 'note_details_page.dart';

/// Recherche à travers tous les cahiers (contrairement à la recherche de
/// NotebookNotesPage qui se limite à un seul cahier) — cherche dans le
/// titre, le contenu, les tags et le nom du cahier.
class GlobalNotesSearchPage extends StatefulWidget {
  const GlobalNotesSearchPage({super.key});

  @override
  State<GlobalNotesSearchPage> createState() => _GlobalNotesSearchPageState();
}

class _GlobalNotesSearchPageState extends State<GlobalNotesSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() => _query = _searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.notesGlobalSearchHint,
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          if (_query.trim().isEmpty) {
            return Center(
              child: Text(
                l10n.notesGlobalSearchPrompt,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity60),
                ),
              ),
            );
          }

          final results = provider.searchNotes(_query);
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.notesSearchEmpty,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity60),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: results.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: UIConstants.spacing8),
            itemBuilder: (context, index) {
              final note = results[index];
              final color = notebookColorFor(note.subject);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: note.isPinned
                        ? Icon(Icons.push_pin, size: 18, color: color)
                        : Icon(Icons.description_outlined, size: 18, color: color),
                  ),
                  title: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${note.subject ?? ''} · ${note.content}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
    );
  }
}
