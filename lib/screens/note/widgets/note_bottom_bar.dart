import 'package:flutter/material.dart';
import 'package:smart_notes/models/note_model.dart';

class NoteBottomBar extends StatelessWidget {
  // FIX: Add the note parameter to the constructor
  final Note note;
  const NoteBottomBar({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add...',
            onPressed: () {
              // TODO: Add checklist, recording, image, etc.
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            tooltip: 'Theme',
            onPressed: () {
              // TODO: Show theme/color picker
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Text Styles',
            onPressed: () {
              // TODO: Show text style options
            },
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: () {
              // TODO: Implement undo
            },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: () {
              // TODO: Implement redo
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
            onPressed: () {
              // TODO: Show more options (delete, copy, share)
            },
          ),
        ],
      ),
    );
  }
}
