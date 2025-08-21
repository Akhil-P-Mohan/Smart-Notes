// lib/screens/selected_notes/selected_notes_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/providers/selection_provider.dart';
import 'package:smart_notes/widgets/reusable/color_picker_dialog.dart';

class SelectedNotesBar extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onPinToggle;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final bool isPinningAction;

  const SelectedNotesBar({
    super.key,
    required this.selectedCount,
    required this.onClose,
    required this.onPinToggle,
    required this.onArchive,
    required this.onDelete,
    required this.isPinningAction,
  });

  Future<void> _selectDateTimeForMultiple(
      BuildContext context, WidgetRef ref) async {
    // ... (This function is unchanged and correct)
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
      ),
      title: Text('$selectedCount selected'),
      // *** THIS IS THE FIX for Bug #2 ***
      // The `actions` list now contains all the required buttons.
      actions: [
        IconButton(
          icon:
              Icon(isPinningAction ? Icons.push_pin_outlined : Icons.push_pin),
          tooltip: isPinningAction ? 'Pin' : 'Unpin',
          onPressed: onPinToggle,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Add Reminder',
          onPressed: () {
            _selectDateTimeForMultiple(context, ref);
          },
        ),
        IconButton(
          icon: const Icon(Icons.archive_outlined),
          tooltip: 'Archive',
          onPressed: onArchive,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete',
          onPressed: onDelete,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
