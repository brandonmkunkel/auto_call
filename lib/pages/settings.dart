import 'package:flutter/material.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/services/settings_manager.dart';

import 'dart:async';

class SettingsPage extends StatefulWidget {
  static String routeName = "/Settings";
  final String title = "Settings";
  final String label = "Settings";

  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  SettingManager manager = SettingManager();

  void loadManager() async {
    await manager.create();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadManager();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        drawer: AppDrawer(context),
        body: Stack(children: [
          buildSettings(context),
        ]));
  }

  Widget premiumSettingsLabel(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Spacer(),
        Icon(Icons.stars, color: manager.isPremium() ? Theme.of(context).accentColor : Colors.grey[500]),
        Spacer(),
        Text(
          manager.isPremium() ? "Premium Settings" : "Available Only for Premium Accounts",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: manager.isPremium() ? Theme.of(context).accentColor : Colors.grey[500],
              fontSize: Theme.of(context).primaryTextTheme.subhead.fontSize),
        ),
        Spacer(),
        Icon(Icons.stars, color: manager.isPremium() ? Theme.of(context).accentColor : Colors.grey[500]),
        Spacer(),
      ],
    );
  }

  Widget buildSettings(BuildContext context) {
    List<Setting> standardSettings = manager.getSettingList(false);
    List<Setting> premiumSettings = manager.getSettingList(true);

    if (standardSettings != null) {
      // Check to see if the App Settings have loaded yet
      return ListView(
        children: List<Widget>.generate(standardSettings.length, (int index) {
              return buildStandardSettingWidget(standardSettings, index);
            }) +
            [Divider(), premiumSettingsLabel(context)] +
            List<Widget>.generate(premiumSettings.length, (int index) {
              return buildPremiumSettingWidget(premiumSettings, index);
            }),
      );
    } else {
      // If not, leave blank
      return Container(
        child:
            Text("Settings have not loaded correctly, server may be down", style: Theme.of(context).textTheme.headline),
      );
    }
  }

  Widget buildStandardSettingWidget(List<Setting> settings, int idx) {
    switch (settings[idx].settingPair.type) {
      case bool:
        {
          return ListTile(
            title: Text(settings[idx].settingPair.text),
            trailing: Switch(
              value: settings[idx].value,
              onChanged: (bool value) {
                setState(() {
                  settings[idx].value = value;
                  manager.prefs.setBool(settings[idx].settingPair.key, value);
                });
              },
            ),
          );
        }
      case int:
        {
          return Container();
        }
    }
  }

  Widget buildPremiumSettingWidget(List<Setting> settings, int idx) {
    switch (settings[idx].settingPair.type) {
      case bool:
        {
          return ListTile(
            title: Text(settings[idx].settingPair.text,
                style: TextStyle(
                    color: !manager.isPremium() ? Colors.grey[500] : Theme.of(context).accentColor)),
            trailing: Switch(
              value: !manager.isPremium() ? false : settings[idx].value,
              onChanged: !manager.isPremium() ? (bool){} : (bool value) {
                setState(() {
                  settings[idx].value = value;
                  manager.prefs.setBool(settings[idx].settingPair.key, value);
                });
              },
            ),
          );
        }
      case int:
        {
          return Container();
        }
    }
  }
}
