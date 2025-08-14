import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/providers/selection_provider.dart';

class SelectedNotesBar extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onPinToggle;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onThemeChange;
  // --- NEW ---
  // This boolean determines if the action is to 'pin' (true) or 'unpin' (false)
  final bool isPinningAction;

  const SelectedNotesBar({
    super.key,
    required this.selectedCount,
    required this.onClose,
    required this.onPinToggle,
    required this.onArchive,
    required this.onDelete,
    required this.onThemeChange,
    // --- NEW ---
    required this.isPinningAction,
  });

  /// Shows date/time picker and sets a reminder for all selected notes.
  Future<void> _selectDateTimeForMultiple(
      BuildContext context, WidgetRef ref) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (date == null) return;
    // ignore: use_build_context_synchronously
    if (!context.mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selectedDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    final selectedIds = ref.read(selectionProvider);
    ref
        .read(noteProvider.notifier)
        .setReminderForMultipleNotes(selectedIds, selectedDateTime);

    ref.read(selectionProvider.notifier).clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set for $selectedCount notes.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
      ),
      title: Text('$selectedCount selected'),
      actions: [
        IconButton(
          // --- MODIFIED ---
          // Dynamically change the icon and tooltip based on the action
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
          icon: const Icon(Icons.color_lens_outlined),
          tooltip: 'Change Theme',
          onPressed: onThemeChange,
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
