import 'package:flutter/material.dart';

import 'home.dart';
import 'ui/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: MyHomePage(),
//      routes: {
//        MyHomePage.routeName: (context) => MyHomePage(),
//      }
    );
  }
}
