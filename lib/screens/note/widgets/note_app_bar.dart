import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/services/ai/translation_service.dart';

class NoteAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Note note;
  const NoteAppBar({super.key, required this.note});

  /// Function to show the date and time pickers to set a reminder.
  Future<void> _selectDateTime(BuildContext context, WidgetRef ref) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: note.reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (date == null) return; // User canceled the date picker

    // ignore: use_build_context_synchronously
    if (!context.mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(note.reminderDate ?? DateTime.now()),
    );

    if (time == null) return; // User canceled the time picker

    final selectedDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    // Update the note's reminder date using the provider
    ref.read(noteProvider.notifier).setReminder(note.id, selectedDateTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the most up-to-date version of the note.
    // This ensures the icons (pin, reminder) update instantly when the state changes.
    final liveNote = ref.watch(noteProvider.select((notes) =>
        notes.firstWhere((n) => n.id == note.id, orElse: () => note)));

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
              liveNote.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          tooltip: 'Pin/Unpin',
          onPressed: () {
            // Use the copyWith helper for cleaner code
            final updatedNote = liveNote.copyWith(
              isPinned: !liveNote.isPinned,
              dateModified: DateTime.now(),
            );
            ref.read(noteProvider.notifier).updateNote(updatedNote);
          },
        ),
        IconButton(
          icon: Icon(liveNote.reminderDate != null
              ? Icons.notifications_active
              : Icons.notifications_outlined),
          tooltip: 'Set Reminder',
          onPressed: () {
            _selectDateTime(context, ref);
          },
        ),
        IconButton(
          icon: const Icon(Icons.archive_outlined),
          tooltip: 'Archive',
          onPressed: () {
            ref
                .read(noteProvider.notifier)
                .toggleArchiveStatus(liveNote.id, true);
            // After archiving, leave the note screen
            Navigator.pop(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.translate),
          onPressed: () async {
            // Placeholder for translation
            final translationService = TranslationService();
            final translatedText = await translationService.translateText(
              'Hello, World!',
              'auto',
              'es',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Translated: $translatedText')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.auto_awesome),
          onPressed: () {
            // TODO: Implement AI restructure/summarization
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
