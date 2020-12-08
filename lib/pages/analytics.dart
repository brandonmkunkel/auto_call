import 'package:flutter/material.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/charts/call_breakdown.dart';

class AnalyticsPage extends StatefulWidget {
  static const String routeName = "/analytics";
  final String title = "Analytics";
  final String label = "Analytics";

  @override
  AnalyticsState createState() => new AnalyticsState();
}

class AnalyticsState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(context),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Row(children: [
          Container(child: DonutPieChart.withSampleData()),
        ]));
  }
}
