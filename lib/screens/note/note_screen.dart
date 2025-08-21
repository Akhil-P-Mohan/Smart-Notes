// lib/screens/note/note_screen.dart
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

  // This save logic is robust and correct for text content.
  void _saveNote() {
    // Before saving, we need to update the _currentNote object with the
    // latest text from the controllers.
    final title = _titleController.text;
    final content = _contentController.text;

    // We update the local _currentNote object first.
    _currentNote = _currentNote.copyWith(
      title: title,
      content: content,
      dateModified: DateTime.now(),
    );

    if (title.isEmpty && content.isEmpty) {
      if (!_isNewNote) {
        ref.read(noteProvider.notifier).permanentlyDeleteNote(_currentNote.id);
      }
      return;
    }

    ref.read(noteProvider.notifier).updateNote(_currentNote);

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
    // Watch the provider to get the latest note data (e.g., if pinned from app bar)
    final notes = ref.watch(noteProvider);
    _currentNote = notes.firstWhere((n) => n.id == _currentNote.id,
        orElse: () => _currentNote);

    // *** THIS IS THE REVERT ***
    // We are no longer calculating or applying any custom colors.
    // The Scaffold and TextFields will use the app's default theme colors.
    return Scaffold(
      appBar: NoteAppBar(note: _currentNote),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration.collapsed(hintText: 'Title'),
              // Style no longer has a dynamic color
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
                // Style no longer has a dynamic color
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
