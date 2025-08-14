import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_notes/providers/note_provider.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get notes that have a reminder and are not deleted or archived
    final notesWithReminders = ref.watch(noteProvider).where((note) {
      return note.reminderDate != null && !note.isDeleted && !note.isArchived;
    }).toList();

    // Sort them by reminder date
    notesWithReminders
        .sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: notesWithReminders.isEmpty
          ? const Center(
              child: Text(
                'Notes with upcoming reminders appear here.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notesWithReminders.length,
              itemBuilder: (context, index) {
                final note = notesWithReminders[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title:
                        Text(note.title.isEmpty ? "Untitled Note" : note.title),
                    subtitle: Text(
                      'Reminder: ${DateFormat.yMMMd().add_jm().format(note.reminderDate!)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.notifications_off_outlined),
                      tooltip: 'Clear Reminder',
                      onPressed: () {
                        ref
                            .read(noteProvider.notifier)
                            .setReminder(note.id, null);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
