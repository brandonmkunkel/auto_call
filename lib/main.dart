import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'ui/theme.dart';

import 'index.dart';

///
/// Main for running the app
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up the shared preferences
  SharedPreferences.getInstance().then((SharedPreferences prefs) {
    globalSettingManager.fromPrefs(prefs);

    runApp(App());
  });
}

///
/// App Stateful Widget
///
class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeProvider themeChangeProvider =
      new ThemeProvider(globalSettingManager.loaded ? globalSettingManager.getSetting("dark_mode") : false);

  @override
  void initState() {
    super.initState();
  }

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
        }));
  }
}
