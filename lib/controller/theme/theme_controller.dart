// lib/controller/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/constants.dart';
import '../../theme/theme.dart';

class ThemeController extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isTransitioning = false;

  ThemeController() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isTransitioning => _isTransitioning;
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  Future<void> setThemeMode(bool value) async {
    _isTransitioning = true;
    notifyListeners();

    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Kconstant.ThemeModeKey, value);

    await Future.delayed(const Duration(milliseconds: 300));
    _isTransitioning = false;
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(Kconstant.ThemeModeKey) ?? false;
    notifyListeners();
  }
}
