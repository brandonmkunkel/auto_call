import 'package:flutter/material.dart';

import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/call_session_widget.dart';
import 'package:auto_call/ui/prompts/post_session_prompt.dart';
import 'package:auto_call/ui/prompts/pre_session_prompt.dart';
import 'package:auto_call/services/settings_manager.dart';

class CallSessionPage extends StatefulWidget {
  static const String routeName = "/call_session";
  final String title = "Call Session";
  final FileManager fileManager;

  CallSessionPage({Key key, @required this.fileManager}) : super(key: key);

  @override
  CallSessionPageState createState() => new CallSessionPageState();
}

class CallSessionPageState extends State<CallSessionPage> {
  // Getter for file manager from widget parent
  FileManager get fileManager => widget.fileManager;

  // Helpful Settings Getters
  bool get editColumnsEnabled => globalSettingManager.isPremium() ? globalSettingManager.get("editColumns") : false;

  @override
  void initState() {
    // Get settings for this page from the SettingsManager
    super.initState();
  }

  Future<PhoneList> readFile() async {
    return await fileManager.readFile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: readFile(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Icon(Icons.error_outline, color: Colors.red, size: 50.0),
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ))
            ]);
          }

          return snapshot.connectionState == ConnectionState.done
              ? CallSessionWidget(fileManager: widget.fileManager, phoneList: snapshot.data)
              : Scaffold(
                  drawer: AppDrawer(),
                  appBar: AppBar(title: Text(widget.title), automaticallyImplyLeading: true),
                  body: Center(
                    child: Column(children: [
                      Text("Processing Call Table", style: Theme.of(context).textTheme.headline6),
                      SizedBox(width: 50.0, height: 50.0, child: const CircularProgressIndicator())
                    ]),
                  ));
        });
  }
}
