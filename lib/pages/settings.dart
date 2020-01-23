import 'package:flutter/material.dart';
import 'package:auto_call/ui/drawer.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  static String routeName = "/Settings";
  final String title = "Settings";

  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingPair {
  const SettingPair({this.key, this.text, this.type});

  final String key;
  final String text;
  final Type type;
}

class Setting {
  Setting({this.settingPair, this.value});

  final SettingPair settingPair;
  var value;
}

class SettingsPageState extends State<SettingsPage> {
  static SharedPreferences prefs;
  static List<SettingPair> settingPairs = <SettingPair>[
    SettingPair(key: "splashed", text: "Has user opened app before", type: bool),
    SettingPair(key: "welcomed", text: "Has user completed welcoming", type: bool),
    SettingPair(key: "_notifications", text: "Receive Push Notifications", type: bool),
  ];
  static List<Setting> appSettings;

  Future<SharedPreferences> loadSettings() async {
    // Pull the Settings from teh SharedPreferences file into the SettingsState
    return await SharedPreferences.getInstance();
  }

  Future<List<Setting>> loadCreateSettingList() async {
    // Pull the Settings from teh SharedPreferences file into the SettingsState
    prefs = await SharedPreferences.getInstance();
    return List.generate(settingPairs.length, storeSetting);
  }

  Setting storeSetting(int idx) {
    return Setting(
        settingPair: settingPairs[idx],
        value: prefs.getBool(settingPairs[idx].key) ?? false);
  }

  void updateSettings() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Load Settings then re-update the state of the Settings Page
    loadCreateSettingList().then((List<Setting> _appSettings) {
      appSettings = _appSettings;
      setState(() {});
    });
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
          buildScrollableSettings(context),
        ]));
  }

  Widget buildSettingWidget(int idx) {
    switch (appSettings[idx].settingPair.type) {
      case bool:
        {
          return CheckboxListTile(
            value: appSettings[idx].value,
            title: Text(appSettings[idx].settingPair.text),
            onChanged: (bool value) {
              setState(() {
                appSettings[idx].value = value;
                prefs.setBool(appSettings[idx].settingPair.key, value);
              });
            },
          );
        }
      case int:  {
        return Container();
      }
    }
  }

  Widget buildScrollableSettings(BuildContext context) {
    if (appSettings != null) {
      // Check to see if the App Settings have loaded yet
      return new Scrollbar(
        child: new ListView(
          children:
              List<Widget>.generate(settingPairs.length, buildSettingWidget),
        ),
      );
    } else {
      // If not, leave blank
      return Container();
    }

//    return new Scrollbar(
//        child: new LayoutBuilder(
//          builder: (BuildContext context, BoxConstraints viewportConstraints) {
//            return SingleChildScrollView(
//              scrollDirection: Axis.vertical,
//              child: ConstrainedBox(
//                constraints: BoxConstraints(
//                  minHeight: viewportConstraints.maxHeight,
//                  minWidth: viewportConstraints.maxWidth,
//                  maxWidth: viewportConstraints.maxWidth,
//                ),
//                child: Column(
//                  children: <Widget>[
//                    Expanded(
//                        flex: 0,
//                        // A flexible child that will grow to fit the viewport but
//                        // still be at least as big as necessary to fit its contents.
//                        child: Column(
//                          children: List<Widget>.generate(
//                              settingPairs.length, buildSettingWidget),
//                        )),
//                  ],
//                ),
//              ),
//            );
//          },
//    ));
  }
}
