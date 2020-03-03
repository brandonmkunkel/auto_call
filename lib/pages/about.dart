import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/terms.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  static const String routeName = "/about";
  final String title = "About";
  final String label = "About";

  @override
  AboutPageState createState() => new AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      drawer: AppDrawer(context),
      body: new Stack(children: <Widget>[
//        buildTermsConditions(context)
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
              child: Container(),
            )));
  }
}
