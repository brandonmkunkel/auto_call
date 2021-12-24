import 'package:flutter/material.dart';

import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/services/settings_manager.dart';

class PostSessionPrompt extends StatefulWidget {
  final FileManager fileManager;
  final PhoneList phoneList;

  PostSessionPrompt({Key key, @required this.fileManager, @required this.phoneList}) : super(key: key);

  @override
  PostSessionPromptState createState() => new PostSessionPromptState();
}

class PostSessionPromptState extends State<PostSessionPrompt> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor.withOpacity(0.9)),
        child: SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
            titlePadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            title: GestureDetector(
              child: Text("Call Session Completed"),
            ),
            children: [
              Column(children: <Widget>[
                GestureDetector(
                  child: Column(children: <Widget>[
                    Divider(),
                    Text("Some stuff will go here eventually\n"),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                          child: Text("Done"),
                          onPressed: () {
                            globalSettingManager.set("activeCallSession", false);
                            globalSettingManager.set("activeCallSessionPath", "");

                            Navigator.of(context).pop();
                          }),
                    )
                  ]),
                )
              ])
            ]));
  }
}
