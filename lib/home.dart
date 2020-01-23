import 'package:auto_call/services/old_calls.dart';
import 'package:flutter/material.dart';
import 'pages/call_queue.dart';
import 'pages/file_selector.dart';
import 'ui/drawer.dart';
import 'services/old_calls.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  static String routeName = "/home";
  final String title = "Auto Call Home Page";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(context),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Past call lists',
              ),
              oldCalls(),
              Divider(),
              Text(
                "Something homepage here????",
                style: Theme.of(context).textTheme.body1,
              ),
              Divider(),
              Text(
                "Use the button below to select a file for calls",
                style: Theme.of(context).textTheme.display1,
                textAlign: TextAlign.center,
              ),
            ],
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FileSelectorPage()));
          },
          tooltip: 'Upload List',
          child: Icon(Icons.file_upload),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
