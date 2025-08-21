// lib/screens/note/widgets/note_bottom_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/widgets/reusable/color_picker_dialog.dart';

class NoteBottomBar extends ConsumerWidget {
  final Note note;
  const NoteBottomBar({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add...',
            onPressed: () {/* TODO */},
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Text Styles',
            onPressed: () {/* TODO */},
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: () {/* TODO */},
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: () {/* TODO */},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
            onPressed: () {/* TODO */},
          ),
        ],
      ),
    );
  }
}
