// lib/screens/archive/archive_screen.dart

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

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedNotes =
        ref.watch(noteProvider).where((note) => note.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive'),
      ),
      body: archivedNotes.isEmpty
          ? const Center(
              child: Text(
                'Your archived notes appear here.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: archivedNotes.length,
              itemBuilder: (context, index) {
                final note = archivedNotes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title:
                        Text(note.title.isEmpty ? "Untitled Note" : note.title),
                    subtitle: Text(
                      getPlainTextFromDelta(note.content), // FIX: Use utility
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.unarchive_outlined),
                      tooltip: 'Unarchive',
                      onPressed: () {
                        ref
                            .read(noteProvider.notifier)
                            .toggleArchiveStatus(note.id, false);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
