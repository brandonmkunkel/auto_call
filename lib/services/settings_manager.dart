import 'package:shared_preferences/shared_preferences.dart';

// Enumerator for describing setting access
enum SettingType { hidden, free, premium, enterprise }

// Setting class used in Map
class Setting {
  Setting({this.text, this.description, this.type, this.settingType});

  final String text;
  final String description;
  final SettingType settingType;
  final Type type;
  var value;

  String toString() {
    return "Setting(text: $text, description: $description, type: $type, settingType: $settingType, value: $value)";
  }
}

///
/// Setting Manager takes care of most of the work around saving/loading settings
///
class SettingManager {
  static SharedPreferences prefs;

  /// Asynchronous init function for calling in at app start up
  Future init() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();

      // SharedPreferences.setMockInitialValues()

      // Load the settings
      loadSettings();
      loaded = true;
    }
  }
  
  // Class attributes
  bool loaded = false;

  static final Map<String, Setting> settings = {
    // Hidden Settings
    "activeCallSession": Setting(type: bool, settingType: SettingType.hidden),
    "activeCallSessionPath": Setting(type: String, settingType: SettingType.hidden),

    // Visible Settings
    "userOnboarded": Setting(text: "Has user completed onboarding", type: bool, settingType: SettingType.free),
    "agreedToTerms": Setting(text: "Has user agreed to terms and conditions", type: bool, settingType: SettingType.free),
//    SettingPair(key: "tableLoadPrompt", text: "Edit Table after loading", type: bool, settingType: SettingType.free),

    "showNotes": Setting(text: "Show Call Note and Result Columns", type: bool, settingType: SettingType.free),
    "postCallPrompt": Setting(text: "Prompt on call completion", type: bool, settingType: SettingType.free),
    "oneTouchCall": Setting(text: "One Touch Call", type: bool, settingType: SettingType.free),
    "isPremium": Setting(text: "Is the user a premium user", type: bool, settingType: SettingType.free),
    // "isEnterprise": Setting(text: "Is the user an enterprise user", type: bool, settingType: SettingType.free),

    // Premium Settings
    "darkMode": Setting(text: "Dark Mode", type: bool, settingType: SettingType.premium),
    "additionalColumns": Setting(text: "Additional Table Columns", type: bool, settingType: SettingType.premium),
    "editColumns": Setting(text: "Edit Additional Table Columns", type: bool, settingType: SettingType.premium),
    "autoCall": Setting(text: "Automatically Call Next Person", type: bool, settingType: SettingType.premium),
  };

  ///
  /// Start up functions
  ///
  void loadSettings() {
    settings.forEach((key, setting) {
      if (setting.type == bool) {
        setting.value = prefs.getBool(key) ?? false;
      } else if (setting.type == int) {
        setting.value = prefs.getInt(key);
      } else if (setting.type == String) {
        setting.value = prefs.getString(key) ?? "";
      } else {
        ArgumentError("SettingManager.loadSettings(), something went wrong when loading $key");
      }
    });
  }

  // Return Standard Settings
  Map<String, Setting> standardSettings() => getSettings(SettingType.free);

  // Return Premium Settings
  Map<String, Setting> premiumSettings() => getSettings(SettingType.premium);

  // Return Enterprise Settings
  Map<String, Setting> enterpriseSettings() => getSettings(SettingType.enterprise);

  // Return settings with given enumerator
  Map<String, Setting> getSettings(SettingType settingType) {
    return Map.from(settings)..removeWhere((key, value) => value.settingType != settingType);
  }

  ///
  /// Access to the function at startup
  ///
  void printSettings() {
    print("Normal Settings");
    standardSettings().forEach((String key, Setting value) => print(value.toString()));

    print("Premium Settings");
    premiumSettings().forEach((String key, Setting value) => print(value.toString()));
  }

  List<Setting> getSettingList(SettingType settingType) {
    return getSettings(settingType).entries.map((e) => e.value).toList();
  }

  // Check to see if the user is premium
  bool isPremium() => prefs.getBool("isPremium") ?? false;
  bool isEnterprise() => prefs.getBool("isEnterprise") ?? false;

  dynamic get(String key) {
    if (!settings.containsKey(key)) {
      print("SettingManager.getSetting() can't access setting named '$key'");
    }
    Setting setting = settings[key];

    if (setting.type == bool) {
      return prefs.getBool(key) ?? false;
    } else if (setting.type == int) {
      return prefs.getInt(key) ?? 0;
    } else if (setting.type == String) {
      return prefs.getString(key) ?? "";
    }
  }

  void set(String key, dynamic value) async {
    if (!settings.containsKey(key)) {
      ArgumentError("SettingManager.setSetting() can't access setting named '$key'");
    }

    Setting setting = settings[key];

    // Update the setting object
    setting.value = value;

    // Update setting in shared_preferences
    if (setting.type == bool) {
      await prefs.setBool(key, value);
    } else if (setting.type == int) {
      await prefs.setInt(key, value);
    } else if (setting.type == String) {
      await prefs.setString(key, value);
    }
  }
}

// Single global instance of SettingManager
final SettingManager globalSettingManager = SettingManager(); 
