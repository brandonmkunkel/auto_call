import 'package:flutter/material.dart';

import 'package:auto_call/services/settings_manager.dart';

class ActiveCallSessionCard extends StatefulWidget {
  @override
  ActiveCallSessionCardState createState() => new ActiveCallSessionCardState();
}

class ActiveCallSessionCardState extends State<ActiveCallSessionCard> {
  bool deletedCallSession = false;

  @override
  Widget build(BuildContext context) {
    bool activeCallSession = globalSettingManager.getSetting("activeCallSession");

    return !activeCallSession
        ? deletedCallSession
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Text(
                      "Deleted Last Call Session",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: Theme.of(context).textTheme.subtitle1.fontSize),
                    ),
                  ),
                ),
              ])
            : Container()
        : Card(
            child: Container(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: Text("Incomplete Call Session",
                        textAlign: TextAlign.left, style: Theme.of(context).textTheme.subtitle1),
                  ),
                  Text("You have an active call session, would you like to continue where you left off?"),
                  Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                  Row(
                    children: [
                      Spacer(flex: 3),
                      RaisedButton(
                        child: Text("No"),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            deletedCallSession = true;
                            globalSettingManager.setSetting("activeCallSession", false);
                          });
                        }
                      ),
                      Spacer(flex: 1),
                      RaisedButton(
                        child: Text("Yes"),
                        color: Colors.greenAccent,
                        onPressed: () {
                          // Load old call session
                          // Navigator.popAndPushNamed(
                          //   context,
                          //   CallSessionPage.routeName,
                          //   arguments: FileManager(_paths[0].path),
                          // );
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
