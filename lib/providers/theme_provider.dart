import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // By default, start with light mode
  ThemeMode _themeMode = ThemeMode.light;

  // A getter so other files can read the current mode
  ThemeMode get themeMode => _themeMode;

  // When the class initializes, load the saved theme
  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // The function your SwitchListTile will call
  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // This tells the whole app to rebuild!
    
    // Save the choice to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDark);
  }

  // Internal function to read from local storage on startup
  _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // If it's null (first time opening app), default to false (light mode)
    bool isDark = prefs.getBool('isDarkMode') ?? false; 
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}