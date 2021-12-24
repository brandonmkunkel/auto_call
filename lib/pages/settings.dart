import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:auto_call/ui/terms.dart';
import 'package:auto_call/ui/theme.dart';
import 'package:auto_call/services/settings_manager.dart';

import 'account.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = "/settings";
  final String title = "Settings";

  SettingsPage({Key key}) : super(key: key);

  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final SettingManager manager = globalSettingManager;

  bool get isPremium => manager.isPremium();

  @override
  Widget build(BuildContext context) {
    Color accentColor = Theme.of(context).accentColor;
    // Color accentColor = Theme.of(context).floatingActionButtonTheme.backgroundColor;

    Map<String, Setting> hiddenSettings = globalSettingManager.hiddenSettings();
    Map<String, Setting> standardSettings = globalSettingManager.standardSettings();
    Map<String, Setting> premiumSettings = globalSettingManager.premiumSettings();
    Map<String, Setting> enterpriseSettings = globalSettingManager.enterpriseSettings();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Scrollbar(
            child: SingleChildScrollView(
                child: Column(
          children: [
            // Go to user account
            ListTile(
              title: Text("Your Account"),
              trailing: Icon(Icons.account_circle),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AccountPage()));
                setState(() {});
              },
            ),

            Divider(),

            // Standard settings
            Container(
                child: Column(
                    children: standardSettings.entries.map((entry) {
              // return buildStandardSettingWidget(entry.key, entry.value);
              return SettingWidget(name: entry.key, setting: entry.value);
            }).toList())),

            // Premium Settings Label (changes if the premium user changes)
            Card(
                margin: EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(Icons.stars, color: isPremium ? accentColor : Theme.of(context).disabledColor),
                            Text(
                              isPremium ? "Premium Settings" : "Premium Account Settings",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isPremium ? accentColor : Theme.of(context).disabledColor,
                                  fontSize: Theme.of(context).primaryTextTheme.subtitle1.fontSize),
                            ),
                            Icon(Icons.stars, color: isPremium ? accentColor : Theme.of(context).disabledColor),
                          ],
                        )),

                    // Premium Settings
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          children: premiumSettings.entries.map((entry) {
                            // return buildPremiumSettingWidget(entry.key, entry.value);
                            return SettingWidget(name: entry.key, setting: entry.value);
                          }).toList(),
                        )),
                  ],
                )),

            // Enable hidden settings for running in debug mode
            kDebugMode
                ? HiddenSettings(
                    children: hiddenSettings.entries
                        .map((entry) => buildStandardSettingWidget(entry.key, entry.value))
                        .toList())
                : Container(),

            Divider(),

            Column(
                children: ListTile.divideTiles(
              context: context,
              tiles: [
                // ListTile(title: Text("Contact Support: ")),
                ListTile(
                  dense: true,
                  title: Text("Terms and Conditions"),
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => termsAndConditionsPage()));
                  },
                ),
                ListTile(
                  dense: true,
                  title: Text("Privacy Policy"),
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => privacyPolicyPage()));
                  },
                ),
                ListTile(
                  dense: true,
                  title: Text("Release Notes"),
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => Scaffold(appBar: AppBar(title: Text("Release Notes")), body: ReleaseNotes())));
                  },
                ),
                ListTile(dense: true, title: VersionText()),
                ListTile(dense: true, title: autoCallCopyright(textAlign: TextAlign.start)),
              ],
            ).toList()),
          ],
        ))),
      ),
    );
  }

  Widget buildStandardSettingWidget(String key, Setting setting) {
    switch (setting.type) {
      case bool:
        {
          return SwitchListTile.adaptive(
            title: Text(setting.text),
            subtitle: setting.description != null ? Text(setting.description) : null,
            controlAffinity: ListTileControlAffinity.trailing,
            value: setting.value,
            activeColor: Theme.of(context).accentColor,
            onChanged: (bool value) {
              setState(() {
                manager.set(key, value);
              });
            },
          );
        }

      case int:
        {
          return Container();
        }

      case String:
        {
          return ListTile(
              title: Text(setting.text),
              subtitle: setting.description != null ? Text(setting.description) : null,
              trailing: Text(setting.value.isNotEmpty ? setting.value : "None"));
        }
    }

    return Container();
  }
}

