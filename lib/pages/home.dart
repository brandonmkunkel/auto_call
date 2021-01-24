import 'package:flutter/material.dart';

import 'package:auto_call/pages/file_selector.dart';
import 'package:auto_call/ui/charts/homepage_chart.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/widgets/call_session_cards.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  static const String routeName = "/home";
  final String title = "Home";
  final String label = "Home";

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
      body: Container(
        padding: EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ActiveCallSessionCard(),
              HomeStatsCard()
            ],
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
