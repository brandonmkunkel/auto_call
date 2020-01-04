import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/terms.dart';

class LegalPage extends StatefulWidget {
  LegalPage({Key key}) : super(key: key);

  static String routeName = "/legal";
  final String title = "Legal";

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
      drawer: appDrawer(context),
      body: new Stack(children: <Widget>[
        buildTermsConditions(context)
      ]),
    );
  }

  Widget buildTermsConditions(BuildContext context) {
    return Container(
        child: new BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: new Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
              ),
              padding: EdgeInsets.all(20.0),
              child: buildScrollableTerms(context),
            )));
  }
}
