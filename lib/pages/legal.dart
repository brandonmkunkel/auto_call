import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/terms.dart';

class LegalPage extends StatefulWidget {
  LegalPage({Key key}) : super(key: key);

  static String routeName = "/legal";
  final String title = "Terms and Conditions";

  @override
  LegalPageState createState() => new LegalPageState();
}

class LegalPageState extends State<LegalPage> {
//  final Widget background = buildFlagBackground();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      drawer: AppDrawer(context),
      body: new Stack(children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
          child: buildScrollableTerms(context),
        )
      ]),
    );
  }
}
