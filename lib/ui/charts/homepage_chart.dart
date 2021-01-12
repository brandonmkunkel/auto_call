import 'package:flutter/material.dart';

import 'package:auto_call/pages/analytics.dart';
import 'package:auto_call/ui/charts/call_breakdown.dart';


class HomeStatsCard extends StatefulWidget {
  @override
  HomeStatsCardState createState() => new HomeStatsCardState();
}

class HomeStatsCardState extends State<HomeStatsCard> {
  @override
  Widget build(BuildContext context) {
   return Card(
       child: Container(
           padding: EdgeInsets.all(15.0),
           child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
             Padding(
               padding: EdgeInsets.only(bottom: 15.0),
               child: Text("Your Calling Stats",
                   textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle1),
             ),
             Text("Stats place holder chart"),
             // DonutPieChart.withSampleData(),
             Row(mainAxisAlignment: MainAxisAlignment.end, children: [
               OutlineButton(child: Text("Go to Stats Page"), onPressed: (){
                 // Navigator.of(context).push(MaterialPageRoute(builder: (context) => AnalyticsPage()));
               },)
             ])

           ])));
  }
}
