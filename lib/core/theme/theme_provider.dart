import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key used to persist the theme choice.
const _kThemeModeKey = 'voiceon_theme_mode';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  // Start with light as the default while SharedPreferences loads.
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  /// Reads the persisted theme from SharedPreferences and updates state.
  /// Called once on construction — any widget watching this provider will
  /// rebuild automatically when state changes from light → the saved value.
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModeKey);
    if (saved == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  /// Sets and persists the theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kThemeModeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  /// Kept for backward compatibility if anything in the app calls cycleThemeMode().
  Future<void> cycleThemeMode() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
