// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/providers/theme_provider.dart';
import 'package:smart_notes/screens/home/home_screen.dart';

// NEW IMPORTS FOR LOCALE FIX
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Just for the delegate

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
    final AppTheme appTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Smart Notes',
      debugShowCheckedModeBanner: false,
      themeMode: appTheme.mode,

      // FIX 1: ADD LOCALIZATION DELEGATES FOR QUILL
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate, // ADDED: Quill's delegate
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],

      // --- LIGHT THEME ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appTheme.color,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // --- DARK THEME ---
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appTheme.color,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}
