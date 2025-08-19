// lib/utils/dummy_data.dart

import 'package:smart_notes/models/note_model.dart';

// Dummy data for initial testing
final List<Note> dummyNotes = [
  Note(
    id: '1',
    title: 'Meeting Notes',
    content:
        'Discussed Q3 goals and project timelines. Key decisions were made.',
    dateCreated: DateTime.now().subtract(const Duration(days: 1)),
    dateModified: DateTime.now(),
    isPinned: true,
  ),
  Note(
    id: '2',
    title: 'Shopping List',
    content: 'Milk, Bread, Eggs, Butter',
    dateCreated: DateTime.now().subtract(const Duration(hours: 5)),
    dateModified: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  Note(
    id: '3',
    title: 'Flutter Ideas',
    content:
        'Build a Smart Notes app with AI features. Use Riverpod for state management.',
    dateCreated: DateTime.now().subtract(const Duration(days: 2)),
    dateModified: DateTime.now(),
    isPinned: true,
  ),
];
