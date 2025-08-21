// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_notes/main.dart'; // Import your main.dart to get MyApp
import 'package:smart_notes/models/note_model.dart'; // Import Note model for the adapter

void main() {
  testWidgets('HomeScreen renders correctly and shows UI elements',
      (WidgetTester tester) async {
    // --- FIX 1: Add Hive Initialization ---
    // A test environment is isolated, so we must initialize Hive here
    // just like we do in the main() function for the real app.
    await Hive.initFlutter('test_'); // Using a prefix for the test directory
    Hive.registerAdapter(NoteAdapter());
    await Hive.openBox<Note>('notes');

    // --- FIX 2: Build the correct widget, MyApp ---
    // Your main app widget is named MyApp, not SmartNotesApp.
    // We must also wrap it in a ProviderScope for Riverpod to work.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Your existing test logic is great and can now run correctly.
    // Let's assume your home screen has an AppBar with the title 'Smart Notes'.
    // If you have a search bar instead, we can adapt this.
    expect(find.text('Smart Notes'), findsOneWidget);

    // If your initial screen might be empty (no pinned/other notes),
    // it's safer to not test for "PINNED" or "OTHERS" in a smoke test,
    // as they might only appear when notes are present.

    // Verify the main floating action button (+) is present.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
