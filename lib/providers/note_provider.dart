import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/services/database/local_storage_service.dart';
import 'package:smart_notes/utils/dummy_data.dart';
import 'package:uuid/uuid.dart';

// Provider to manage the list of notes
final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier();
});

class NoteNotifier extends StateNotifier<List<Note>> {
  final LocalStorageService _storageService = LocalStorageService();
  final _uuid = const Uuid();

  NoteNotifier() : super([]) {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    // Await the opening of the box
    await _storageService.openBox();
    final notes = await _storageService.getNotes();
    if (notes.isEmpty) {
      // If storage is empty, populate it with dummy data for the first run
      for (var note in dummyNotes) {
        state = [...state, note];
      }
      _storageService.saveNotes(state);
    } else {
      state = notes;
    }
  }

  /// Creates a new note or updates an existing one.
  void updateNote(Note note) {
    final noteExists = state.any((n) => n.id == note.id);
    if (noteExists) {
      state = [
        for (final n in state)
          if (n.id == note.id) note else n,
      ];
    } else {
      state = [...state, note];
    }
    _storageService.saveNotes(state);
  }

  /// Deletes a single note by its ID.
  void deleteNote(String noteId) {
    state = state.where((note) => note.id != noteId).toList();
    _storageService.saveNotes(state);
  }

  /// Deletes multiple notes at once.
  void deleteMultipleNotes(Set<String> noteIds) {
    state = state.where((note) => !noteIds.contains(note.id)).toList();
    _storageService.saveNotes(state);
  }

  /// Toggles the pinned status of multiple notes.
  void togglePinMultipleNotes(Set<String> noteIds, bool isPinned) {
    state = [
      for (final note in state)
        if (noteIds.contains(note.id))
          Note(
              id: note.id,
              title: note.title,
              content: note.content,
              dateCreated: note.dateCreated,
              dateModified: DateTime.now(),
              isPinned: isPinned,
              checklist: note.checklist,
              imageUrl: note.imageUrl,
              audioPath: note.audioPath)
        else
          note
    ];
    _storageService.saveNotes(state);
  }
}
