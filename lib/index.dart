import 'package:flutter/material.dart';

import 'package:auto_call/pages/home.dart';
import 'package:auto_call/pages/file_selector.dart';
import 'package:auto_call/pages/call_queue.dart';
import 'package:auto_call/pages/old_calls.dart';
import 'package:auto_call/pages/legal.dart';
import 'package:auto_call/pages/about.dart';
import 'package:auto_call/pages/settings.dart';

// Page index used by the app for
final List<dynamic> pageIndex = [
  HomePage,

];


class AppIndex {
  static final List<dynamic> pageIndex = [
    HomePage,
    OldCallsPage,
    CallQueuePage,
    FileSelectorPage,
    SettingsPage,
    AboutPage,
    LegalPage,
  ];

  static Map<String, WidgetBuilder> buildRoutes(BuildContext context) {
    return Map<String, WidgetBuilder>.fromIterable(pageIndex, key: (e) => e.routeName, value: (e) => ((context) => e()));
  }
}


