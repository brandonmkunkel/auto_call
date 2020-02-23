import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'services/calls_and_messages_service.dart';

import 'pages/home.dart';
import 'pages/file_selector.dart';
import 'pages/call_queue.dart';
import 'pages/call_queue2.dart';
import 'pages/old_calls.dart';
import 'pages/legal.dart';
import 'pages/about.dart';
import 'pages/settings.dart';

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
);

final ThemeData appDarkTheme = ThemeData(
  brightness: Brightness.dark,
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: appTheme,
        darkTheme: appDarkTheme,
        home: HomePage(),
        routes: {
          HomePage.routeName: (context) => HomePage(),
          OldCallsPage.routeName: (context) => OldCallsPage(),
          CallQueuePage.routeName: (context) => CallQueuePage(),
          CallQueuePage2.routeName: (context) => CallQueuePage2(),
          FileSelectorPage.routeName: (context) => FileSelectorPage(),
          SettingsPage.routeName: (context) => SettingsPage(),
          LegalPage.routeName: (context) => LegalPage(),
          AboutPage.routeName: (context) => LegalPage(),
        }
//      routes: AppIndex.buildRoutes(context),
    );
  }
}
