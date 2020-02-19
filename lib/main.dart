import 'package:flutter/material.dart';

import 'ui/theme.dart';

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



void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
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
