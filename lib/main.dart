import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_notes/providers/theme_provider.dart';
import 'package:smart_notes/screens/home/home_screen.dart';
import 'package:smart_notes/utils/app_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive for local storage
  await Hive.initFlutter();
  runApp(
    // Wrap the app with ProviderScope for Riverpod state management
    const ProviderScope(
      child: SmartNotesApp(),
    ),
  );
}

class SmartNotesApp extends ConsumerWidget {
  const SmartNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme provider to get the current theme mode
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Smart Notes',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
