import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:auto_call/services/settings_manager.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

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
  AccountType accountType;

  // Turn the account levle into a string
  String get accountLevelString => accountType.toString().split(".")[1];

  String get accountLevelDescriptor => "${accountLevelString[0].toUpperCase()}${accountLevelString.substring(1)}";

  // Reauth the user, used for deleting account
  // static Future<void> reauthCurrentUser(String password) async {
  //   User currentUser = _auth.currentUser;
  //   UserCredential result = await currentUser.reauthenticateWithCredential(
  //       EmailAuthProvider.credential(email: currentUser.email, password: password));
  // }

  @override
  Widget build(BuildContext context) {
    // Store account type
    accountType = AccountType.values[globalSettingManager.get("accountLevel")];

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            FlatButton(
              onPressed: () async {
                await _auth.signOut();

                // Pop all routes and then push the login page
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
              },
              child: Text("Sign Out", style: TextStyle(color: Theme.of(context).primaryTextTheme.button.color)),
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            // _auth.currentUser.emailVerified
            //     ? Card(
            //         child: ListTile(
            //           title: Text("Email Verified"),
            //           trailing: Icon(Icons.check),
            //         ),
            //       )
            //     : Card(
            //         child: ListTile(
            //         title: Text("Email Verification incomplete"),
            //         trailing: RaisedButton(
            //           child: Text("Resend Verification Email"),
            //           onPressed: () {
            //             _auth.currentUser.sendEmailVerification();
            //           },
            //         ),
            //       )),

            Card(
              child: ListTile(
                title: Text("Account Level: ${this.accountLevelDescriptor}"),
                trailing: RaisedButton(
                  child: Text(
                    "Update",
                    style: Theme.of(context).primaryTextTheme.button,
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    // Navigator.of(context).push()
                  },
                ),
                enabled: true,
              ),
            ),

            Card(
              child: Column(
                children: [
                  ListTile(title: Text("User ID: "), trailing: Text("${_auth.currentUser.uid}")),
                  ListTile(title: Text("Username: "), trailing: Text("${_auth.currentUser.displayName ?? ""}")),
                  ListTile(title: Text("Email"), trailing: Text("${_auth.currentUser.email}")),
                  ListTile(title: Text("Password"), trailing: Text("*" * 8)),
                  ListTile(title: Text("Phone Number"), trailing: Text("${_auth.currentUser.phoneNumber ?? ""}")),
                ],
              ),
            ),

            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Organization")),
                  ListTile(title: Text("Team ID")),
                  ListTile(title: Text("Team Role")),
                  ListTile(
                    trailing: RaisedButton(child: Text("Leave Organization")),
                  )
                ],
              ),
            ),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Delete Account",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () async {
                      await showDialog(context: context, builder: (context) => DeleteAccountDialog());
                    },
                    onLongPress: () {},
                  )
                ],
              ),
            ),
          ],
        ))

        // floatingActionButton: FloatingActionButton.extended(
        //   label: Text(accountChanged ? "Save Changes" : "Exit"),
        //   icon: Icon(accountChanged ? Icons.save : Icons.close_rounded),
        //   backgroundColor: accountChanged ? Colors.green : Colors.red,
        //   onPressed: () async {
        //     if (accountChanged) {
        //
        //     }
        //
        //     Navigator.of(context).pop();
        //   },
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
  }
}

class DeleteAccountDialog extends StatefulWidget {
  @override
  DeleteAccountState createState() => DeleteAccountState();
}

class DeleteAccountState extends State<DeleteAccountDialog> {
  String userPassword = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Delete User Account",
        style: Theme.of(context).textTheme.headline6,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child:
                  Text("This will permanently delete your account and cannot be undone.", textAlign: TextAlign.left)),
          // Container(
          //     padding: EdgeInsets.symmetric(vertical: 15),
          //     child: Column(
          //       children: [
          //         Text("Re-enter password"),
          //         TextField(
          //           obscureText: true,
          //         )
          //       ],
          //     )),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            FlatButton(
              child: Text("Cancel", style: Theme.of(context).primaryTextTheme.button),
              color: Colors.grey,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Spacer(),
            FlatButton(
              child: Text("Delete My Account", style: Theme.of(context).primaryTextTheme.button),
              color: Colors.red,
              onPressed: () async {
                try {
                  await _auth.currentUser.delete();

                  // Pop all routes and then push the login page
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
                } catch (e) {
                  print(e);
                  // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Error deleting account ${e.toString()}")));
                }
              },
            ),
          ])
        ],
      ),
    );
  }
}
