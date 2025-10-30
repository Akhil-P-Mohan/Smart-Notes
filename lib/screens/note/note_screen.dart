// lib/screens/note/note_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:smart_notes/models/checklist_item_model.dart';
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
  late List<TextEditingController> _checklistControllers;
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
    _checklistControllers = _currentNote.checklist
        .map((item) => TextEditingController(text: item.text))
        .toList();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
    for (var controller in _checklistControllers) {
      controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _saveNote);
  }

  void _saveNote() {
    // Before saving, ensure the local _currentNote has the latest text
    // from controllers to avoid race conditions.
    final updatedChecklist = List.generate(
      _checklistControllers.length,
      (index) => ChecklistItem(
        text: _checklistControllers[index].text,
        // Use the correct property name from your model
        isChecked: _currentNote.checklist[index].isChecked,
      ),
    );

    _currentNote = _currentNote.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      checklist: updatedChecklist,
      dateModified: DateTime.now(),
    );

    // Don't save empty notes unless they are special types (image/audio)
    bool isEffectivelyEmpty = _titleController.text.isEmpty &&
        _contentController.text.isEmpty &&
        _currentNote.checklist.every((item) => item.text.isEmpty) &&
        _currentNote.imageUrl == null &&
        _currentNote.audioPath == null;

    if (isEffectivelyEmpty) {
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
    for (var controller in _checklistControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for external updates to the note (like color changes)
    final notes = ref.watch(noteProvider);
    _currentNote = notes.firstWhere((n) => n.id == _currentNote.id,
        orElse: () => _currentNote);

    return Scaffold(
      appBar: NoteAppBar(note: _currentNote),
      // Use a GestureDetector to unfocus text fields when tapping the background
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration.collapsed(hintText: 'Title'),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // --- DYNAMIC CONTENT WIDGETS ---
              if (_currentNote.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Image.file(File(_currentNote.imageUrl!)),
                ),

              if (_currentNote.audioPath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _AudioPlayerWidget(filePath: _currentNote.audioPath!),
                ),

              if (_currentNote.checklist.isNotEmpty) _buildChecklist(),

              // Always show the main content TextField
              TextField(
                controller: _contentController,
                decoration: const InputDecoration.collapsed(
                    hintText: 'Start typing...'),
                maxLines: null, // This allows the field to grow
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NoteBottomBar(note: _currentNote),
    );
  }

  Widget _buildChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _checklistControllers.length,
          itemBuilder: (context, index) {
            final item = _currentNote.checklist[index];
            return Row(
              children: [
                Checkbox(
                  value: item.isChecked, // <-- Use the correct property name
                  onChanged: (bool? value) {
                    // *** THIS IS THE FIX for the missing `copyWith` method ***
                    // We manually create a new ChecklistItem object.
                    final newItem = ChecklistItem(
                      text: item.text,
                      isChecked: value ?? false,
                    );
                    ref
                        .read(noteProvider.notifier)
                        .updateChecklistItem(_currentNote.id, index, newItem);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _checklistControllers[index],
                    decoration:
                        const InputDecoration.collapsed(hintText: 'List item'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () {
                    ref
                        .read(noteProvider.notifier)
                        .deleteChecklistItem(_currentNote.id, index);
                    // Also remove the controller to keep the lists in sync
                    setState(() {
                      _checklistControllers.removeAt(index).dispose();
                    });
                  },
                ),
              ],
            );
          },
        ),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
          onPressed: () {
            ref.read(noteProvider.notifier).addChecklistItem(_currentNote.id);
            // Add a new controller for the new item
            setState(() {
              _checklistControllers.add(TextEditingController());
            });
          },
        ),
        const Divider(),
      ],
    );
  }
}

// A dedicated stateful widget to manage the audio player state
class _AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  const _AudioPlayerWidget({required this.filePath});

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _audioPlayer.setFilePath(widget.filePath);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print("Error initializing audio player: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            StreamBuilder<PlayerState>(
              stream: _audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator());
                } else if (playing != true) {
                  return IconButton(
                      icon: const Icon(Icons.play_arrow),
                      iconSize: 32,
                      onPressed: _audioPlayer.play);
                } else if (processingState != ProcessingState.completed) {
                  return IconButton(
                      icon: const Icon(Icons.pause),
                      iconSize: 32,
                      onPressed: _audioPlayer.pause);
                } else {
                  return IconButton(
                      icon: const Icon(Icons.replay),
                      iconSize: 32,
                      onPressed: () => _audioPlayer.seek(Duration.zero));
                }
              },
            ),
            Expanded(
              child: StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _audioPlayer.duration ?? Duration.zero;
                  return Slider(
                    value: position.inMilliseconds
                        .toDouble()
                        .clamp(0.0, duration.inMilliseconds.toDouble()),
                    max: duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
