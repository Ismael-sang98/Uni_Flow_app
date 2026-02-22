import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/study_note.dart';

class NotesProvider with ChangeNotifier {
  final Box<StudyNote> _notesBox = Hive.box<StudyNote>('notes');
  final Box _settingsBox = Hive.box('settings');
  List<StudyNote> _notes = [];

  List<StudyNote> get notes => _notes;

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
    return _notes
        .where((note) => (note.subject ?? '').trim() == notebookName.trim())
        .toList()
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
        await _notesBox.delete(id);
      }
      loadNotes();
      return;
    }

    notifyListeners();
  }

  void loadNotes() {
    _notes = _notesBox.values.toList();
    _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> addNote(StudyNote note) async {
    await _notesBox.put(note.id, note);
    loadNotes();
  }

  Future<void> updateNote(StudyNote note) async {
    await _notesBox.put(note.id, note);
    loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
    loadNotes();
  }
}
