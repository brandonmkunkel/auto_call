import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = true;

  /// Instantiate the ThemeProvider class with a dark theme setting
  ThemeProvider(this._isDarkTheme);

  /// Check if it is dark theme
  bool isDark() => _isDarkTheme;

  /// Return dark/might mode theme data
  ThemeData getTheme() => _isDarkTheme ? darkTheme : lightTheme;

  /// Get the themeMode which used for switching between dark
  ThemeMode themeMode() => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  /// Set the Dark Theme and notify listeners
  void setTheme(bool isDarkTheme) async {
    _isDarkTheme = isDarkTheme;
    notifyListeners();
  }
}

// This file will hold information describing the Theme for the App
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  backgroundColor: Colors.grey[100],
  scaffoldBackgroundColor: Colors.grey[100],
  primarySwatch: Colors.blue,
  disabledColor: Colors.grey[400],
  fontFamily: "Roboto",
);

final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Colors.grey[900],
    scaffoldBackgroundColor: Colors.grey[900],
    primarySwatch: Colors.blue,
    disabledColor: Colors.grey[700],
    fontFamily: "Roboto");
