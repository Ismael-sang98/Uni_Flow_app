import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/notes_provider.dart';
import '../services/confirm_deletion.dart';
import '../screens/note_details_page.dart';

class NotesLibraryView extends StatelessWidget {
  const NotesLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        if (provider.notes.isEmpty) {
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
                  l10n.notesEmpty,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          itemCount: provider.notes.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final note = provider.notes[index];
            final created = DateFormat('dd/MM').format(note.createdAt);
            final subject = note.subject?.trim();

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
                    builder: (_) => NoteDetailsPage(note: note),
                  ),
                ),
                title: Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    if (subject != null && subject.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.school_rounded, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          created,
                          style: TextStyle(
                            fontSize: 12,
                            // ignore: deprecated_member_use
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: note.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await confirmDeletion(
                      context,
                      note.title,
                    );
                    if (!confirmed) return;
                    if (!context.mounted) return;
                    await context.read<NotesProvider>().deleteNote(note.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
