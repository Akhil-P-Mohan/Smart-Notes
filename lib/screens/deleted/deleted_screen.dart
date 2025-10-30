// lib/screens/deleted/deleted_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'dart:convert'; // Added for JSON decoding
import 'package:flutter_quill/flutter_quill.dart'; // Added for Document class

// Utility to get plain text from Quill Delta JSON
String getPlainTextFromDelta(String deltaJson) {
  try {
    if (deltaJson.isEmpty || deltaJson == '[{"insert":"\\n"}]') {
      return '';
    }
    final doc = Document.fromJson(jsonDecode(deltaJson));
    return doc.toPlainText().trim();
  } catch (e) {
    return deltaJson;
  }
}

class DeletedScreen extends ConsumerWidget {
  const DeletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedNotes =
        ref.watch(noteProvider).where((note) => note.isDeleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (deletedNotes.isNotEmpty)
            TextButton(
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Empty Trash?'),
                    content: const Text(
                        'All notes in the trash will be permanently deleted.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(noteProvider.notifier).emptyTrash();
                          Navigator.pop(context);
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Empty Trash'),
            ),
        ],
      ),
      body: deletedNotes.isEmpty
          ? const Center(
              child: Text(
                'No notes in trash.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: deletedNotes.length,
              itemBuilder: (context, index) {
                final note = deletedNotes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title:
                        Text(note.title.isEmpty ? "Untitled Note" : note.title),
                    subtitle: Text(
                      getPlainTextFromDelta(note.content), // FIX: Use utility
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore_from_trash_outlined),
                          tooltip: 'Restore',
                          onPressed: () {
                            ref
                                .read(noteProvider.notifier)
                                .restoreNote(note.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_outlined,
                              color: Colors.red),
                          tooltip: 'Delete Forever',
                          onPressed: () {
                            ref
                                .read(noteProvider.notifier)
                                .permanentlyDeleteNote(note.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
