import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'services/calls_and_messages_service.dart';

import 'pages/home.dart';
import 'pages/file_selector.dart';
import 'pages/call_session.dart';
import 'pages/contact_tracker.dart';
import 'pages/old_calls.dart';
import 'pages/legal.dart';
import 'pages/about.dart';
import 'pages/settings.dart';
import 'pages/call_page.dart';

import 'index.dart';

///
/// Main for running the app
///
void main() {
  setupLocator();
  runApp(MyApp());
}

// This file will hold information describing the Theme for the App

final ThemeData appTheme = ThemeData(
    brightness: Brightness.light,
    backgroundColor: Colors.grey[300],
    primarySwatch: defaultTargetPlatform == TargetPlatform.iOS ? Colors.white : Colors.green,
    disabledColor: Colors.grey[400],
    fontFamily: "Raleway");

final ThemeData appDarkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Colors.black,
    primarySwatch: defaultTargetPlatform == TargetPlatform.iOS ? Colors.grey[700] : Colors.green,
    accentColor: Colors.green[600],
    disabledColor: Colors.grey[700],
    fontFamily: "Raleway");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appDarkTheme,
//        theme: appTheme,
//        darkTheme: appDarkTheme,
      home: HomePage(),
      routes: {
        HomePage.routeName: (context) => HomePage(),
//        CallSessionPage.routeName: (context) => CallSessionPage(),
        FileSelectorPage.routeName: (context) => FileSelectorPage(),
        CallPage.routeName: (context) => CallPage(),
        OldCallsPage.routeName: (context) => OldCallsPage(),
        ContactTrackerPage.routeName: (context) => ContactTrackerPage(),
        SettingsPage.routeName: (context) => SettingsPage(),
        LegalPage.routeName: (context) => LegalPage(),
        AboutPage.routeName: (context) => AboutPage(),
      },
      onGenerateRoute: (settings) {
        // If you push the PassArguments route
        if (settings.name == CallSessionPage.routeName) {
          return MaterialPageRoute(builder: (context) => CallSessionPage(fileManager: settings.arguments));
        } else {
          return null;
        }
      },
//      routes: AppIndex.buildRoutes(context),
    );
  }
}
