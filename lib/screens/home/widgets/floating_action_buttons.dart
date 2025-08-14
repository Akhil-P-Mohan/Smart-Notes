import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/screens/note/note_screen.dart';
import 'package:smart_notes/services/ai/ocr_service.dart';
import 'package:smart_notes/services/ai/voice_to_text_service.dart';
import 'package:uuid/uuid.dart';

class FloatingActionButtons extends StatelessWidget {
  const FloatingActionButtons({super.key});

  /// Shows a language selection dialog before starting Tesseract OCR.
  Future<void> _showLanguagePicker(BuildContext context) async {
    // Show a dialog and wait for the user to select a language code string
    final String? selectedLanguage = await showDialog(
      context: context,
      builder: (context) => const OcrLanguageDialog(),
    );

    if (selectedLanguage == null) return; // User canceled

    // Proceed with OCR using the selected language
    final ocrService = OcrService();
    final extractedText =
        await ocrService.processImageWithLanguage(selectedLanguage);

    if (extractedText.isNotEmpty && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteScreen(
            note: Note(
              id: const Uuid().v4(),
              content: extractedText,
              dateCreated: DateTime.now(),
              dateModified: DateTime.now(),
            ),
          ),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text was extracted.')),
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
  Widget build(BuildContext context) {
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
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            } else {
              _showPermissionDialog(context,
                  'Microphone permission is required to use voice-to-text.');
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
              _showLanguagePicker(context);
            } else {
              _showPermissionDialog(
                  context, 'Camera permission is required to use OCR.');
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

/// A dialog widget to let the user choose the OCR language for Tesseract.
class OcrLanguageDialog extends StatelessWidget {
  const OcrLanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Language for OCR'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(context, title: 'English', languageCode: 'eng'),
          _buildLanguageOption(context,
              title: 'Hindi (हिंदी)', languageCode: 'hin'),
          // --- ADD THIS LINE ---
          _buildLanguageOption(context,
              title: 'Kannada (ಕನ್ನಡ)', languageCode: 'kan'),
          // -------------------
          _buildLanguageOption(context,
              title: 'Malayalam (മലയാളം)', languageCode: 'mal'),
          _buildLanguageOption(context,
              title: 'Tamil (தமிழ்)', languageCode: 'tam'),
        ],
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
