// lib/providers/note_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/models/checklist_item_model.dart'; // <-- THIS IS THE FIX
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/services/database/local_storage_service.dart';

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

  // --- NEW METHODS FOR CHECKLISTS ---

  void addChecklistItem(String noteId, {String text = ''}) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          note.copyWith(
            checklist: [...note.checklist, ChecklistItem(text: text)],
            dateModified: DateTime.now(),
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  void updateChecklistItem(
      String noteId, int itemIndex, ChecklistItem newItem) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          note.copyWith(
            checklist: List<ChecklistItem>.from(note.checklist)
              ..[itemIndex] = newItem,
            dateModified: DateTime.now(),
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  void deleteChecklistItem(String noteId, int itemIndex) {
    state = [
      for (final note in state)
        if (note.id == noteId)
          note.copyWith(
            checklist: List<ChecklistItem>.from(note.checklist)
              ..removeAt(itemIndex),
            dateModified: DateTime.now(),
          )
        else
          note
    ];
    _storageService.saveNotes(state);
  }

  // --- ALL YOUR OTHER EXISTING METHODS ---
  // (softDeleteNote, toggleArchiveStatus, setReminder, etc. all remain the same)

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
            isPinned: false, // Unpin when archiving
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
}
