import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:auto_call/pages/onboarding.dart';
import 'package:auto_call/pages/login.dart';

import 'package:auto_call/pages/past_sessions.dart';
import 'package:auto_call/pages/contacts.dart';
import 'package:auto_call/pages/account.dart';
import 'package:auto_call/pages/settings.dart';

import 'package:auto_call/ui/terms.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;

    return Drawer(
        child: Container(
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  // onDetailsPressed: () { Navigator.of(context).pushNamed(AccountPage.routeName); },

                  currentAccountPicture: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text("Auto Call", style: textStyle)),
                  // currentAccountPicture: IconButton(
                  //   padding: EdgeInsets.all(0),
                  //   iconSize: 50,
                  //     icon: Icon(Icons.account_circle, color: Theme.of(context).buttonColor),
                  // onPressed: () {
                  //       Navigator.of(context).popAndPushNamed(AccountPage.routeName);
                  // } ,),

                  otherAccountsPictures: [
                    // FlatButton.icon(
                    //   icon: Icon(Icons.logout),
                    //   label: Text('Sign Out', style: Theme.of(context).textTheme.subtitle1),
                    //   onPressed: () async {
                    //     await _auth.signOut();
                    //     Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (route) => false);
                    //   },
                    // ),
                    // FlatButton(child: Text('Sign Out', style: Theme.of(context).textTheme.subtitle1), onPressed: () async {
                    //   await _auth.signOut();
                    //   Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (route) => false);
                    // },),
                    IconButton(icon: Icon(Icons.settings, color: Theme.of(context).primaryTextTheme.bodyText1.color), onPressed: (){
                      Navigator.of(context).popAndPushNamed(SettingsPage.routeName);
                    },)
                  ],

                  accountName: Text("User: ${_auth.currentUser.displayName ?? ""}", style: Theme.of(context).primaryTextTheme.bodyText1,),
                  accountEmail: Text("Email: ${_auth.currentUser.email}", style: Theme.of(context).primaryTextTheme.bodyText2),
                ),
                ListTile(
                  leading: Icon(Icons.auto_awesome),
                  title: Text('Onboarding', style: textStyle),
                  onTap: () => navigateTo(context, OnboardingPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login', style: textStyle),
                  onTap: () => navigateTo(context, LoginPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Past Sessions', style: textStyle),
                  onTap: () => navigateTo(context, PastSessionsPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.contact_page),
                  title: Text('Contacts', style: textStyle),
                  onTap: () => navigateTo(context, ContactsPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Account', style: textStyle),
                  onTap: () => navigateTo(context, AccountPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings', style: textStyle),
                  onTap: () => navigateTo(context, SettingsPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out', style: textStyle),
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (route) => false);
                  },
                ),
                Divider(),
                Expanded(child: Align(alignment: Alignment.bottomCenter, child: ListTile(title: autoCallCopyright()))),
              ],
            )));
  }

  void navigateTo(BuildContext context, String desiredRoute) {
    Navigator.of(context).pushNamed(desiredRoute);
  }
}
