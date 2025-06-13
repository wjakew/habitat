import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'dark_mode';

  // Get the current theme mode
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Toggle between light and dark mode
  Future<ThemeMode> toggleThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = !(prefs.getBool(_themeKey) ?? false);
    await prefs.setBool(_themeKey, isDarkMode);
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Set a specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, mode == ThemeMode.dark);
  }

  // Check if dark mode is enabled
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}
