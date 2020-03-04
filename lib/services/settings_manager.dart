import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPair {
  final String key;
  final String text;
  final Type type;
  final bool premium;
  Function(BuildContext) fcn;

  SettingPair({this.key, this.text, this.type, this.premium});
}

class Setting {
  Setting({this.settingPair, this.value});

  final SettingPair settingPair;
  var value;
}

class SettingManager {
  SharedPreferences prefs;
  static final List<SettingPair> standardPairs = [
    SettingPair(key: "splashed", text: "Has user opened app before", type: bool, premium: false),
    SettingPair(key: "welcomed", text: "Has user completed welcoming", type: bool, premium: false),
    SettingPair(key: "registered", text: "Has user registered an account", type: bool, premium: false),
    SettingPair(key: "comment_prompt", text: "Prompt on call completion", type: bool, premium: false),
    SettingPair(key: "one_touch_call", text: "One Touch Call", type: bool, premium: false),
    SettingPair(key: "is_premium", text: "Is the user a premium user", type: bool, premium: false),
  ];
  static final List<SettingPair> premiumPairs = [
    SettingPair(key: "dark_mode", text: "Dark Mode", type: bool, premium: true),
    SettingPair(key: "statistics", text: "Enable User statistics", type: bool, premium: true),
  ];

  List<Setting> standardSettings;
  List<Setting> premiumSettings;

  static Future<SharedPreferences> startPreferencesInstance() async {
    // Pull the Settings from teh SharedPreferences file into the SettingsState
    return await SharedPreferences.getInstance();
  }

  Future<List<Setting>> loadSettings({bool premium=false}) async {
    List pairs = premium ? premiumPairs : standardPairs;
    var _settings = List.generate(pairs.length, (int index) {
      return Setting(settingPair: pairs[index], value: prefs.getBool(pairs[index].key) ?? false);
    });
    print(_settings);
    return _settings;
  }

  Future<void> create() async {
    await startPreferencesInstance().then((SharedPreferences _prefs) async {
      prefs = _prefs;
      standardSettings = await loadSettings(premium: false);
      premiumSettings = await loadSettings(premium: true);
    });
  }

  void printSettings() {}

  List<Setting> getSettingList(bool premium) {
    return premium ? premiumSettings : standardSettings;
  }

  bool isPremium() {
    return prefs.getBool("is_premium") ?? false;
  }

  dynamic getSetting(String key) async {
    return true;
  }

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
