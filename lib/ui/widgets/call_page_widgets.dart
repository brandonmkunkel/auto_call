import 'package:auto_call/services/settings_manager.dart';
import 'package:flutter/material.dart';

import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/pages/settings.dart';

class SaveButton extends StatelessWidget {
  final FileManager fileManager;
  final PhoneList phoneList;
  SaveButton({Key key, @required this.fileManager, @required this.phoneList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return fileManager == null
      ? Container()
      : IconButton(
      icon: Icon(Icons.save),
      onPressed: () async {
        bool acceptSave = await showDialog(barrierDismissible: false, context: context, builder: (_) => SaveAlert());

        if (acceptSave) {
          await fileManager.saveCallSession(phoneList);

          // Find the Scaffold in the widget tree and use it to show a SnackBar which tells the user that the
          // Call session was saved
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("File saved to " + await FileManager.savedFilePath(fileManager.path)),
            backgroundColor: Colors.grey[600],
            behavior: SnackBarBehavior.floating
          ));
        }
      },
    );
  }
}

class CallCloseButton extends StatelessWidget {
  final FileManager fileManager;
  final PhoneList phoneList;
  CallCloseButton({Key key, @required this.fileManager, @required this.phoneList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.cancel),
      onPressed: () async {
        bool acceptClose = await showDialog(
            barrierDismissible: false, context: context, builder: (BuildContext context) => CloseAlert());

        if (acceptClose) {
         bool acceptSave = await showDialog(
             barrierDismissible: false, context: context, builder: (BuildContext context) => SaveAlert());

         await fileManager.saveCallSession(phoneList);

         // Find the Scaffold in the widget tree and use it to show a SnackBar which tells the user that the
         // Call session was saved
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text("File saved to " + await FileManager.savedFilePath(fileManager.path)),
             backgroundColor: Colors.grey[600],
             behavior: SnackBarBehavior.floating
         ));

          globalSettingManager.set("activeCallSession", acceptSave);
          globalSettingManager.set("activeCallSessionPath", acceptSave ? await FileManager.savedFilePath(fileManager.path) : "");
          Navigator.of(context).pop();
        }
      },
    );
  }
}

class CallSettingsButton extends StatelessWidget {
  CallSettingsButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage()));
        });
  }
}

class CloseAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Call Session Close Alert"),
      content: Text("Are you sure you want end your call session?"),
      actions: <Widget>[
        TextButton(child: Text("No"), onPressed: () => Navigator.of(context).pop(false), style: TextButton.styleFrom(
          primary: Theme.of(context).textTheme.bodyText1.color, // foreground
        )
        ),
        TextButton(child: Text("Yes"), onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(
          primary: Theme.of(context).textTheme.bodyText1.color, // foreground
        ))
      ],
    );
  }
}

class SaveAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Save Call Session"),
      content: Text("Do you wish to save your call session?"),
      actions: <Widget>[
        TextButton(child: Text("No"), onPressed: () => Navigator.of(context).pop(false), style: TextButton.styleFrom(
          primary: Theme.of(context).textTheme.bodyText1.color, // foreground
        )),
        TextButton(child: Text("Yes"), onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(
          primary: Theme.of(context).textTheme.bodyText1.color, // foreground
        ))
      ],
    );
  }
}
