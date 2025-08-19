// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_notes/main.dart'; // We import main to have the ProviderScope

void main() {
  testWidgets('HomeScreen renders correctly and shows pinned/other sections',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap with ProviderScope because the app uses Riverpod.
    await tester.pumpWidget(const ProviderScope(child: SmartNotesApp()));

    // Verify that the AppBar title (or part of it) is present.
    // Since our search bar has a hint 'Search your notes..', we can look for that.
    expect(
        find.widgetWithText(TextField, 'Search your notes..'), findsOneWidget);

    // Verify the "PINNED" and "OTHERS" text labels are present,
    // because our dummy data has both pinned and unpinned notes.
    expect(find.text('PINNED'), findsOneWidget);
    expect(find.text('OTHERS'), findsOneWidget);

    // Verify the main floating action button (+) is present.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
