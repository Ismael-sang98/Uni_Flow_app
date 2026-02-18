import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/study_note.dart';

class NotesProvider with ChangeNotifier {
  final Box<StudyNote> _notesBox = Hive.box<StudyNote>('notes');
  List<StudyNote> _notes = [];

  List<StudyNote> get notes => _notes;

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
