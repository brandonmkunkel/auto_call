import 'package:flutter/material.dart';
import 'package:auto_call/pages/home.dart';
import 'package:auto_call/pages/file_selector.dart';
import 'package:auto_call/pages/call_session.dart';
import 'package:auto_call/pages/old_calls.dart';
import 'package:auto_call/pages/settings.dart';
import 'package:auto_call/pages/about.dart';
import 'package:auto_call/pages/legal.dart';

class AppDrawer extends StatelessWidget {
//  final List menuItems = [
//    [Icons.home, HomePage],
//    [Icons.note_add, FileSelectorPage],
//    [Icons.cloud_upload, CallQueuePage],
//    [Icons.cloud_upload, CallQueuePage2],
//    [Icons.history, OldCallsPage],
//    [Icons.settings, SettingsPage],
//    [Icons.info, AboutPage],
//  ];

  // const AppDrawer(BuildContext context);

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
//          ListTile(
//            title: Text('Splash', textScaleFactor: textScale),
//            onTap: () => navigatorUpdate(context, Splash.routeName),
//          ),
//          ListTile(
//            title: Text('Welcome', textScaleFactor: textScale),
//            onTap: () => navigatorUpdate(context, WelcomePage.routeName),
//          ),

                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, HomePage.routeName),
                ),
//        ListTile(
//          leading: Icon(Icons.note_add),
//          title: Text('File Selector', style: Theme.of(context).textTheme.subtitle1),
//          onTap: () => navigatorUpdate(context, FileSelectorPage.routeName),
//        ),
//        ListTile(
//          leading: Icon(Icons.cloud_upload),
//          title: Text('Call Session', style: Theme.of(context).textTheme.subtitle1),
//          onTap: () => navigatorUpdate(context, CallSessionPage.routeName),
//        ),
//        ListTile(
//          leading: Icon(Icons.history),
//          title: Text('Call Page', style: Theme.of(context).textTheme.subtitle1),
//          onTap: () => navigatorUpdate(context, CallPage.routeName),
//        ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Old Calls', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, OldCallsPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, SettingsPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, AboutPage.routeName),
                ),
                Divider(),
                Expanded(
                  flex: 1,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ListTile(
                        title: Text('Copyright 2020 | Brandon Kunkel', textAlign: TextAlign.center),
                        onTap: () => navigatorUpdate(context, LegalPage.routeName),
                      )),
                ),
              ],
            )));
  }

  void navigatorUpdate(BuildContext context, String desiredRoute) {

    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    // Push the selected route if it is not the current path
    Navigator.of(context).pushNamedAndRemoveUntil(
        desiredRoute, (route) {
      print("selected route: $desiredRoute, route.isCurrent ${route.isCurrent} : route name: ${route.settings.name}");
      print("condition ${route.isCurrent && route.settings.name == desiredRoute ? false : true}");
      return route.isCurrent && route.settings.name == desiredRoute ? false : true;
    }
    );
  }
}
