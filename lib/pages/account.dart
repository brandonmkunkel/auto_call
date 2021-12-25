import 'package:auto_call/classes/setting.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:auto_call/classes/settings_manager.dart';
import 'package:auto_call/pages/upgrade.dart';
import 'package:auto_call/pages/login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AccountPage extends StatefulWidget {
  static const String routeName = "/account";
  final String title = "Account Page";

  @override
  AccountPageState createState() => new AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final SettingManager manager = globalSettingManager;
  bool accountChanged = false;
  AccountType get accountType => globalSettingManager.accountType;

  // Turn the account level into a string
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
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            TextButton(
              child: Text("Sign Out"),
              style: TextButton.styleFrom(primary: Theme.of(context).primaryTextTheme.button?.color),
              onPressed: () async {
                await _auth.signOut();

                // Pop all routes and then push the login page
                Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (Route<dynamic> route) => false);
              },
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
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
              //         trailing: ElevatedButton(
              //           child: Text("Resend Verification Email"),
              //           onPressed: () {
              //             _auth.currentUser.sendEmailVerification();
              //           },
              //         ),
              //       )),

              AccountUpgradeCard(),

              Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10.0),
                child: Column(
                  children: [
                    ListTile(title: Text("User ID: "), trailing: Text("${_auth.currentUser?.uid}")),
                    ListTile(title: Text("Username: "), trailing: Text("${_auth.currentUser?.displayName}")),
                    ListTile(title: Text("Email"), trailing: Text("${_auth.currentUser?.email}")),
                    ListTile(title: Text("Password"), trailing: Text("*" * 8)),
                    ListTile(title: Text("Phone Number"), trailing: Text("${_auth.currentUser?.phoneNumber}")),
                  ],
                ),
              ),

              OrganizationStatusCard(),

              Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10.0),
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
                    )
                  ],
                ),
              ),
            ],
          )),
        )

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
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("This will permanently delete your account and cannot be undone.")),
          // Container(
          //   padding: EdgeInsets.symmetric(vertical: 10),
          //   child: Text("Please enter your account password to confirm", style: TextStyle(color: Colors.red)),
          // ),
          // Container(
          //     padding: EdgeInsets.symmetric(vertical: 10),
          //     child: TextField(
          //       obscureText: true,
          //       decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
          //     )),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            TextButton(
              child: Text("Cancel"),
              style: TextButton.styleFrom(primary: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Spacer(),
            TextButton(
              child: Text("Delete My Account"),
              style: TextButton.styleFrom(primary: Colors.red),
              onPressed: () async {
                try {
                  await _auth.currentUser?.delete();

                  // Pop all routes and then push the login page
                  Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (Route<dynamic> route) => false);
                } catch (e) {
                  print(e);
                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting account ${e.toString()}")));
                }
              },
            ),
          ])
        ],
      ),
    );
  }
}

class OrganizationStatusCard extends StatefulWidget {
  @override
  OrganizationStatusCardState createState() => OrganizationStatusCardState();
}

class OrganizationStatusCardState extends State<OrganizationStatusCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10.0),
      child: Column(
        children: [
          ListTile(title: Text("Organization"), trailing: Text("None")),
          ListTile(title: Text("Team ID"), trailing: Text("None")),
          ListTile(title: Text("Team Role"), trailing: Text("None")),
          ListTile(
            trailing: ElevatedButton(child: Text("Leave Organization"), onPressed: null),
          )
        ],
      ),
    );
  }
}

class AccountUpgradeCard extends StatefulWidget {
  @override
  AccountUpgradeCardState createState() => AccountUpgradeCardState();
}

class AccountUpgradeCardState extends State<AccountUpgradeCard> {
  AccountType get accountType => globalSettingManager.accountType;

  String get accountLevelString => accountType.toString().split(".")[1];

  String get accountLevelDescriptor => "${accountLevelString[0].toUpperCase()}${accountLevelString.substring(1)}";

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text("Account Level: ${this.accountLevelDescriptor}"),
        trailing: ElevatedButton(
          child: Text(
            accountType == AccountType.free ? "Upgrade" : "Change",
            style: Theme.of(context).primaryTextTheme.button,
          ),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () async {
            await Navigator.of(context).pushNamed(UpgradePage.routeName);
            setState(() {});
          },
        ),
        enabled: true,
      ),
    );
  }
}
