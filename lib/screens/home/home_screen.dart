import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/providers/selection_provider.dart';
import 'package:smart_notes/screens/home/widgets/custom_app_bar.dart';
import 'package:smart_notes/screens/home/widgets/floating_action_buttons.dart';
import 'package:smart_notes/screens/home/widgets/menu_drawer.dart';
import 'package:smart_notes/screens/home/widgets/note_card.dart';
import 'package:smart_notes/screens/note/note_screen.dart';
import 'package:smart_notes/screens/selected_notes/selected_notes_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Helper method to build the correct AppBar based on the selection mode.
  /// This is a robust way to avoid type inference issues with conditional operators.
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isMultiSelectMode,
    Set<String> selectedIds,
  ) {
    if (isMultiSelectMode) {
      return SelectedNotesBar(
        selectedCount: selectedIds.length,
        onClose: () => ref.read(selectionProvider.notifier).clear(),
        onDelete: () {
          ref.read(noteProvider.notifier).deleteMultipleNotes(selectedIds);
          ref.read(selectionProvider.notifier).clear();
        },
        onPinToggle: () {
          ref
              .read(noteProvider.notifier)
              .togglePinMultipleNotes(selectedIds, true);
          ref.read(selectionProvider.notifier).clear();
        },
        onArchive: () {
          // TODO: Implement archive logic for multiple notes
        },
        onReminder: () {
          // TODO: Implement reminder logic for multiple notes
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
    final notes = ref.watch(noteProvider);
    final selectedIds = ref.watch(selectionProvider);
    final isMultiSelectMode = selectedIds.isNotEmpty;

    final pinnedNotes = notes.where((note) => note.isPinned).toList();
    final otherNotes = notes.where((note) => !note.isPinned).toList();

    return Scaffold(
      key: _scaffoldKey,
      // Call the helper method to build the AppBar
      appBar: _buildAppBar(context, isMultiSelectMode, selectedIds),
      drawer: const MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
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
