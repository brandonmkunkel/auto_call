import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'classes/settings_manager.dart';

import 'pages/onboarding.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/file_selector.dart';
import 'pages/contacts.dart';
import 'pages/past_sessions.dart';
import 'pages/account.dart';
import 'pages/upgrade.dart';
import 'pages/settings.dart';
import 'ui/theme.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AutoCall extends StatefulWidget {
  final String title = "Auto Call";

  @override
  _AutoCall createState() => _AutoCall();
}

class _AutoCall extends State<AutoCall> {
  // Dynamic Theme
  ThemeProvider themeChangeProvider = ThemeProvider(globalSettingManager.get("darkMode"));

  // Firebase Analytics observers
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<ThemeProvider>(builder: (BuildContext context, value, Widget? child) {
        return MaterialApp(
          title: widget.title,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: Provider.of<ThemeProvider>(context).themeMode(),

          // Set apps first page by checking whether or not the user has been onboarded
          home: !globalSettingManager.get("userOnboarded")
              ? OnboardingPage()
              : _auth.currentUser != null
                  ? HomePage()
                  : LoginPage(),

          // Routes
          routes: {
            HomePage.routeName: (context) => HomePage(),
            OnboardingPage.routeName: (context) => OnboardingPage(),
            LoginPage.routeName: (context) => LoginPage(),
            FileSelectorPage.routeName: (context) => FileSelectorPage(),
            ContactsPage.routeName: (context) => ContactsPage(),
            PastSessionsPage.routeName: (context) => PastSessionsPage(),
            AccountPage.routeName: (context) => AccountPage(),
            UpgradePage.routeName: (context) => UpgradePage(),
            SettingsPage.routeName: (context) => SettingsPage(),
          },
          navigatorObservers: <NavigatorObserver>[observer],
        );
      }),
    );
  }
}
