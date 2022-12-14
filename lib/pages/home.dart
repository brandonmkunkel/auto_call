import 'package:flutter/material.dart';

import 'package:auto_call/pages/file_selector.dart';
import 'package:auto_call/pages/account.dart';
import 'package:auto_call/ui/charts/homepage_charts.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/widgets/call_session_cards.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "/home";
  final String title = "Home";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double fontSize = 32.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[AccountUpgradeCard(), ActiveCallSessionCard(), HomeStatsCard()],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("New Call Session"),
        icon: Icon(Icons.add_call),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => FileSelectorPage()));
        },
        tooltip: 'Start new call session',
      ),
    );
  }
}
