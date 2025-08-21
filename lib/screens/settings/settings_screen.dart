// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the entire AppTheme object
    final appTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        // Using a ListView to prevent overflow
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- SECTION 1: SYSTEM THEME ---
          Text(
            'App Theme',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          // We use a SegmentedButton for the Light/Dark/System choice
          SegmentedButton<ThemeMode>(
            segments: const <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined)),
              ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.settings_system_daydream_outlined)),
            ],
            selected: {appTheme.mode}, // The currently selected mode
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              // Call the new method to change only the mode
              ref.read(themeProvider.notifier).setThemeMode(newSelection.first);
            },
          ),

          const Divider(height: 48),

          // --- SECTION 2: SYSTEM COLOR ---
          Text(
            'App Color',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // This is the same color picker UI as before
          _ColorPicker(),
        ],
      ),
    );
  }
}

// I've moved the color picker into its own sub-widget for cleanliness
class _ColorPicker extends ConsumerWidget {
  final List<Color> _colorOptions = const [
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.purple,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);

    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: _colorOptions.map((color) {
        return InkWell(
          onTap: () {
            ref.read(themeProvider.notifier).setThemeColor(color);
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: appTheme.color == color
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: appTheme.color == color
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
