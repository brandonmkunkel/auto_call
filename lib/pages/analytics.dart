import 'package:auto_call/pages/upgrade.dart';
import 'package:auto_call/services/settings_manager.dart';
import 'package:auto_call/ui/charts/homepage_charts.dart';
import 'package:flutter/material.dart';
import 'package:auto_call/ui/charts/call_breakdown.dart';

class AnalyticsPage extends StatefulWidget {
  static const String routeName = "/analytics";
  final String title = "Analytics";

  @override
  AnalyticsState createState() => new AnalyticsState();
}

class AnalyticsState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: UpgradePromptWidget(
              requiredAccountType: AccountType.premium,
              featureName: "contact tracking",
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                child: ListTile(
                    title: Text(
                  "Analytics coming soon!",
                  textAlign: TextAlign.center,
                )),
              )),
        ));
  }
}
