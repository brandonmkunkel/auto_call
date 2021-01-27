import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme;

  /// Instantiate the ThemeProvider class with a dark theme setting
  ThemeProvider(this._isDarkTheme);

  /// Check if it is dark theme
  isDark() => _isDarkTheme;

  /// Get the theme
  getTheme() => _isDarkTheme ? darkTheme : lightTheme;

  /// Set the Dark Theme and notify listeners
  setTheme(bool isDarkTheme) async {
    _isDarkTheme = isDarkTheme;
    notifyListeners();
  }
}


// This file will hold information describing the Theme for the App
final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    backgroundColor: Colors.grey[100],
    scaffoldBackgroundColor: Colors.grey[100],
    primarySwatch: Colors.green,
    disabledColor: Colors.grey[400],
    fontFamily: "Raleway"
);

final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Colors.grey[900],
    scaffoldBackgroundColor: Colors.grey[900],
    primarySwatch: Colors.green,
    accentColor: Colors.green[600],
    disabledColor: Colors.grey[700],
    fontFamily: "Raleway"
);
