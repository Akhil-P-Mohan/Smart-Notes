// lib/screens/home/widgets/floating_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/note_provider.dart';
import 'package:smart_notes/screens/note/note_screen.dart';
import 'package:smart_notes/services/ai/ocr_service.dart';
import 'package:smart_notes/services/ai/voice_to_text_service.dart';
import 'package:uuid/uuid.dart';

class FloatingActionButtons extends ConsumerWidget {
  const FloatingActionButtons({super.key});

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) async {
    final String? selectedLanguage = await showDialog(
      context: context,
      builder: (context) => const OcrLanguageDialog(),
    );

    if (selectedLanguage == null || !context.mounted) return;

    final ocrService = OcrService();
    final extractedText =
        await ocrService.processImageWithLanguage(context, selectedLanguage);

    if (extractedText.isNotEmpty &&
        !extractedText.contains('Error') &&
        context.mounted) {
      final newNote = Note(
        id: const Uuid().v4(),
        title: extractedText.split('\n').first,
        content: extractedText,
        dateCreated: DateTime.now(),
        dateModified: DateTime.now(),
      );

      // Use the correct 'updateNote' method which handles adding new notes
      ref.read(noteProvider.notifier).updateNote(newNote);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteScreen(
            note: newNote,
          ),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(extractedText.contains('Error')
                ? extractedText
                : 'No text was extracted.')),
      );
    }
  }

  void _showPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'voice_fab',
          mini: true,
          onPressed: () async {
            if (await Permission.microphone.request().isGranted) {
              final voiceService = VoiceToTextService();
              final result = await voiceService.startListening();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(result)));
              }
            } else {
              if (context.mounted) {
                _showPermissionDialog(context,
                    'Microphone permission is required to use voice-to-text.');
              }
            }
          },
          child: const Icon(Icons.mic),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'capture_fab',
          mini: true,
          onPressed: () async {
            if (await Permission.camera.request().isGranted) {
              _showLanguagePicker(context, ref);
            } else {
              if (context.mounted) {
                _showPermissionDialog(
                    context, 'Camera permission is required to use OCR.');
              }
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'add_fab',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NoteScreen(note: null)),
            );
          },
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// A dialog widget to let the user choose the OCR language.
// *** THIS IS THE FIX: Providing the full implementation of the class ***
class OcrLanguageDialog extends StatelessWidget {
  const OcrLanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Language for OCR'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context,
                title: 'English', languageCode: 'eng'),
            _buildLanguageOption(context,
                title: 'Hindi (हिंदी)', languageCode: 'hin'),
            _buildLanguageOption(context,
                title: 'Chinese (中文)', languageCode: 'chi'),
            _buildLanguageOption(context,
                title: 'Japanese (日本語)', languageCode: 'jpn'),
            _buildLanguageOption(context,
                title: 'Korean (한국어)', languageCode: 'kor'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        )
      ],
    );
  }

  Widget _buildLanguageOption(BuildContext context,
      {required String title, required String languageCode}) {
    return ListTile(
      title: Text(title),
      subtitle: const Text('Offline', style: TextStyle(fontSize: 12)),
      onTap: () {
        // Return the selected language code when tapped
        Navigator.pop(context, languageCode);
      },
    );
  }
}
