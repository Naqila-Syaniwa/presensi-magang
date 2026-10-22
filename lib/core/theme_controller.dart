
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  ThemeController._();

  static const String _themeKey = 'theme_mode';

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeKey);

    mode.value = savedMode == 'dark'
        ? ThemeMode.dark
        : savedMode == 'system'
            ? ThemeMode.system
            : ThemeMode.light;
  }

  static Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      newMode.name,
    );
  }
}