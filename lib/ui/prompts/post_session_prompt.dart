import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:auto_call/services/file_io.dart';

class PostSessionPrompt extends StatefulWidget {
  final FileManager fileManager;

  PostSessionPrompt({Key key, @required this.fileManager}) : super(key: key);

  @override
  PostSessionPromptState createState() => new PostSessionPromptState();
}

class PostSessionPromptState extends State<PostSessionPrompt> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor.withOpacity(0.9)),
        child: SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
            titlePadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            title: GestureDetector(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[Text("Call Session Completed"), Divider()],
            )),
            children: [
              Column(children: <Widget>[
                GestureDetector(
                  child: Column(children: <Widget>[
                    Text("Some stuff will go here eventually\n"),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RaisedButton(child: Text("Done"), onPressed: () {
//                        widget.fileManager.phoneList.iterator = 0;
//                        widget.fileManager.phoneList.people.forEach((person) {
//                          person.called = false;
//                        });

                        // Pop the Dialog off of the screen
                        Navigator.of(context).pop();
                      }),
                    )
                  ]),
                )
              ])
            ]));
  }
}
