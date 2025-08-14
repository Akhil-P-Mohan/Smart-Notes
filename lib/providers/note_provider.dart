import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/services/database/local_storage_service.dart';
import 'package:uuid/uuid.dart';

// Provider to manage the list of notes
final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier();
});

class NoteNotifier extends StateNotifier<List<Note>> {
  final LocalStorageService _storageService = LocalStorageService();

  NoteNotifier() : super([]) {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await _storageService.openBox();
    state = await _storageService.getNotes();
  }

  /// Sets or clears the reminder for multiple notes at once.
  void setReminderForMultipleNotes(Set<String> noteIds, DateTime? reminder) {
    state = [
      for (final note in state)
        if (noteIds.contains(note.id))
          Note(
            id: note.id,
            title: note.title,
            content: note.content,
            dateCreated: note.dateCreated,
            dateModified: DateTime.now(),
            isPinned: note.isPinned,
            checklist: note.checklist,
            imageUrl: note.imageUrl,
            audioPath: note.audioPath,
            isArchived: note.isArchived,
            isDeleted: note.isDeleted,
            reminderDate: reminder, // Set the new reminder date
          )
        else
          note
    ];
    _storageService.saveNotes(state);
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

  /// Toggles the archive status of a single note.
  void toggleArchiveStatus(String noteId, bool isArchived) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          Note(
            id: note.id,
            title: note.title,
            content: note.content,
            dateCreated: note.dateCreated,
            dateModified: DateTime.now(),
            isPinned: false, // Unpin when archiving
            checklist: note.checklist,
            imageUrl: note.imageUrl,
            audioPath: note.audioPath,
            isArchived: isArchived, // Set the archive status
            isDeleted: note.isDeleted,
            reminderDate: note.reminderDate,
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  /// Archives or un-archives multiple notes.
  void toggleArchiveMultipleNotes(Set<String> noteIds, bool isArchived) {
    state = [
      for (final note in state)
        if (noteIds.contains(note.id))
          Note(
              id: note.id,
              title: note.title,
              content: note.content,
              dateCreated: note.dateCreated,
              dateModified: DateTime.now(),
              isPinned: false, // Unpin when archiving
              checklist: note.checklist,
              imageUrl: note.imageUrl,
              audioPath: note.audioPath,
              isArchived: isArchived,
              isDeleted: note.isDeleted,
              reminderDate: note.reminderDate)
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  /// Soft deletes a single note (moves to trash).
  void softDeleteNote(String noteId) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          Note(
              id: note.id,
              title: note.title,
              content: note.content,
              dateCreated: note.dateCreated,
              dateModified: DateTime.now(),
              isPinned: false, // Unpin when deleting
              checklist: note.checklist,
              imageUrl: note.imageUrl,
              audioPath: note.audioPath,
              isArchived: false, // Unarchive when deleting
              isDeleted: true, // Set the deleted status
              reminderDate: note.reminderDate)
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  /// Soft deletes multiple notes.
  void softDeleteMultipleNotes(Set<String> noteIds) {
    state = [
      for (final note in state)
        if (noteIds.contains(note.id))
          Note(
              id: note.id,
              title: note.title,
              content: note.content,
              dateCreated: note.dateCreated,
              dateModified: DateTime.now(),
              isPinned: false,
              checklist: note.checklist,
              imageUrl: note.imageUrl,
              audioPath: note.audioPath,
              isArchived: false,
              isDeleted: true, // Set as deleted
              reminderDate: note.reminderDate)
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  /// Restores a note from the trash.
  void restoreNote(String noteId) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          Note(
              id: note.id,
              title: note.title,
              content: note.content,
              dateCreated: note.dateCreated,
              dateModified: DateTime.now(),
              isPinned: note.isPinned,
              checklist: note.checklist,
              imageUrl: note.imageUrl,
              audioPath: note.audioPath,
              isArchived: note.isArchived,
              isDeleted: false, // Set deleted to false
              reminderDate: note.reminderDate)
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  /// Permanently deletes a single note.
  void permanentlyDeleteNote(String noteId) {
    state = state.where((note) => note.id != noteId).toList();
    _storageService.saveNotes(state);
  }

  /// Empties the trash.
  void emptyTrash() {
    state = state.where((note) => !note.isDeleted).toList();
    _storageService.saveNotes(state);
  }

  // --- Reminder and Pinning logic (some modified) ---
  void setReminder(String noteId, DateTime? reminder) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          Note(
            id: note.id,
            title: note.title,
            content: note.content,
            dateCreated: note.dateCreated,
            dateModified: DateTime.now(),
            isPinned: note.isPinned,
            checklist: note.checklist,
            imageUrl: note.imageUrl,
            audioPath: note.audioPath,
            isArchived: note.isArchived,
            isDeleted: note.isDeleted,
            reminderDate: reminder, // Set the reminder
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

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
              isArchived: note.isArchived, // Keep existing state
              isDeleted: note.isDeleted, // Keep existing state
              checklist: note.checklist,
              imageUrl: note.imageUrl,
              audioPath: note.audioPath)
        else
          note
    ];
    _storageService.saveNotes(state);
  }
}
