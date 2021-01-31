import 'package:flutter/material.dart';
import 'package:auto_call/pages/home.dart';
import 'package:auto_call/pages/past_sessions.dart';
import 'package:auto_call/pages/settings.dart';
import 'package:auto_call/pages/legal.dart';
import 'package:auto_call/pages/onboarding.dart';
import 'package:auto_call/pages/login.dart';
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
                  leading: Icon(Icons.account_circle),
                  title: Text('Onboarding', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, OnboardingPage.routeName),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Login', style: Theme.of(context).textTheme.subtitle1),
                  onTap: () => navigatorUpdate(context, LoginPage.routeName),
                ),
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
                  onTap: () => navigatorUpdate(context, PastSessionsPage.routeName),
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
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    // Push the selected route if it is not the current path
    Navigator.of(context).pushNamedAndRemoveUntil(desiredRoute, (route) {
      print("selected route: $desiredRoute, route.isCurrent ${route.isCurrent} : route name: ${route.settings.name}");
      print("condition ${route.isCurrent && route.settings.name == desiredRoute ? false : true}");
      return route.isCurrent && route.settings.name == desiredRoute ? false : true;
    });
  }
}
