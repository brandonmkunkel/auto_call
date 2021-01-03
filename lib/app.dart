import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/settings_manager.dart';

import 'pages/home.dart';
import 'pages/file_selector.dart';
import 'pages/call_session.dart';
import 'pages/old_calls.dart';
import 'pages/legal.dart';
import 'pages/about.dart';
import 'pages/settings.dart';
import 'ui/theme.dart';


class AutoCall extends StatefulWidget {
  @override
  _AutoCall createState() => _AutoCall();
}

class _AutoCall extends State<AutoCall> {
  ThemeProvider themeChangeProvider =
  new ThemeProvider(globalSettingManager.loaded ? globalSettingManager.getSetting("dark_mode") : false);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => themeChangeProvider,
        child: Consumer<ThemeProvider>(builder: (BuildContext context, value, Widget child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: Provider.of<ThemeProvider>(context).getTheme(),
            home: HomePage(),
            routes: {
              HomePage.routeName: (context) => HomePage(),
              FileSelectorPage.routeName: (context) => FileSelectorPage(),
//              CallPage.routeName: (context) => CallPage(),
              OldCallsPage.routeName: (context) => OldCallsPage(),
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
        }));
  }
}



