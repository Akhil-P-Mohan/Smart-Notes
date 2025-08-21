// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/theme_provider.dart'; // Your final theme provider
import 'package:smart_notes/screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notes');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// MyApp is a ConsumerWidget to access providers.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- THIS IS THE FIX ---
    // 1. Watch the provider to get the entire AppTheme object.
    final AppTheme appTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Smart Notes',
      debugShowCheckedModeBanner: false,

      // 2. Use the .mode property from our AppTheme object.
      themeMode: appTheme.mode,

      // --- LIGHT THEME ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          // 3. Use the .color property from our AppTheme object.
          seedColor: appTheme.color,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // --- DARK THEME ---
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          // 4. And use the .color property here too.
          seedColor: appTheme.color,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}
