import 'package:flutter/material.dart';

import 'file_selector.dart';
import 'package:auto_call/ui/drawer.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  static String routeName = "/home";
  final String title = "Auto Call Home Page";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double fontSize = 32.0;

  @override
  Widget build(BuildContext context) {
    //80% of screen width
    double c_width = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
        drawer: AppDrawer(context),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          padding: EdgeInsets.all(20.0),
          child:SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                    "This app will help you get through a list of phone calls as fast as possible\n\n"
                    "Simply use the button below to upload. For more tools and features, use the menu button at the top left.\n\n"
                    "This app is free to use for a minimum set of productivity features. A premium subscription will eventually be added in.",
                    style: Theme.of(context).textTheme.body2,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
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
