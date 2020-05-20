import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Singleton setting manager for
SettingManager globalSettingManager = SettingManager();

//Future<void> loadGlobalSettings() async {
//  await globalSettingManager.loadSingleton();
//  print("done loading global settings");
//}

enum SettingType  {
  hidden,
  free,
  premium,
  enterprise
}

// Setting Classes used in the Setting Manager
class SettingPair {
  final String key;
  final String text;
  final String description;
  final Type type;
  final bool premium;
  Function(BuildContext) fcn;

  SettingPair({this.key, this.text, this.description, this.type, this.premium});

  String toString() {
    return "SettingPair(key: $key, text: $text, type: $type, premium: $premium)";
  }
}

class Setting {
  Setting({this.settingPair, this.value});

  final SettingPair settingPair;
  var value;

  String toString() {
    return "Setting(settingPair: ${settingPair.toString()}, value: ${value.toString()})";
  }
}

///
/// Setting Manager takes care of most of the work around saving/loading settings
///
class SettingManager {
//  // Treat the Setting Manager as a singleton, only one should exist
//  static final SettingManager _singleton = SettingManager.singleInstance();
//  factory SettingManager() => _singleton;
//  SettingManager.singleInstance() {
//    loadSingleton();
//    print("done loadSingleton");
//
//  }

//  SettingManager.load() {
//    loadSingleton();
//  }

  // Class attributes
  SharedPreferences prefs;
  Map<String, Setting> standardSettings;
  Map<String, Setting> premiumSettings;
  bool loaded=false;

  static final List<SettingPair> settingPairs = [
    // Standard Settings
//    SettingPair(key: "splashed", text: "Has user opened app before", type: bool, premium: false),
//    SettingPair(key: "welcomed", text: "Has user completed welcoming", type: bool, premium: false),
//    SettingPair(key: "registered", text: "Has user registered an account", type: bool, premium: false),
//    SettingPair(key: "table_load_prompt", text: "Edit Table after loading", type: bool, premium: false),

    SettingPair(key: "show_notes", text: "Show Call Note and Result Columns", type: bool, premium: false),
    SettingPair(key: "post_call_prompt", text: "Prompt on call completion", type: bool, premium: false),
    SettingPair(key: "one_touch_call", text: "One Touch Call", type: bool, premium: false),
    SettingPair(key: "is_premium", text: "Is the user a premium user", type: bool, premium: false),
//    SettingPair(key: "is_enterprise", text: "Is the user an enterprise user", type: bool, premium: false),

    // Premium Settings
    SettingPair(key: "dark_mode", text: "Dark Mode", type: bool, premium: true),
    SettingPair(key: "additional_columns", text: "Additional Table Columns", type: bool, premium: true),
    SettingPair(key: "edit_columns", text: "Edit Additional Table Columns", type: bool, premium: true),
    SettingPair(key: "auto_call", text: "Automatically Call Next Person", type: bool, premium: true),
//    SettingPair(key: "cloud_storage", text: "Cloud Storage", type: bool, premium: true),
//    SettingPair(key: "client_tracking", text: "Client Tracking", type: bool, premium: true),
  ];

  ///
  /// Start up functions
  ///
  void loadSingleton() {
    startPreferencesInstance().then((SharedPreferences _prefs) {
      prefs = _prefs;
      standardSettings = loadSettings(premium: false);
      premiumSettings = loadSettings(premium: true);
      loaded = true;
      print("_prefs loaded");
    });
  }

  void fromPrefs(SharedPreferences preferences) {
    prefs = preferences;
    standardSettings = loadSettings(premium: false);
    premiumSettings = loadSettings(premium: true);
    loaded = true;
  }

  Future<SharedPreferences> startPreferencesInstance() async {
    // Pull the Settings from teh SharedPreferences file into the SettingsState
    return await SharedPreferences.getInstance();
  }

  Map<String, Setting> loadSettings({bool premium = false}) {
    var _settings = Map<String, Setting>.fromIterable(settingPairs,
      key: (settingPair) => settingPair.key.toString() ,
      value: (settingPair) => settingPair.premium == premium
          ? Setting(settingPair: settingPair, value: prefs.getBool(settingPair.key) ?? false)
          : null
    );

    // Remove null entries
    _settings.removeWhere((key, value) => value==null);

    return _settings;
  }

  ///
  /// Access to the function at startup
  ///
  void printSettings() {
    print("Normal Settings");
    standardSettings.forEach((String key, Setting value) {
      print(value.toString());
    });

    print("Premium Settings");
    premiumSettings.forEach((String key, Setting value) {
      print(value.toString());
    });
  }

  Map<String, Setting> getSettingMap(bool premium) {
    return premium ? premiumSettings : standardSettings;
  }

  List<Setting> getSettingList(bool premium) {
    return getSettingMap(premium).entries.map((e) => e.value).toList();
  }

  bool isPremium() => prefs.getBool("is_premium") ?? false;

  Map<String, Setting> keyLookup(String key) {
    // Look up the Key in both settings and return which setting set it comes in
    return premiumSettings.containsKey(key) ? premiumSettings : standardSettings;
  }

  dynamic getSetting(String key) {
//    return keyLookup(key)[key].value;
    Setting setting = keyLookup(key)[key];

    if (setting.value.runtimeType == bool) {
      return prefs.getBool(key) ?? false;
    } else if (setting.value.runtimeType == int) {
      return prefs.getInt(key) ?? 0;
    } else if (setting.value.runtimeType == String) {
      return prefs.getString(key) ?? "";
    }
  }

  void setSetting(String key, dynamic value) async {
    Map<String, Setting> settingMap = keyLookup(key);

    // Store the value at the specified key
    settingMap[key].value = value;

    if (value.runtimeType == bool) {
      prefs.setBool(key, value);
    } else if (value.runtimeType == int) {
      prefs.setInt(key, value);
    } else if (value.runtimeType == String) {
      prefs.setString(key, value);
    }
  }
}

