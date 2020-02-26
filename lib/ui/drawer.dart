import 'package:flutter/material.dart';
import 'package:auto_call/pages/home.dart';
import 'package:auto_call/pages/file_selector.dart';
import 'package:auto_call/pages/call_session.dart';
import 'package:auto_call/pages/old_calls.dart';
import 'package:auto_call/pages/contact_tracker.dart';
import 'package:auto_call/pages/settings.dart';
import 'package:auto_call/pages/about.dart';
import 'package:auto_call/pages/legal.dart';

class AppDrawer extends StatelessWidget {
  final double textScale = 1.5;

//  final List menuItems = [
//    [Icons.home, HomePage],
//    [Icons.note_add, FileSelectorPage],
//    [Icons.cloud_upload, CallQueuePage],
//    [Icons.cloud_upload, CallQueuePage2],
//    [Icons.history, OldCallsPage],
//    [Icons.settings, SettingsPage],
//    [Icons.info, AboutPage],
//  ];

  const AppDrawer(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: new Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new DrawerHeader(
          child: new Center(
              child: new Text('Your Favorite Robot Assistant',
                  textScaleFactor: 1.5, style: TextStyle(color: Colors.white))),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        ),
//          new ListTile(
//            title: new Text('Splash', textScaleFactor: textScale),
//            onTap: () {
//              navigatorUpdate(context, Splash.routeName);
//            },
//          ),
//          new ListTile(
//            title: new Text('Welcome', textScaleFactor: textScale),
//            onTap: () {
//              navigatorUpdate(context, WelcomePage.routeName);
//            },
//          ),

        new ListTile(
          leading: new Icon(Icons.home),
          title: new Text('Home', style: Theme.of(context).textTheme.title),
          onTap: () {
            navigatorUpdate(context, HomePage.routeName);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.note_add),
          title: new Text('File Selector', style: Theme.of(context).textTheme.title),
          onTap: () {
            navigatorUpdate(context, FileSelectorPage.routeName);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.cloud_upload),
          title: new Text('Call Queue', style: Theme.of(context).textTheme.title),
          onTap: () {
            navigatorUpdate(context, CallSessionPage.routeName);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.history),
          title: new Text('Old Calls', style: Theme.of(context).textTheme.title),
          onTap: () {
            navigatorUpdate(context, OldCallsPage.routeName);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.contacts),
          title: new Text('Contact Tracker', style: Theme.of(context).textTheme.title),
          onTap: () {
            navigatorUpdate(context, ContactTrackerPage.routeName);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.settings),
          title: new Text('Settings', style: Theme.of(context).textTheme.title),
          onTap: () {
            navigatorUpdate(context, SettingsPage.routeName);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.info),
          title: new Text('About', style: Theme.of(context).textTheme.title),
          onTap: () {
            navigatorUpdate(context, AboutPage.routeName);
          },
        ),
        new Divider(),
        new Expanded(
          flex: 1,
          child: new Align(
              alignment: Alignment.bottomCenter,
              child: new ListTile(
                title: new Text(
                  'Copyright 2020 | Brandon Kunkel',
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  navigatorUpdate(context, LegalPage.routeName);
                },
              )),
        ),
      ],
    ));
  }

  void navigatorUpdate(BuildContext context, String desiredRoute) {
    // Pop the drawer
    Navigator.of(context).pop();

    // Push the selected route if it is not the current path
    Navigator.of(context).pushNamedAndRemoveUntil(
        desiredRoute, (route) => route.isCurrent && route.settings.name == desiredRoute ? false : true);
  }
}
