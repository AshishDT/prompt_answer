import 'package:nigerian_igbo/app/data/local/store/local_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore_for_file: public_member_api_docs

class ThemeProvider {
  static ThemeMode _theme = ThemeMode.system;
  static late ThemeMode _themeMode;

  static ThemeMode get themeMode => _themeMode;
  static ThemeMode get currentTheme => _theme;

  static Future<void> setThemeMode(ThemeMode value) async {
    _theme = value;
    _themeMode = getThemeMode(value);

    Get.changeThemeMode(_themeMode);
    LocalStore.themeMode(value.index);
  }

  static ThemeMode getThemeMode(ThemeMode themeMode) {
    ThemeMode _setThemeMode = ThemeMode.system;
    switch (themeMode) {
      case ThemeMode.system:
        _setThemeMode = ThemeMode.system;
        break;
      case ThemeMode.dark:
        _setThemeMode = ThemeMode.dark;
        break;
      case ThemeMode.light:
        _setThemeMode = ThemeMode.light;
        break;
      }

    return _setThemeMode;
  }

  static Future<void> getThemeModeFromStore() async {
    final int _storedTheme = LocalStore.themeMode() ?? 0;

    await setThemeMode(ThemeMode.values[_storedTheme]);
  }

  // checks whether darkmode is set via system or previously by user
  static bool get isDarkModeOn {
    if (currentTheme == ThemeMode.system) {
      if (Get.isPlatformDarkMode) {
        return true;
      }
    }
    if (currentTheme == ThemeMode.dark) {
      return true;
    }
    return false;
  }
}
