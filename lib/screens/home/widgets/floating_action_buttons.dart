import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_notes/screens/note/note_screen.dart';
import 'package:smart_notes/services/ai/ocr_service.dart';
import 'package:smart_notes/services/ai/voice_to_text_service.dart';

class FloatingActionButtons extends StatelessWidget {
  const FloatingActionButtons({super.key});

  /// Shows a simple dialog for denied permissions.
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
              final ocrService = OcrService();
              final text = await ocrService.captureAndProcessImage();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('OCR Result: $text')));
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
            // Navigate to NoteScreen with a null note to indicate creation
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
