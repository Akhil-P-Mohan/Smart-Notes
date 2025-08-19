// lib/screens/home/widgets/note_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/selection_provider.dart';
import 'package:smart_notes/screens/note/note_screen.dart';

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

    return GestureDetector(
      onTap: () {
        if (isMultiSelectMode) {
          // If in multi-select mode, a tap toggles selection
          selectionNotifier.toggle(note.id);
        } else {
          // Otherwise, navigate to the note screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteScreen(note: note)),
          );
        }
      },
      onLongPress: () {
        // A long press always toggles selection and enters multi-select mode
        selectionNotifier.toggle(note.id);
      },
      child: Card(
        // Change color and add an icon if the card is selected
        color: isSelected ? Colors.deepPurple.withOpacity(0.3) : null,
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
                  if (note.title.isNotEmpty && note.content.isNotEmpty)
                    const SizedBox(height: 8),
                  if (note.content.isNotEmpty)
                    Text(
                      note.content,
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
