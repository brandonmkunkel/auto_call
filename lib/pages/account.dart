import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:auto_call/services/settings_manager.dart';

class AccountPage extends StatefulWidget {
  static const String routeName = "/account";
  final String title = "Account Page";
  final String label = "Account Page";

  @override
  AccountPageState createState() => new AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final SettingManager manager = globalSettingManager;
  bool accountChanged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
          padding: EdgeInsets.all(15.0),
          child: SizedBox.expand(
            child: Card(
              child: Center(
                child: Text("User Accounts Coming Soon!"),
              ),
            ),
          )),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(accountChanged ? "Save Changes" : "Exit"),
        icon: Icon(accountChanged ? Icons.save : Icons.close_rounded),
        backgroundColor: accountChanged ? Colors.green : Colors.red,
        onPressed: () async {
          if (accountChanged) {

          }

          Navigator.of(context).pop();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
