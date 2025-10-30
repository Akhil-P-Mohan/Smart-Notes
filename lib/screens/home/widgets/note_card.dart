import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/selection_provider.dart';
import 'package:smart_notes/screens/note/note_screen.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart'; // Import Quill for Document

// FIX 5: Utility to convert Quill Delta JSON to plain text for the card preview
String getPlainTextFromDelta(String deltaJson) {
  try {
    if (deltaJson.isEmpty || deltaJson == '[{"insert":"\\n"}]') {
      return '';
    }
    // Decode the JSON string into a Quill Document
    final doc = Document.fromJson(jsonDecode(deltaJson));
    // Use Quill's internal method to extract plain text
    return doc.toPlainText().trim();
  } catch (e) {
    // Fallback: If it's not valid JSON (e.g., old notes), return the raw string
    // In a real app, you might want a more sophisticated migration.
    return deltaJson;
  }
}

class NoteCard extends ConsumerWidget {
  final Note note;
  final bool isSelected;

  const NoteCard({
    super.key,
    required this.note,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionNotifier = ref.read(selectionProvider.notifier);
    final isMultiSelectMode = ref.watch(selectionProvider).isNotEmpty;

    // FIX 5: Get the displayable content
    final displayContent = getPlainTextFromDelta(note.content);

    return GestureDetector(
      onTap: () {
        if (isMultiSelectMode) {
          selectionNotifier.toggle(note.id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteScreen(note: note)),
          );
        }
      },
      onLongPress: () {
        selectionNotifier.toggle(note.id);
      },
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.35)
            : null,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.title.isNotEmpty)
                    Text(
                      note.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Use displayContent here
                  if (note.title.isNotEmpty && displayContent.isNotEmpty)
                    const SizedBox(height: 8),
                  if (displayContent.isNotEmpty) // Use displayContent here
                    Text(
                      displayContent, // FIX: DISPLAY PLAIN TEXT
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: Colors.white),
              )
          ],
        ),
      ),
    );
  }
}
