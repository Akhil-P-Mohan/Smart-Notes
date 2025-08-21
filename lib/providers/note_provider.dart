// lib/providers/note_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/services/database/local_storage_service.dart';
import 'package:flutter/material.dart';

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
    state = await _storageService.getNotes();
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
      state = [note, ...state];
    }
    _storageService.saveNotes(state);
  }

  /// Permanently deletes a single note.
  void permanentlyDeleteNote(String noteId) {
    state = state.where((note) => note.id != noteId).toList();
    _storageService.saveNotes(state);
  }

  // --- ALL YOUR OTHER NOTE MANAGEMENT METHODS ---
  // These are all correct and do not need to be changed.

  void setReminderForMultipleNotes(Set<String> noteIds, DateTime? reminder) {
    state = [
      for (final note in state)
        if (noteIds.contains(note.id))
          note.copyWith(
            dateModified: DateTime.now(),
            reminderDate: reminder,
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  void toggleArchiveStatus(String noteId, bool isArchived) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          note.copyWith(
            dateModified: DateTime.now(),
            isPinned: false,
            isArchived: isArchived,
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  void toggleArchiveMultipleNotes(Set<String> noteIds, bool isArchived) {
    state = [
      for (final note in state)
        if (noteIds.contains(note.id))
          note.copyWith(
            dateModified: DateTime.now(),
            isPinned: false,
            isArchived: isArchived,
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  void softDeleteNote(String noteId) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          note.copyWith(
            dateModified: DateTime.now(),
            isPinned: false,
            isArchived: false,
            isDeleted: true,
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  void softDeleteMultipleNotes(Set<String> noteIds) {
    state = [
      for (final note in state)
        if (noteIds.contains(note.id))
          note.copyWith(
            dateModified: DateTime.now(),
            isPinned: false,
            isArchived: false,
            isDeleted: true,
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  void restoreNote(String noteId) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          note.copyWith(
            dateModified: DateTime.now(),
            isDeleted: false,
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  void emptyTrash() {
    state = state.where((note) => !note.isDeleted).toList();
    _storageService.saveNotes(state);
  }

  void setReminder(String noteId, DateTime? reminder) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          note.copyWith(
            dateModified: DateTime.now(),
            reminderDate: reminder,
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
          note.copyWith(
            dateModified: DateTime.now(),
            isPinned: isPinned,
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  // The updateNoteColor and updateMultipleNotesColor methods have been removed.
}
