import 'package:flutter/material.dart';

import 'file_selector.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/charts/call_breakdown.dart';

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
          padding: EdgeInsets.all(10.0),
          child:SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Welcome Back!", style: Theme.of(context).textTheme.headline),
                Text(
                    "This app will help you get through a list of phone calls as fast as possible\n\n"
                        "Simply use the button below to upload. For more tools and features, use the menu button at the top left.\n\n"
                        "This app is free to use for a minimum set of productivity features. A premium subscription will eventually be added in.",
                    style: Theme.of(context).textTheme.body2,
                    textAlign: TextAlign.center),
                Divider(),
                Text("Call Stats", style: Theme.of(context).textTheme.headline),
//                Container(
//                  padding: EdgeInsets.all(20.0),
//                  child:  DonutPieChart.withSampleData()
//                ),

//                Spacer()

              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text("New Call Session"),
          icon: Icon(Icons.add_call),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FileSelectorPage()));
          },
          tooltip: 'Start new call session',
        ),
//        floatingActionButtonLocation: FloatingActionButtonLocation.startTop
    );
  }
}
