// lib/screens/home/home_screen.dart
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

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isMultiSelectMode,
    Set<String> selectedIds,
  ) {
    if (isMultiSelectMode) {
      final allNotes = ref.read(noteProvider);
      final selectedNotes =
          allNotes.where((note) => selectedIds.contains(note.id)).toList();

      final bool shouldPin = selectedNotes.any((note) => !note.isPinned);

      return SelectedNotesBar(
        selectedCount: selectedIds.length,
        isPinningAction: shouldPin,
        onClose: () => ref.read(selectionProvider.notifier).clear(),
        onDelete: () {
          ref.read(noteProvider.notifier).softDeleteMultipleNotes(selectedIds);
          ref.read(selectionProvider.notifier).clear();
        },
        onPinToggle: () {
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
        // *** FIX 1: The 'onThemeChange' callback is removed as it's no longer needed. ***
      );
    } else {
      return CustomAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allNotes = ref.watch(noteProvider);
    final selectedIds = ref.watch(selectionProvider);
    final isMultiSelectMode = selectedIds.isNotEmpty;
    final sortBy = ref.watch(sortByProvider);
    final sortOrder = ref.watch(sortOrderProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final activeNotes =
        allNotes.where((note) => !note.isArchived && !note.isDeleted).toList();

    final filteredNotes = searchQuery.isEmpty
        ? activeNotes
        : activeNotes.where((note) {
            final titleMatch =
                note.title.toLowerCase().contains(searchQuery.toLowerCase());
            final contentMatch =
                note.content.toLowerCase().contains(searchQuery.toLowerCase());
            return titleMatch || contentMatch;
          }).toList();

    final sortedNotes = List<Note>.from(filteredNotes);
    sortedNotes.sort((a, b) {
      final int comparison;
      switch (sortBy) {
        case SortBy.dateCreated:
          comparison = a.dateCreated.compareTo(b.dateCreated);
          break;
        case SortBy.dateModified:
          comparison = a.dateModified.compareTo(b.dateModified);
          break;
        // *** FIX 2: The 'default' case is removed as it's unreachable. ***
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
            if (activeNotes.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text("Create your first note!")),
              ),
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
