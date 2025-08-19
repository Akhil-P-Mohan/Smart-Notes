// lib/providers/selection_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage the set of selected note IDs
final selectionProvider =
    StateNotifierProvider<SelectionNotifier, Set<String>>((ref) {
  return SelectionNotifier();
});

class SelectionNotifier extends StateNotifier<Set<String>> {
  SelectionNotifier() : super({});

  /// Toggles the selection status of a given note ID.
  void toggle(String noteId) {
    if (state.contains(noteId)) {
      state = state.where((id) => id != noteId).toSet();
    } else {
      state = {...state, noteId};
    }
  }

  /// Clears the entire selection.
  void clear() {
    state = {};
  }
}
