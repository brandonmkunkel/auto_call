import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme;

  ThemeProvider(this._isDarkTheme);

  isDark() => _isDarkTheme;

  getTheme() => _isDarkTheme ? darkTheme : lightTheme;

  setTheme(bool isDarkTheme) async {
    _isDarkTheme = isDarkTheme;
    notifyListeners();
  }
}


// This file will hold information describing the Theme for the App
final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    backgroundColor: Colors.grey[300],
    primarySwatch: defaultTargetPlatform == TargetPlatform.iOS ? Colors.white : Colors.green,
    disabledColor: Colors.grey[400],
    fontFamily: "Raleway"
);

final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Colors.grey[900],
    scaffoldBackgroundColor: Colors.grey[900],
    primarySwatch: defaultTargetPlatform == TargetPlatform.iOS ? Colors.grey[700] : Colors.green,
    accentColor: Colors.green[600],
    disabledColor: Colors.grey[700],
    fontFamily: "Raleway"
);