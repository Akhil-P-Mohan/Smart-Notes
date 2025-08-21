// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. A simple class to hold our two theme settings together.
@immutable
class AppTheme {
  final ThemeMode mode;
  final Color color;

  const AppTheme({required this.mode, required this.color});
}

// 2. The provider now manages an AppTheme object instead of just a Color.
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  static const _themeModeKey = 'themeMode';
  static const _themeColorKey = 'themeColor';

  ThemeNotifier()
      : super(
            const AppTheme(mode: ThemeMode.system, color: Colors.deepPurple)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Load the saved ThemeMode (as an index: 0=system, 1=light, 2=dark)
    final modeIndex = prefs.getInt(_themeModeKey) ?? 0;
    final themeMode = ThemeMode.values[modeIndex];

    // Load the saved Color
    final colorValue = prefs.getInt(_themeColorKey);
    final themeColor =
        colorValue != null ? Color(colorValue) : Colors.deepPurple;

    state = AppTheme(mode: themeMode, color: themeColor);
  }

  // A new method to change ONLY the theme mode
  Future<void> setThemeMode(ThemeMode newMode) async {
    state = AppTheme(mode: newMode, color: state.color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, newMode.index);
  }

  // A new method to change ONLY the theme color
  Future<void> setThemeColor(Color newColor) async {
    state = AppTheme(mode: state.mode, color: newColor);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorKey, newColor.value);
  }
}
