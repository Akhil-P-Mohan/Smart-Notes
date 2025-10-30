// lib/screens/note/widgets/note_bottom_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/screens/note/note_screen.dart';
import 'package:uuid/uuid.dart';

class NoteBottomBar extends ConsumerStatefulWidget {
  final Note note;
  final VoidCallback onAddTap;
  final VoidCallback onStyleTap;
  final VoidCallback onUndoTap;
  final VoidCallback onRedoTap;
  final bool canUndo;
  final bool canRedo;
  final Function({required String type}) onMediaSelect;

  const NoteBottomBar({
    super.key,
    required this.note,
    required this.onAddTap,
    required this.onStyleTap,
    required this.onUndoTap,
    required this.onRedoTap,
    required this.canUndo,
    required this.canRedo,
    required this.onMediaSelect,
  });

  @override
  ConsumerState<NoteBottomBar> createState() => _NoteBottomBarState();
}

class _NoteBottomBarState extends ConsumerState<NoteBottomBar> {
  static const List<Map<String, dynamic>> _addMenuItems = [
    {'label': 'List', 'icon': Icons.checklist_outlined, 'type': 'List'},
    {'label': 'Image', 'icon': Icons.image_outlined, 'type': 'Image'},
    {'label': 'Audio', 'icon': Icons.mic_none_outlined, 'type': 'Audio'},
    {'label': 'OCR', 'icon': Icons.document_scanner_outlined, 'type': 'OCR'},
  ];

  // NEW METHOD: Show the Add Menu as a Modal Bottom Sheet
  void _showAddMenu(BuildContext context) {
    widget.onAddTap(); // Unfocus keyboard

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: _addMenuItems.map((item) {
            return ListTile(
              leading: Icon(item['icon']),
              title: Text(item['label'] as String),
              onTap: () {
                Navigator.pop(ctx); // Close menu
                widget.onMediaSelect(type: item['type'] as String);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // OLD METHOD: Show the More Options Menu (remains the same)
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delete
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(ctx); // Close menu
                ref.read(noteProvider.notifier).softDeleteNote(widget.note.id);
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            // Make a Copy
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Make a Copy'),
              onTap: () {
                Navigator.pop(ctx); // Close menu
                _makeCopy();
              },
            ),
            // Share
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(ctx); // Close menu
                _shareNote();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. '+' Button (Add Media/Checklist) - NOW CALLS _showAddMenu
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add Media/List',
            onPressed: () => _showAddMenu(context), // CALLS MODAL SHEET
          ),

          // 2. Text Style Button
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Text Styles',
            onPressed: widget.onStyleTap,
          ),

          // 3. Undo
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: widget.canUndo
                ? () {
                    widget.onUndoTap();
                    FocusManager.instance.primaryFocus
                        ?.unfocus(); // FIX: Unfocus after action
                  }
                : null,
            color: widget.canUndo ? null : Colors.grey,
          ),

          // 4. Redo
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: widget.canRedo
                ? () {
                    widget.onRedoTap();
                    FocusManager.instance.primaryFocus
                        ?.unfocus(); // FIX: Unfocus after action
                  }
                : null,
            color: widget.canRedo ? null : Colors.grey,
          ),

          // 5. More Options (⋮)
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
    );
  }

  void _makeCopy() {
    final originalNote = widget.note;
    final newNote = originalNote.copyWith(
      id: const Uuid().v4(),
      dateCreated: DateTime.now(),
      dateModified: DateTime.now(),
      isPinned: false,
      isArchived: false,
      isDeleted: false,
    );
    ref.read(noteProvider.notifier).updateNote(newNote);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NoteScreen(note: newNote)),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Note copied!'),
      duration: Duration(seconds: 1),
    ));
  }

  void _shareNote() {
    final textToShare = '${widget.note.title}\n\n[Rich Content]';
    Share.share(textToShare, subject: widget.note.title);
  }
}
