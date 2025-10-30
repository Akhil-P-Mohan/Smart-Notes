// lib/screens/home/widgets/floating_action_buttons.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:smart_notes/models/checklist_item_model.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/screens/note/note_screen.dart';
import 'package:smart_notes/services/ai/ocr_service.dart';
import 'package:uuid/uuid.dart';

class FloatingActionButtons extends ConsumerStatefulWidget {
  const FloatingActionButtons({super.key});

  @override
  ConsumerState<FloatingActionButtons> createState() =>
      _FloatingActionButtonsState();
}

class _FloatingActionButtonsState extends ConsumerState<FloatingActionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isMenuOpen = false;

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  // List of menu items to be displayed
  late final List<_MenuItem> _menuItems;
  double _maxLabelWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Define the menu items here
    _menuItems = [
      _MenuItem(
          icon: Icons.camera_alt,
          label: 'Text Extraction',
          onPressed: _handleTextExtraction),
      _MenuItem(
          icon: Icons.image_outlined,
          label: 'Image',
          onPressed: _handleImageNote),
      _MenuItem(icon: Icons.mic, label: 'Audio', onPressed: _handleAudioNote),
      _MenuItem(icon: Icons.edit, label: 'Text', onPressed: _handleNewTextNote),
      _MenuItem(
          icon: Icons.checklist,
          label: 'List',
          onPressed: _handleChecklistNote),
    ];

    // Pre-calculate the max width of the labels after the first frame
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _calculateMaxLabelWidth());
  }

  /// Calculates the width of the longest label to ensure all option boxes have the same size.
  void _calculateMaxLabelWidth() {
    double maxWidth = 0;
    for (final item in _menuItems) {
      final textPainter = TextPainter(
        text: TextSpan(
            text: item.label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      if (textPainter.width > maxWidth) {
        maxWidth = textPainter.width;
      }
    }
    if (mounted) {
      setState(() {
        _maxLabelWidth = maxWidth;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // --- HANDLER METHODS (ALL FULLY FUNCTIONAL) ---
  void _createNewNoteAndNavigate(Note newNote) {
    ref.read(noteProvider.notifier).updateNote(newNote);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoteScreen(note: newNote)),
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera')),
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery')),
        ],
      ),
    );
  }

  Future<void> _handleTextExtraction() async {
    final ocrService = OcrService();
    final extractedText =
        await ocrService.processImageWithLanguage(context, 'eng');
    if (extractedText.isNotEmpty &&
        !extractedText.contains('Error') &&
        mounted) {
      final newNote = Note(
          id: const Uuid().v4(),
          content: extractedText,
          dateCreated: DateTime.now(),
          dateModified: DateTime.now());
      _createNewNoteAndNavigate(newNote);
    }
  }

  Future<void> _handleImageNote() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;
    final XFile? imageFile = await _picker.pickImage(source: source);
    if (imageFile == null) return;
    final newNote = Note(
        id: const Uuid().v4(),
        imageUrl: imageFile.path,
        dateCreated: DateTime.now(),
        dateModified: DateTime.now());
    _createNewNoteAndNavigate(newNote);
  }

  Future<void> _handleAudioNote() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${const Uuid().v4()}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Recording... Tap to stop.'),
          duration: const Duration(minutes: 5),
          action: SnackBarAction(
              label: 'STOP',
              onPressed: () async {
                final path = await _audioRecorder.stop();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (path == null) return;
                final newNote = Note(
                    id: const Uuid().v4(),
                    audioPath: path,
                    dateCreated: DateTime.now(),
                    dateModified: DateTime.now());
                _createNewNoteAndNavigate(newNote);
              }),
        ));
      }
    }
  }

  void _handleNewTextNote() {
    _createNewNoteAndNavigate(Note(
        id: const Uuid().v4(),
        dateCreated: DateTime.now(),
        dateModified: DateTime.now()));
  }

  void _handleChecklistNote() {
    final newNote = Note(
        id: const Uuid().v4(),
        checklist: [ChecklistItem(text: '', isChecked: false)],
        dateCreated: DateTime.now(),
        dateModified: DateTime.now());
    _createNewNoteAndNavigate(newNote);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isMenuOpen)
          Positioned.fill(
            child: ModalBarrier(
              color: Colors.black.withOpacity(0.1), // Simplified from blur
              dismissible: true,
              onDismiss: _toggleMenu,
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // The animated menu options
              FadeTransition(
                opacity: _animationController,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _menuItems
                        .map((item) =>
                            _buildOption(item, maxLabelWidth: _maxLabelWidth))
                        .toList(),
                  ),
                ),
              ),

              // The main Floating Action Button
              FloatingActionButton(
                heroTag: 'main_fab',
                onPressed: _toggleMenu,
                child: RotationTransition(
                  turns: _rotateAnimation,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption(_MenuItem item, {required double maxLabelWidth}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          _toggleMenu();
          // Delay to allow the menu to start closing before executing the action
          Future.delayed(const Duration(milliseconds: 150), item.onPressed);
        },
        // Use a transparent color to ensure the whole row is tappable
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Label with fixed width
              Container(
                width: maxLabelWidth,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    decoration:
                        TextDecoration.none, // Explicitly remove underline
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // The icon button
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  // FIX: Use the primary color of the FAB
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: kElevationToShadow[2],
                ),
                child: Icon(item.icon, color: colorScheme.onPrimaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  _MenuItem({required this.icon, required this.label, required this.onPressed});
}
