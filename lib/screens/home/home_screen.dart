import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/providers/search_provider.dart';
import 'package:smart_notes/providers/selection_provider.dart';
import 'package:smart_notes/providers/sort_provider.dart';
import 'package:smart_notes/screens/home/widgets/custom_app_bar.dart';
import 'package:smart_notes/screens/home/widgets/floating_action_buttons.dart';
import 'package:smart_notes/screens/home/widgets/menu_drawer.dart';
import 'package:smart_notes/screens/home/widgets/note_card.dart';
import 'package:smart_notes/screens/selected_notes/selected_notes_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Helper method to build the correct AppBar based on the selection mode.
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isMultiSelectMode,
    Set<String> selectedIds,
  ) {
    if (isMultiSelectMode) {
      // --- NEW LOGIC ---
      // Get all notes to check the status of the selected ones.
      final allNotes = ref.read(noteProvider);
      final selectedNotes =
          allNotes.where((note) => selectedIds.contains(note.id)).toList();

      // Determine the action: if ANY selected note is unpinned, the action is to PIN.
      // Otherwise, if ALL are already pinned, the action is to UNPIN.
      final bool shouldPin = selectedNotes.any((note) => !note.isPinned);
      // --- END NEW LOGIC ---

      return SelectedNotesBar(
        selectedCount: selectedIds.length,
        // --- NEW ---
        isPinningAction: shouldPin,
        onClose: () => ref.read(selectionProvider.notifier).clear(),
        onDelete: () {
          ref.read(noteProvider.notifier).softDeleteMultipleNotes(selectedIds);
          ref.read(selectionProvider.notifier).clear();
        },
        onPinToggle: () {
          // --- MODIFIED ---
          // Use the 'shouldPin' boolean we just calculated to perform the correct action.
          ref
              .read(noteProvider.notifier)
              .togglePinMultipleNotes(selectedIds, shouldPin);
          ref.read(selectionProvider.notifier).clear();
        },
        onArchive: () {
          ref
              .read(noteProvider.notifier)
              .toggleArchiveMultipleNotes(selectedIds, true);
          ref.read(selectionProvider.notifier).clear();
        },
        onThemeChange: () {
          // TODO: Implement theme change for multiple notes
        },
      );
    } else {
      return CustomAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch all necessary providers
    final allNotes = ref.watch(noteProvider);
    final selectedIds = ref.watch(selectionProvider);
    final isMultiSelectMode = selectedIds.isNotEmpty;
    final sortBy = ref.watch(sortByProvider);
    final sortOrder = ref.watch(sortOrderProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // --- FILTERING LOGIC ---
    // 1. Get only active notes (not archived, not deleted)
    final activeNotes =
        allNotes.where((note) => !note.isArchived && !note.isDeleted).toList();

    // 2. Filter by search query
    final filteredNotes = searchQuery.isEmpty
        ? activeNotes
        : activeNotes.where((note) {
            final titleMatch =
                note.title.toLowerCase().contains(searchQuery.toLowerCase());
            final contentMatch =
                note.content.toLowerCase().contains(searchQuery.toLowerCase());
            return titleMatch || contentMatch;
          }).toList();

    // --- SORTING LOGIC ---
    final sortedNotes = List<Note>.from(filteredNotes);
    sortedNotes.sort((a, b) {
      final int comparison;
      switch (sortBy) {
        case SortBy.dateCreated:
          comparison = a.dateCreated.compareTo(b.dateCreated);
          break;
        case SortBy.dateModified:
        default:
          comparison = a.dateModified.compareTo(b.dateModified);
          break;
      }
      return sortOrder == SortOrder.descending ? -comparison : comparison;
    });

    final pinnedNotes = sortedNotes.where((note) => note.isPinned).toList();
    final otherNotes = sortedNotes.where((note) => !note.isPinned).toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context, isMultiSelectMode, selectedIds),
      drawer: const MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            // Show a message if there are no notes at all
            if (activeNotes.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text("Create your first note!")),
              ),
            // Show a message if search yields no results
            if (filteredNotes.isEmpty &&
                searchQuery.isNotEmpty &&
                activeNotes.isNotEmpty)
              const SliverFillRemaining(
                child: Center(child: Text("No notes found.")),
              ),

            if (pinnedNotes.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('PINNED',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey)),
                ),
              ),
              SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childCount: pinnedNotes.length,
                itemBuilder: (context, index) {
                  final note = pinnedNotes[index];
                  return NoteCard(
                    note: note,
                    isSelected: selectedIds.contains(note.id),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
            if (otherNotes.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('OTHERS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey)),
                ),
              ),
              SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childCount: otherNotes.length,
                itemBuilder: (context, index) {
                  final note = otherNotes[index];
                  return NoteCard(
                    note: note,
                    isSelected: selectedIds.contains(note.id),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      floatingActionButton:
          isMultiSelectMode ? null : const FloatingActionButtons(),
    );
  }
}
