import 'package:flutter/material.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/services/ai/translation_service.dart';

class NoteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Note? note;
  const NoteAppBar({super.key, this.note});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(note?.isPinned == true
              ? Icons.push_pin
              : Icons.push_pin_outlined),
          onPressed: () {
            // TODO: Implement pinning logic
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Implement reminder functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.archive_outlined),
          onPressed: () {
            // TODO: Implement archiving logic
          },
        ),
        IconButton(
          icon: const Icon(Icons.translate),
          onPressed: () async {
            // Placeholder for translation
            final translationService = TranslationService();
            final translatedText = await translationService.translateText(
              'Hello, World!',
              'auto',
              'es',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Translated: $translatedText')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.auto_awesome),
          onPressed: () {
            // TODO: Implement AI restructure/summarization
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