///
/// Setting Widget Class
///
///
class SettingWidget extends StatefulWidget {
  final Setting setting;
  final String name;
  const SettingWidget({Key key, @required this.name, @required this.setting}) : super(key: key);

  @override
  SettingWidgetState createState() => new SettingWidgetState();
}

class SettingWidgetState extends State<SettingWidget> {
  Setting get setting => widget.setting;

  bool get isPremiumSetting =>
      setting.settingType == SettingType.premium || setting.settingType == SettingType.enterprise;

  @override
  Widget build(BuildContext context) {
    bool premiumUser = globalSettingManager.isPremium();

    switch (widget.setting.type) {
      case bool:
        {
          return SwitchListTile.adaptive(
            title: Text(setting.text,
                style: !isPremiumSetting
                    ? null
                    : TextStyle(color: !premiumUser ? Theme.of(context).disabledColor : Theme.of(context).accentColor)),
            subtitle: setting.description != null
                ? Text(setting.description,
                    style: !isPremiumSetting
                        ? null
                        : TextStyle(
                            color: !premiumUser ? Theme.of(context).disabledColor : Theme.of(context).accentColor))
                : null,
            controlAffinity: ListTileControlAffinity.trailing,
            value: isPremiumSetting && !premiumUser ? false : widget.setting.value,
            activeColor: Theme.of(context).accentColor,
            onChanged: isPremiumSetting && !premiumUser
                ? null
                : (bool value) {
                    setState(() {
                      globalSettingManager.set(widget.name, value);

                      if (widget.name == "darkMode") {
                        Provider.of<ThemeProvider>(context, listen: false).setTheme(value);
                      }
                    });
                  },
          );
        }
      case int:
        {
          // return ListTile(
          //   title: Text(setting.text),
          //
          //   // trailing: Text("${setting.value ?? 0}"),
          //   trailing: ToggleButtons(children: [
          //     Text("Free"), Text("Premium"), Text("Enterprise")
          //   ], isSelected: [],),
          //   // subtitle: Text(setting.description),
          // trailing: Switch(
          //   value: setting.value,
          //   activeColor: Theme.of(context).accentColor,
          //   onChanged: (bool value) {
          //     setState(() {
          //       manager.set(key, value);
          //     });
          //   },
          // ),
          // );
          return Container();
        }
      case String:
        {
          return ListTile(
              title: Text(setting.text,
                  style: !isPremiumSetting
                      ? null
                      : TextStyle(
                          color: !premiumUser ? Theme.of(context).disabledColor : Theme.of(context).accentColor)),
              subtitle: setting.description != null
                  ? Text(setting.description,
                      style: !isPremiumSetting
                          ? null
                          : TextStyle(
                              color: !premiumUser ? Theme.of(context).disabledColor : Theme.of(context).accentColor))
                  : null,
              trailing: Text(setting.value,
                  style: !isPremiumSetting
                      ? null
                      : TextStyle(
                          color: !premiumUser ? Theme.of(context).disabledColor : Theme.of(context).accentColor)));
        }
    }

    return Container();
  }
}

///
/// Widget to show hidden settings
///
class HiddenSettings extends StatefulWidget {
  final List<Widget> children;
  const HiddenSettings({Key key, @required this.children}) : super(key: key);

  @override
  HiddenSettingsState createState() => new HiddenSettingsState();
}

class HiddenSettingsState extends State<HiddenSettings> {
  @override
  Widget build(BuildContext context) {
    return !kReleaseMode
        ? ExpansionTile(
            title: Text("Hidden Settings", style: Theme.of(context).textTheme.subtitle1), children: widget.children)
        : Container();
  }
}
