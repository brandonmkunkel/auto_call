import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
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