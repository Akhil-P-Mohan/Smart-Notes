import 'package:flutter/material.dart';

/// An AppBar that appears when multi-select mode is enabled.
/// It shows the number of selected items and available actions.
class SelectedNotesBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onPinToggle;
  final VoidCallback onReminder;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onThemeChange;

  const SelectedNotesBar({
    super.key,
    required this.selectedCount,
    required this.onClose,
    required this.onPinToggle,
    required this.onReminder,
    required this.onArchive,
    required this.onDelete,
    required this.onThemeChange,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
      ),
      title: Text('$selectedCount selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.push_pin_outlined),
          tooltip: 'Pin/Unpin',
          onPressed: onPinToggle,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Add Reminder',
          onPressed: onReminder,
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
