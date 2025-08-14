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

  @override
  void initState() {
    super.initState();
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

  _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _saveNote();
    });
  }

  void _saveNote() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      return;
    }

    final updatedNote = Note(
      id: _currentNote.id,
      title: _titleController.text,
      content: _contentController.text,
      dateCreated: _currentNote.dateCreated,
      dateModified: DateTime.now(),
      isPinned: _currentNote.isPinned,
      checklist: _currentNote.checklist,
      imageUrl: _currentNote.imageUrl,
      audioPath: _currentNote.audioPath,
    );
    setState(() {
      _currentNote = updatedNote;
    });
    ref.read(noteProvider.notifier).updateNote(updatedNote);
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
      // This line will now work correctly
      bottomNavigationBar: NoteBottomBar(note: _currentNote),
    );
  }
}
