// lib/screens/note/note_screen.dart

import 'dart:async';
import 'dart:convert';
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

// FLUTTER QUILL IMPORTS (Final Fix: No alias, relying on dart_quill_delta for Delta)
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart'; // Relies on this for Delta
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:smart_notes/services/ai/ocr_service.dart';

class NoteScreen extends ConsumerStatefulWidget {
  final Note? note;
  const NoteScreen({super.key, this.note});

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  late TextEditingController _titleController;
  late QuillController _quillController;
  late List<TextEditingController> _checklistControllers;
  late FocusNode _quillFocusNode;

  Timer? _debounce;
  late Note _currentNote;
  bool _isNewNote = false;
  bool _showTextStyles = false;

  @override
  void initState() {
    super.initState();
    _quillFocusNode = FocusNode();
    _isNewNote = widget.note == null;
    _currentNote = widget.note ??
        Note(
          id: const Uuid().v4(),
          title: '',
          content: '[{"insert":"\\n"}]',
          dateCreated: DateTime.now(),
          dateModified: DateTime.now(),
        );

    _titleController = TextEditingController(text: _currentNote.title);
    _checklistControllers = _currentNote.checklist
        .map((item) => TextEditingController(text: item.text))
        .toList();

    // Initialize QuillController
    try {
      final doc = Document.fromJson(jsonDecode(_currentNote.content));
      _quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      _quillController = QuillController(
        // Delta is resolved via dart_quill_delta
        document: Document.fromDelta(Delta()..insert(_currentNote.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Add Listeners
    _titleController.addListener(_onTextChanged);
    _quillController.addListener(_onQuillContentChanged);
    for (var controller in _checklistControllers) {
      controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _saveNote);
  }

  void _onQuillContentChanged() {
    _onTextChanged();
  }

  void _saveNote() {
    final quillContent =
        jsonEncode(_quillController.document.toDelta().toJson());

    final updatedChecklist = List.generate(
      _checklistControllers.length,
      (index) => ChecklistItem(
        text: _checklistControllers[index].text,
        isChecked: _currentNote.checklist[index].isChecked,
      ),
    );

    _currentNote = _currentNote.copyWith(
      title: _titleController.text,
      content: quillContent,
      checklist: updatedChecklist,
      dateModified: DateTime.now(),
    );

    final isQuillEmpty =
        quillContent == '[{"insert":"\\n"}]' || quillContent == '[]';

    bool isEffectivelyEmpty = _titleController.text.isEmpty &&
        isQuillEmpty &&
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
    _quillController.dispose();
    _quillFocusNode.dispose();
    for (var controller in _checklistControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- MEDIA HANDLERS (UNCHANGED) ---
  Future<void> _handleOCR() async {
    final ocrService = OcrService();
    final extractedText =
        await ocrService.processImageWithLanguage(context, 'eng');
    if (extractedText.isNotEmpty &&
        !extractedText.contains('Error') &&
        mounted) {
      final cursorPosition = _quillController.selection.baseOffset;
      _quillController.document.insert(cursorPosition, extractedText);
      _quillController.updateSelection(
        TextSelection.collapsed(offset: cursorPosition + extractedText.length),
        ChangeSource.local,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Text extracted and added to note.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _handleImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      _quillController.document.insert(
        _quillController.selection.baseOffset,
        BlockEmbed.image(imageFile.path),
      );
      _quillController.updateSelection(
        TextSelection.collapsed(
            offset: _quillController.selection.baseOffset + 1),
        ChangeSource.local,
      );
    }
  }

  Future<void> _handleAudio() async {
    final AudioRecorder audioRecorder = AudioRecorder();
    if (_currentNote.audioPath != null ||
        _currentNote.checklist.isNotEmpty ||
        _currentNote.imageUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Only one media/checklist type allowed per note (Audio).'),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (await audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${const Uuid().v4()}.m4a';
      await audioRecorder.start(const RecordConfig(), path: filePath);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Recording... Tap STOP to finish.'),
        duration: const Duration(minutes: 5),
        action: SnackBarAction(
            label: 'STOP',
            onPressed: () async {
              final path = await audioRecorder.stop();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              if (path != null) {
                final updatedNote = _currentNote.copyWith(
                  audioPath: path,
                  dateModified: DateTime.now(),
                );
                setState(() => _currentNote = updatedNote);
                ref.read(noteProvider.notifier).updateNote(updatedNote);
              }
            }),
      ));
    }
  }

  void _handleChecklist() {
    if (_currentNote.audioPath != null ||
        _currentNote.checklist.isNotEmpty ||
        _currentNote.imageUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Only one media/checklist type allowed per note (Checklist).'),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    final updatedNote = _currentNote.copyWith(
      checklist: [ChecklistItem(text: '', isChecked: false)],
      dateModified: DateTime.now(),
    );

    setState(() {
      _currentNote = updatedNote;
      _checklistControllers = updatedNote.checklist
          .map((item) => TextEditingController(text: item.text))
          .toList();
    });
    ref.read(noteProvider.notifier).updateNote(updatedNote);
  }
  // --- END MEDIA HANDLERS ---

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteProvider);
    _currentNote = notes.firstWhere((n) => n.id == _currentNote.id,
        orElse: () => _currentNote);

    return Scaffold(
      appBar: NoteAppBar(note: _currentNote),
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

              // FIX: Switch to QuillEditor and add placeholder
              QuillEditor(
                controller: _quillController,
                focusNode: _quillFocusNode,
                scrollController: ScrollController(),
                config: QuillEditorConfig(
                  placeholder: 'Start typing your notes...',
                  padding: EdgeInsets.zero,
                  // REMOVED: readOnly: false, <- This is the source of the conflict.
                  embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showTextStyles)
            _QuillTextStyleBar(
              controller: _quillController,
              onClose: () => setState(() => _showTextStyles = false),
            ),
          ListenableBuilder(
            listenable: _quillController,
            builder: (context, child) {
              return NoteBottomBar(
                note: _currentNote,
                onAddTap: () => FocusScope.of(context).unfocus(),
                onStyleTap: () =>
                    setState(() => _showTextStyles = !_showTextStyles),
                onUndoTap: _quillController.undo,
                onRedoTap: _quillController.redo,
                canUndo: _quillController.hasUndo,
                canRedo: _quillController.hasRedo,
                onMediaSelect: ({required String type}) async {
                  switch (type) {
                    case 'OCR':
                      await _handleOCR();
                      break;
                    case 'Image':
                      await _handleImage();
                      break;
                    case 'Audio':
                      await _handleAudio();
                      break;
                    case 'List':
                      _handleChecklist();
                      break;
                  }
                },
              );
            },
          ),
        ],
      ),
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
                  value: item.isChecked,
                  onChanged: (bool? value) {
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

class _QuillTextStyleBar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback onClose;

  const _QuillTextStyleBar({required this.controller, required this.onClose});

  @override
  Widget build(BuildContext context) {
    // Helper widget to force-center the toolbar button (FIX 1)
    Widget buildStyledButton(Widget button) {
      return SizedBox(
        width: 48, // Standard button width
        height: 48, // Standard button height
        child: Center(child: button), // Center the button within the space
      );
    }

    return BottomAppBar(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Basic text styles - Wrapped in buildStyledButton
          buildStyledButton(
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.bold,
            ),
          ),
          buildStyledButton(
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.italic,
            ),
          ),
          buildStyledButton(
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.underline,
            ),
          ),
          buildStyledButton(
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.strikeThrough,
            ),
          ),

          // Highlight/Background Color Option
          buildStyledButton(
            QuillToolbarColorButton(
              controller: controller,
              isBackground: true,
            ),
          ),

          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

// ... (Audio Player Widget remains the same)
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
