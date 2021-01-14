import 'package:flutter/material.dart';

import 'package:auto_call/services/settings_manager.dart';

/// Boolean Settings Widget
class BoolSettingsWidget extends StatefulWidget {
  final String settingKey;
  final Setting setting;

  BoolSettingsWidget({Key key, @required this.settingKey, @required this.setting});

  @override
  BoolSettingsState createState() => new BoolSettingsState();
}

class BoolSettingsState extends State<BoolSettingsWidget> {
  Setting setting;

  @override
  void initState() {
    setting = widget.setting;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.setting.text),
      trailing: Switch(
        value: widget.setting.value,
        onChanged: (bool value) {
          setState(() {
            globalSettingManager.set(widget.settingKey, value);
          });
        },
      ),
    );
  }
}
