import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'services/calls_and_messages_service.dart';
import 'services/settings_manager.dart';

import 'pages/home.dart';
import 'pages/file_selector.dart';
import 'pages/call_session.dart';
import 'pages/contact_tracker.dart';
import 'pages/old_calls.dart';
import 'pages/legal.dart';
import 'pages/about.dart';
import 'pages/settings.dart';
import 'pages/call_page.dart';
import 'ui/theme.dart';

import 'index.dart';

///
/// Main for running the app
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadGlobalSettings();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: darkTheme,
//        theme: appTheme,
//        darkTheme: appDarkTheme,
      home: HomePage(),
      routes: {
        HomePage.routeName: (context) => HomePage(),
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
    );
  }
}
