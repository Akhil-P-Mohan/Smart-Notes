// lib/screens/note/note_screen.dart

// *** FIX: Corrected the import path ***
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/screens/note/widgets/note_app_bar.dart';
import 'package:smart_notes/screens/note/widgets/note_bottom_bar.dart';
import 'package:uuid/uuid.dart';

class NoteScreen extends ConsumerStatefulWidget {
  final Note? note;
  const NoteScreen({super.key, this.note});

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Timer? _debounce;
  late Note _currentNote;
  bool _isNewNote = false;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;

    _currentNote = widget.note ??
        Note(
          id: const Uuid().v4(),
          title: '',
          content: '',
          dateCreated: DateTime.now(),
          dateModified: DateTime.now(),
        );

    _titleController = TextEditingController(text: _currentNote.title);
    _contentController = TextEditingController(text: _currentNote.content);

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _saveNote();
    });
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;

    // If both title and content are empty...
    if (title.isEmpty && content.isEmpty) {
      // and it's an existing note, delete it.
      if (!_isNewNote) {
        // *** FIX: Call the correct delete method ***
        ref.read(noteProvider.notifier).permanentlyDeleteNote(_currentNote.id);
      }
      return; // Don't save empty notes.
    }

    final updatedNote = _currentNote.copyWith(
      title: title,
      content: content,
      dateModified: DateTime.now(),
    );

    setState(() {
      _currentNote = updatedNote;
    });

    // *** FIX: Call the correct add/update method ***
    // Your `updateNote` handles both cases perfectly.
    ref.read(noteProvider.notifier).updateNote(updatedNote);

    // Once the note is saved for the first time, it's no longer "new".
    if (_isNewNote) {
      _isNewNote = false;
    }
  }

  @override
  void dispose() {
    _saveNote();
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NoteAppBar(note: _currentNote),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration.collapsed(hintText: 'Title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration.collapsed(
                    hintText: 'Start typing...'),
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NoteBottomBar(note: _currentNote),
    );
  }
}
