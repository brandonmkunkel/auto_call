import 'package:flutter/material.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/terms.dart';

class LegalPage extends StatefulWidget {
  LegalPage({Key key}) : super(key: key);

  static const String routeName = "/legal";
  final String title = "Terms and Conditions";

  @override
  LegalPageState createState() => new LegalPageState();
}

class LegalPageState extends State<LegalPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: AppDrawer(),
      body: Stack(children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          child: termsAndConditions(),
        )
      ]),
    );
  }
}
