import 'package:flutter/material.dart';
import 'package:auto_call/services/phone_list.dart';

class AfterCallPrompt extends StatelessWidget {
  final Person person;

  AfterCallPrompt({this.person});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: new Text("Call Completed"),
        content: new Column(children: [
          Text("Record a comment about the call"),
          TextFormField(
            initialValue: person.note,
            autofocus: false,
            onChanged: (String text) {
              person.note = text;
            },
            decoration: InputDecoration(
//              hintStyle: calledTextColor(context, fileManager.phoneList.people[i].called),
//              labelStyle: calledTextColor(context, fileManager.phoneList.people[i].called),
                border: InputBorder.none,
                hintText: '..........'),
          ),
        ]),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]);
  }
}