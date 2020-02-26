import 'package:flutter/material.dart';

import 'package:auto_call/pages/home.dart';
import 'package:auto_call/pages/file_selector.dart';
import 'package:auto_call/pages/call_session.dart';
import 'package:auto_call/pages/old_calls.dart';
import 'package:auto_call/pages/legal.dart';
import 'package:auto_call/pages/about.dart';
import 'package:auto_call/pages/settings.dart';

///
/// This class handles storage of page indexing to take verbosity away from MAIN or DRAWER
///
class AppIndex {
  static final List<dynamic> pageIndex = [
    HomePage,
    OldCallsPage,
    CallSessionPage,
    FileSelectorPage,
    SettingsPage,
    AboutPage,
    LegalPage,
  ];
//  static final Map<String, dynamic> drawerIndex = {
////    HomePage.title:
//  };

  static final List<List> drawerIndex = [
    [Icons.home, HomePage],
    [Icons.note_add, FileSelectorPage],
    [Icons.cloud_upload, CallSessionPage],
    [Icons.history, OldCallsPage],
    [Icons.settings, SettingsPage],
    [Icons.info, AboutPage],
  ];

  static Map<String, WidgetBuilder> buildRoutes(BuildContext context) {
    return Map<String, WidgetBuilder>.fromIterable(pageIndex, key: (e) => e.routeName, value: (e) => ((context) => e()));
  }
}


