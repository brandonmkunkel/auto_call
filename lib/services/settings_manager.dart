import 'package:flutter/material.dart';

class SettingPair {
  SettingPair({this.key,this.text,this.type});

  final String key;
  final String text;
  final Type type;
  Function(BuildContext) fcn;
}

class Setting {
  Setting({this.settingPair, this.value});

  final SettingPair settingPair;
  var value;

}

class SettingManager {
  List<SettingPair> settingPairs = <SettingPair>[
  SettingPair(key: "splashed", text: "Has user opened app before", type: bool),
  SettingPair(key: "welcomed", text: "Has user completed welcoming", type: bool),
  SettingPair(key: "_comment_prompt", text: "Post-Call Comment Prompt", type: bool),
  SettingPair(key: "_dark_mode", text: "Dark Mode", type: bool),
  ];

  List<Setting> appSettings;
//  List<Setting> lastSettings;

//  void applySettingUpdates(BuildContext context) {
//    bool changed = false;
//    for (int idx=0; idx<appSettings.length; idx++) {
//      if (appSettings[idx].value != lastSettings[idx].value) {
//        changed = true;
//
//        appSettings[idx].settingPair.fcn(context);
//      }
//    }
//
//    // Move the current state to last, for checking next time
//    lastSettings = changed ? appSettings : lastSettings;
//  }
}