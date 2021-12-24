import 'package:flutter/material.dart';

import 'package:auto_call/pages/call_page.dart';
import 'package:auto_call/pages/past_sessions.dart';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/services/settings_manager.dart';

class ActiveCallSessionCard extends StatefulWidget {
  @override
  ActiveCallSessionCardState createState() => new ActiveCallSessionCardState();
}

class ActiveCallSessionCardState extends State<ActiveCallSessionCard> {
  bool deletedCallSession = false;

  bool get activeCallSession => globalSettingManager.get("activeCallSession");
  String get activeCallSessionPath => globalSettingManager.get("activeCallSessionPath");
  bool get showActiveCallSession => activeCallSession && activeCallSessionPath.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return !showActiveCallSession
        ? deletedCallSession
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
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
            margin: EdgeInsets.symmetric(vertical: 5),
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
                      ElevatedButton(
                          child: Text("No"),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              deletedCallSession = true;

                              // Reset the cache for the past call session
                              globalSettingManager.set("activeCallSession", false);
                              globalSettingManager.set("activeCallSessionPath", "");
                            });
                          }),
                      Spacer(flex: 1),
                      ElevatedButton(
                        child: Text("Yes"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        onPressed: () async {
                          // Load old call session
                          String path = globalSettingManager.get("activeCallSessionPath") ?? "";

                          // If there is a file linked to the previous call session, open it up
                          if (path.isNotEmpty) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    CallSessionPage(fileManager: FileManager.fromFile(path, reuseDateTime: true))));
                          } else {
                            await showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (_) => AlertDialog(
                                      title: Text("Error Loading File"),
                                      content: Text("We couldn't find a valid old call session file to open. "
                                          "This file may be corrupted or lost, try searching within ${PastSessionsPage.label} instead"),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Close"),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.red,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(builder: (_) => PastSessionsPage()));
                                          },
                                          child: Text("Go to ${PastSessionsPage.label}"),
                                        )
                                      ],
                                    ));
                            globalSettingManager.set("activeCallSession", false);
                            globalSettingManager.set("activeCallSessionPath", "");
                          }
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
