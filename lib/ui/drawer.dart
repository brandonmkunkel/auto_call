import 'package:flutter/material.dart';

import 'package:auto_call/pages/onboarding.dart';
import 'package:auto_call/pages/login.dart';

import 'package:auto_call/pages/past_sessions.dart';
import 'package:auto_call/pages/contacts.dart';
import 'package:auto_call/pages/account.dart';
import 'package:auto_call/pages/settings.dart';

import 'package:auto_call/ui/terms.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DrawerHeader(
                  child: Center(child: Text('AutoCall', textScaleFactor: 1.5, style: TextStyle(color: Colors.white))),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                ),
                ListTile(
                  leading: Icon(Icons.auto_awesome),
                  title: Text('Onboarding', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, OnboardingPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, LoginPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Past Sessions', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, PastSessionsPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.contact_page),
                  title: Text('Contacts', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, ContactsPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Account', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, AccountPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, SettingsPage.routeName),
                ),
                Divider(),
                Expanded(child: Align(alignment: Alignment.bottomCenter, child: ListTile(title: autoCallCopyright()))),
              ],
            )));
  }

  void navigatorUpdate(BuildContext context, String desiredRoute) {
    Navigator.of(context).pushNamed(desiredRoute);
  }
}
