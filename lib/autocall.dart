
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'services/settings_manager.dart';

import 'pages/onboarding.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/file_selector.dart';
import 'pages/call_session.dart';
import 'pages/past_sessions.dart';
import 'pages/legal.dart';
import 'pages/settings.dart';
import 'ui/theme.dart';

class AutoCall extends StatefulWidget {
  final String title = "Auto Call";

  @override
  _AutoCall createState() => _AutoCall();
}

class _AutoCall extends State<AutoCall> {
  // Dynamic Theme
  ThemeProvider themeChangeProvider =
      new ThemeProvider(globalSettingManager.loaded ? globalSettingManager.getSetting("darkMode") : false);

  // Firebase Analytics observers
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<ThemeProvider>(builder: (BuildContext context, value, Widget child) {
        return MaterialApp(
          title: widget.title,
          theme: Provider.of<ThemeProvider>(context).getTheme(),

          // Set apps first page by checking whether or not the user has been onboarded
          home: globalSettingManager.getSetting("userOnboarded") ? HomePage() : OnboardingPage() ,

          // Routes
          routes: {
            HomePage.routeName: (context) => HomePage(),
            OnboardingPage.routeName: (context) => OnboardingPage(),
            LoginPage.routeName: (context) => LoginPage(),
            FileSelectorPage.routeName: (context) => FileSelectorPage(),
//              CallPage.routeName: (context) => CallPage(),
            PastSessionsPage.routeName: (context) => PastSessionsPage(),
            SettingsPage.routeName: (context) => SettingsPage(),
            LegalPage.routeName: (context) => LegalPage(),
          },
          onGenerateRoute: (settings) {
            // If you push the PassArguments route
            if (settings.name == CallSessionPage.routeName) {
              return MaterialPageRoute(builder: (context) => CallSessionPage(fileManager: settings.arguments));
            } else {
              return null;
            }
          },
          navigatorObservers: <NavigatorObserver>[observer],
        );
      }),
    );
  }
}
