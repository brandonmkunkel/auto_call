import 'package:auto_call/services/settings_manager.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/services/phone_list.dart';

class PreSessionPrompt extends StatefulWidget {
  final FileManager fileManager;
  final PhoneList phoneList;

  PreSessionPrompt({Key key, @required this.fileManager, @required this.phoneList}) : super(key: key);

  @override
  PreSessionPromptState createState() => new PreSessionPromptState();
}

class PreSessionPromptState extends State<PreSessionPrompt> {
  List<bool> columns;

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
    bool editColumns = globalSettingManager.isPremium() ? globalSettingManager.get("editColumns") : false;

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
              children: <Widget>[Text("Select Table Columns"), Divider()],
            )),
            children: [
              Column(children: <Widget>[
                GestureDetector(
                  child: Column(children: <Widget>[
                    Text("The following supplementary labels were found in the loaded table"),
                    ListView.builder(itemBuilder: (context, idx) {
                      return ListTile(
                        leading: Checkbox(
                            value: true,
                            onChanged: (bool value) {
                              columns[idx] = value;
                            }),
                        title: Text(widget.phoneList.additionalLabels[idx]),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RaisedButton(
                          child: Text("Done"),
                          onPressed: () {
                            // Pop the Dialog off of the screen
                            Navigator.of(context).pop(columns);
                          }),
                    )
                  ]),
                )
              ])
            ]));
  }
}
