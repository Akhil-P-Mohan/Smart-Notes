// lib/services/database/local_storage_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_notes/models/note_model.dart';

class LocalStorageService {
  // The box is already open, so we just get a reference to it.
  final Box<Note> _notesBox = Hive.box<Note>('notes');

  // The `openBox` method is no longer needed.

  /// Saves the current list of notes to the local Hive database.
  Future<void> saveNotes(List<Note> notes) async {
    // We clear the box first to handle deletions correctly.
    await _notesBox.clear();
    // Then, we write all the notes back. Using a map is efficient.
    final Map<String, Note> notesMap = {for (var note in notes) note.id: note};
    await _notesBox.putAll(notesMap);
  }

  /// Retrieves all notes from the local Hive database.
  Future<List<Note>> getNotes() async {
    // This is a simple, synchronous call now.
    return _notesBox.values.toList();
  }
}
