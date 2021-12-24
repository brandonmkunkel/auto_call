import 'package:auto_call/ui/prompts/errors.dart';
import 'package:flutter/material.dart';

import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/ui/call_session_widget.dart';
import 'package:auto_call/ui/widgets/permission_widget.dart';
import 'package:auto_call/services/settings_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class CallSessionPage extends StatefulWidget {
  static const String routeName = "/call_session";
  final String title = "Call Session";
  final FileManager fileManager;

  CallSessionPage({Key key, @required this.fileManager}) : super(key: key);

  @override
  CallSessionPageState createState() => new CallSessionPageState();
}

class CallSessionPageState extends State<CallSessionPage> {
  Future<PhoneList> phoneListFuture;

  // Getter for file manager from widget parent
  FileManager get fileManager => widget.fileManager;

  // Helpful Settings Getters
  bool get editColumnsEnabled => globalSettingManager.isPremium() ? globalSettingManager.get("editColumns") : false;

  @override
  void initState() {
    // Get settings for this page from the SettingsManager
    super.initState();

    phoneListFuture = readFile();
  }

  Future<PhoneList> readFile() async {
    return await fileManager.readFile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: phoneListFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return GeneralErrorWidget(errorText: "Error loading Call Page with file", error: snapshot.error);
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return PermissionsWidget(
                requestedPermission: Permission.phone,
                child: CallSessionWidget(fileManager: widget.fileManager, phoneList: snapshot.data));
          }

          // If we are still waiting, use show a progress bar
          return Scaffold(
              appBar: AppBar(title: Text(widget.title)),
              body: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Processing Call Table", style: Theme.of(context).textTheme.headline6),
                  SizedBox(width: 50.0, height: 50.0, child: const CircularProgressIndicator())
                ]),
              ));
        });
  }
}
