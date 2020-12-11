import 'package:flutter/material.dart';

import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/ui/drawer.dart';

class ContactTrackerPage extends StatefulWidget {
  static const String routeName = "/contact_tracker";
  final String title = "Contact Tracker";
  final String label = "Contact Tracker";

  @override
  ContactTrackerState createState() => new ContactTrackerState();
}

class ContactTrackerState extends State<ContactTrackerPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                    child: Text("Track your contacts here",
                        textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline5))),
          ],
        ));
  }

}



