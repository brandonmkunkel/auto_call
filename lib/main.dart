import 'package:auto_call/pages/file_selector.dart';
import 'package:auto_call/services/old_calls.dart';
import 'package:flutter/material.dart';

import 'ui/theme.dart';

import 'home.dart';
import 'services/old_calls.dart';
import 'pages/call_queue.dart';
import 'pages/call_queue2.dart';
import 'pages/legal.dart';



void main() {
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
        CallQueuePage.routeName: (context) => CallQueuePage(),
        CallQueuePage2.routeName: (context) => CallQueuePage2(),
        FileSelectorPage.routeName: (context) => FileSelectorPage(),

        LegalPage.routeName: (context) => LegalPage(),
      }
    );
  }
}
