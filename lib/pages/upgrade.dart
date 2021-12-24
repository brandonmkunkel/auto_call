import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_call/services/settings_manager.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class UpgradePage extends StatefulWidget {
  static const String routeName = "/upgrade";
  final String title = "Upgrade Account";

  @override
  UpgradePageState createState() => new UpgradePageState();
}

class UpgradePageState extends State<UpgradePage> {
  AccountType accountType;

  // Turn the account level into a string
  String get accountLevelString => accountType.toString().split(".")[1];

  String get accountLevelDescriptor => "${accountLevelString[0].toUpperCase()}${accountLevelString.substring(1)}";

  @override
  Widget build(BuildContext context) {
    accountType = AccountType.values[globalSettingManager.get("accountLevel")];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Card(
                child: Container(
                    padding: EdgeInsets.all(15.0),
                    child: Column(children: [
                      Text("This page will be updated in the future to accept in-app payments. \n\n"
                          "For the time being, enjoy a free upgrade of your choice :)"),
                    ]))),
            RadioListTile<AccountType>(
              title: const Text('Free'),
              value: AccountType.free,
              groupValue: accountType,
              onChanged: (AccountType value) {
                setState(() {
                  globalSettingManager.set("accountLevel", value.index);
                });
              },
            ),
            RadioListTile<AccountType>(
              title: const Text('Premium'),
              value: AccountType.premium,
              groupValue: accountType,
              onChanged: (AccountType value) {
                setState(() {
                  globalSettingManager.set("accountLevel", value.index);
                });
              },
            ),
            RadioListTile<AccountType>(
              title: const Text('Enterprise'),
              value: AccountType.enterprise,
              groupValue: accountType,
              onChanged: (AccountType value) {
                setState(() {
                  globalSettingManager.set("accountLevel", value.index);
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Complete"),
        icon: Icon(Icons.monetization_on),
        onPressed: () {
          setState(() {
            Navigator.pop(context);
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

///
/// Upgrade prompt which normalizes interface for gate-keeping access to different widgets
///
class UpgradePromptWidget extends StatefulWidget {
  final AccountType requiredAccountType;
  final String featureName;
  final Widget child;

  UpgradePromptWidget({@required this.requiredAccountType, @required this.featureName, @required this.child});

  @override
  UpgradePromptWidgetState createState() => new UpgradePromptWidgetState();
}

class UpgradePromptWidgetState extends State<UpgradePromptWidget> {
  // Turn the account level into a string
  String get accountLevelString => widget.requiredAccountType.toString().split(".")[1];

  String get accountLevelDescriptor => "${accountLevelString[0].toUpperCase()}${accountLevelString.substring(1)}";

  @override
  Widget build(BuildContext context) {
    return globalSettingManager.accountType.index >= widget.requiredAccountType.index
        ? widget.child
        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                child: Text(
                  "Free accounts do not have access to ${widget.featureName.toLowerCase()}",
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                child: Text(
                  "Only $accountLevelDescriptor accounts have access to this feature",
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                )),
            ElevatedButton(
                child: Text("Upgrade Account"),
                onPressed: () async {
                  await Navigator.of(context).pushNamed(UpgradePage.routeName);

                  setState(() {});
                })
          ]);
  }
}
