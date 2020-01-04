import 'package:flutter/material.dart';
import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/ui/drawer.dart';

class OldCallsPage extends StatefulWidget {
  static String routeName = "/old_calls";
  final String title = "Call Queue";

  @override
  OldCallsState createState() => new OldCallsState();
}

class OldCallsState extends State<OldCallsPage> {
  bool inCall = false;

  @override
  void initState() {
    super.initState();
  }

//  @override
//  void setState(){
//    super.initState();
//  }

  void changeCallState() {
    setState(() {
      inCall = !inCall;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: appDrawer(context),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child:
        Container(
          child: Text("Old call files will go here"),
        )
      )
    );
  }
}
