// lib/services/database/local_storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_notes/models/note_model.dart';

class LocalStorageService {
  final String _notesBoxName = 'notes';
  late Box<Note> _notesBox;

  /// Opens the Hive box for notes. Must be called before other methods.
  Future<void> openBox() async {
    _notesBox = await Hive.openBox<Note>(_notesBoxName);
  }

  /// Saves the current list of notes to the local Hive database.
  Future<void> saveNotes(List<Note> notes) async {
    await _notesBox.clear();
    for (var note in notes) {
      // Use put instead of add to ensure updates work correctly
      await _notesBox.put(note.id, note);
    }
  }

  /// Retrieves all notes from the local Hive database.
  Future<List<Note>> getNotes() async {
    return _notesBox.values.toList();
  }
}
