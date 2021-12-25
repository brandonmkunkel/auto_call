// Enumerator for describing setting access
enum SettingType { hidden, free, premium, enterprise }
enum AccountType { free, premium, enterprise }

// Setting class used in Map
class Setting {
  Setting({required this.text, this.description, required this.type, required this.settingType});

  final String text;
  final String? description;
  final SettingType settingType;
  final Type type;
  var value;

  String toString() {
    return "Setting(text: $text, description: $description, type: $type, settingType: $settingType, value: $value)";
  }
}
