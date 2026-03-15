import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  /// Load tema dari storage saat app pertama dibuka
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDark = prefs.getBool('app_theme_dark') ?? false;
    _themeMode = savedDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Toggle dan simpan ke storage - berlaku global, tidak terikat user
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_theme_dark', isDark);
    notifyListeners();
  }

  Future<void> resetTheme() async {}
}
