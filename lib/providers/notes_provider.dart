import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/study_note.dart';
import '../services/image_manager.dart';

/// Une note dans la corbeille est purgée définitivement après ce délai,
/// pour éviter qu'elle ne s'accumule indéfiniment sans jamais être nettoyée.
const Duration kTrashRetentionDuration = Duration(days: 30);

class NotesProvider with ChangeNotifier {
  final Box<StudyNote> _notesBox = Hive.box<StudyNote>('notes');
  final Box _settingsBox = Hive.box('settings');
  final ImageManager _imageManager = ImageManager();
  List<StudyNote> _notes = [];
  List<StudyNote> _deletedNotes = [];

  /// Notes actives (non supprimées), cahiers épinglés en tête.
  List<StudyNote> get notes => _notes;

  /// Notes dans la corbeille, les plus récemment supprimées en premier.
  List<StudyNote> get deletedNotes => _deletedNotes;

  List<String> get notebooks {
    final saved =
        (_settingsBox.get('custom_notebooks') as List?)
            ?.map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        <String>[];

    final fromNotes = _notes
        .map((note) => note.subject?.trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    final merged = <String>{...saved, ...fromNotes}.toList();
    merged.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return merged;
  }

  List<StudyNote> notesByNotebook(String notebookName) {
    final clean = notebookName.trim();
    final matching = _notes
        .where((note) => (note.subject ?? '').trim() == clean)
        .toList();
    return _sortPinnedFirst(matching);
  }

  /// Trie une liste de notes en mettant les épinglées en tête (chacun des
  /// deux groupes restant trié par date de création décroissante).
  List<StudyNote> _sortPinnedFirst(List<StudyNote> input) {
    final list = List<StudyNote>.from(input);
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  /// Recherche globale (tous cahiers confondus) dans titre, contenu, tags
  /// et nom de cahier. Notes de la corbeille exclues.
  List<StudyNote> searchNotes(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(q);
      final contentMatch = note.content.toLowerCase().contains(q);
      final subjectMatch = (note.subject ?? '').toLowerCase().contains(q);
      final tagsMatch = note.tags.any(
        (tag) => tag.toLowerCase().contains(q),
      );
      return titleMatch || contentMatch || subjectMatch || tagsMatch;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> createNotebook(String notebookName) async {
    final clean = notebookName.trim();
    if (clean.isEmpty) return;

    final saved =
        (_settingsBox.get('custom_notebooks') as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    if (!saved.contains(clean)) {
      saved.add(clean);
      await _settingsBox.put('custom_notebooks', saved);
      notifyListeners();
    }
  }

  Future<void> deleteNotebook(
    String notebookName, {
    required bool deletePages,
  }) async {
    final clean = notebookName.trim();
    if (clean.isEmpty) return;

    final saved =
        (_settingsBox.get('custom_notebooks') as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];
    saved.removeWhere((name) => name.trim() == clean);
    await _settingsBox.put('custom_notebooks', saved);

    if (deletePages) {
      final ids = _notes
          .where((note) => (note.subject ?? '').trim() == clean)
          .map((note) => note.id)
          .toList();
      for (final id in ids) {
        await softDeleteNote(id);
      }
      return;
    }

    notifyListeners();
  }

  void loadNotes() {
    _purgeExpiredTrash();
    final all = _notesBox.values.toList();
    _notes = _sortPinnedFirst(all.where((n) => !n.isDeleted).toList());
    _deletedNotes = all.where((n) => n.isDeleted).toList()
      ..sort((a, b) => (b.deletedAt ?? b.createdAt).compareTo(
        a.deletedAt ?? a.createdAt,
      ));
    notifyListeners();
  }

  /// Purge silencieusement les notes de la corbeille au-delà du délai de
  /// rétention, avec leurs fichiers associés. Appelé à chaque loadNotes()
  /// pour ne pas nécessiter de tâche planifiée séparée.
  void _purgeExpiredTrash() {
    final now = DateTime.now();
    final expired = _notesBox.values.where((n) {
      if (!n.isDeleted || n.deletedAt == null) return false;
      return now.difference(n.deletedAt!) > kTrashRetentionDuration;
    }).toList();
    for (final note in expired) {
      _imageManager.deleteNoteFiles(note);
      _notesBox.delete(note.id);
    }
  }

  Future<void> addNote(StudyNote note) async {
    await _notesBox.put(note.id, note);
    loadNotes();
  }

  Future<void> updateNote(StudyNote note) async {
    await _notesBox.put(note.id, note);
    loadNotes();
  }

  /// Suppression définitive et immédiate (utilisée depuis la corbeille).
  Future<void> deleteNote(String id) async {
    final note = _notesBox.get(id);
    if (note != null) _imageManager.deleteNoteFiles(note);
    await _notesBox.delete(id);
    loadNotes();
  }

  /// Déplace une note vers la corbeille (réversible) au lieu de la
  /// supprimer définitivement — c'est l'action déclenchée par le bouton
  /// "Supprimer" habituel de l'UI.
  Future<void> softDeleteNote(String id) async {
    final note = _notesBox.get(id);
    if (note == null) return;
    await _notesBox.put(
      id,
      note.copyWith(isDeleted: true, deletedAt: DateTime.now()),
    );
    loadNotes();
  }

  Future<void> restoreNote(String id) async {
    final note = _notesBox.get(id);
    if (note == null) return;
    // isDeleted doit repasser à false ; deletedAt n'a plus de sens dès
    // qu'une note n'est plus dans la corbeille, on reconstruit donc la note
    // plutôt que d'utiliser copyWith (qui ne peut pas remettre un champ à
    // null via le pattern `?? this.field`).
    await _notesBox.put(
      id,
      StudyNote(
        id: note.id,
        title: note.title,
        content: note.content,
        subject: note.subject,
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
        tags: note.tags,
        imagePaths: note.imagePaths,
        attachmentPaths: note.attachmentPaths,
        imageCaptions: note.imageCaptions,
        isPinned: note.isPinned,
      ),
    );
    loadNotes();
  }

  Future<void> togglePin(String id) async {
    final note = _notesBox.get(id);
    if (note == null || note.isDeleted) return;
    await _notesBox.put(id, note.copyWith(isPinned: !note.isPinned));
    loadNotes();
  }

  Future<void> emptyTrash() async {
    final ids = _deletedNotes.map((n) => n.id).toList();
    for (final id in ids) {
      final note = _notesBox.get(id);
      if (note != null) _imageManager.deleteNoteFiles(note);
      await _notesBox.delete(id);
    }
    loadNotes();
  }
}
