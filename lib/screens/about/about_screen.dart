// lib/screens/about/about_screen.dart

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a slightly smaller font for better readability of long text
    final bodyTextStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Smart Notes'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Notes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Smart Notes is a modern, AI-powered note-taking application designed to make capturing, organizing, and accessing your ideas effortless. Whether you’re jotting down quick thoughts, creating checklists, saving images, or recording voice notes, Smart Notes adapts to your workflow.',
                style: bodyTextStyle,
              ),
              const SizedBox(height: 16),
              Text(
                'Built with Material 3 design and a fully responsive UI, Smart Notes ensures a clean and consistent experience across Android and iOS devices. It supports offline note saving for privacy and accessibility, while offering integration-ready AI/ML features like:',
                style: bodyTextStyle,
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• OCR with multi-language support'),
                    Text('• Translation services'),
                    Text('• Voice-to-Text transcription'),
                    Text('• AI-powered summarization'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'With its intuitive interface, users can pin important notes, sort by creation or modification date, set reminders, apply custom themes, and quickly search through saved content.',
                style: bodyTextStyle,
              ),
              const SizedBox(height: 16),
              Text(
                'Smart Notes is not just a note-taking app—it’s your personal productivity assistant, helping you capture and manage information in the most efficient way possible.',
                style: bodyTextStyle,
              ),
              const Divider(height: 40),
              const Text('Version: 1.0.0'),
              const SizedBox(height: 8),
              const Text('Developed by: Akhil P Mohan'),
              const SizedBox(height: 8),
              const Text('Location: Malappuram, Kerala, India'),
            ],
          ),
        ),
      ),
    );
  }
}
