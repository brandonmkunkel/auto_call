import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:auto_call/ui/terms.dart';
import 'package:auto_call/ui/theme.dart';
import 'package:auto_call/services/settings_manager.dart';
import 'package:auto_call/ui/widgets/settings_widgets.dart';

import 'account.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = "/settings";
  final String title = "Settings";
  final String label = "Settings";

  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final SettingManager manager = globalSettingManager;

  bool get isPremium => manager.isPremium();

  @override
  Widget build(BuildContext context) {
    Map<String, Setting> standardSettings = globalSettingManager.standardSettings();
    Map<String, Setting> premiumSettings = globalSettingManager.premiumSettings();
    Map<String, Setting> enterpriseSettings = globalSettingManager.enterpriseSettings();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Scrollbar(child:
      SingleChildScrollView(
          child: Column(
        children: [
          // Go to user account
          ListTile(
            title: Text("User Account"),
            trailing: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AccountPage()));
              },
            ),
          ),

          Divider(),

          // Standard settings
          Column(
              children: standardSettings.entries.map((entry) {
            return buildStandardSettingWidget(entry.key, entry.value);
          }).toList()),

          // Setting Divider
          Divider(),

          // Premium Settings Label (changes if the premium user changes)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(Icons.stars, color: isPremium ? Theme.of(context).accentColor : Colors.grey[500]),
              Text(
                isPremium ? "Premium Settings" : "Available Only for Premium Accounts",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isPremium ? Theme.of(context).accentColor : Colors.grey[500],
                    fontSize: Theme.of(context).primaryTextTheme.subtitle1.fontSize),
              ),
              Icon(Icons.stars, color: isPremium ? Theme.of(context).accentColor : Colors.grey[500]),
            ],
          ),

          // Premium Settings
          Column(
            children: premiumSettings.entries.map((entry) {
              return buildPremiumSettingWidget(entry.key, entry.value);
            }).toList(),
          ),

          Divider(),

          // Bottom App Information
          Column(
                children: ListTile.divideTiles(
              context: context,
              tiles: [
                // ListTile(title: Text("Support")),
                ListTile(
                  dense: true,
                  title: Text("Terms and Conditions"),
                  onTap: () async {
                    await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(title: Text("Terms and Conditions:"), content: termsAndConditions()));
                  },
                ),
                ListTile(
                  dense: true,
                  title: Text("Privacy Policy"),
                  onTap: () async {
                    await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(title: Text("Privacy Policy:"), content: privacyPolicy()));
                  },
                ),
                ListTile(
                  dense: true,
                  title: Text("Release Notes"),
                  onTap: () async {
                    await showDialog(
                        context: context, builder: (_) => AlertDialog(title: Text("Release Notes:"), content: changelog()));
                  },
                ),
                ListTile(dense: true, title: VersionText()),
                ListTile(dense: true, title: autoCallCopyright(textAlign: TextAlign.start)),
              ],
            ).toList()),
        ],
      ))),
    );
  }

  Widget buildStandardSettingWidget(String key, Setting setting) {
    switch (setting.type) {
      case bool:
        {
          return ListTile(
            title: Text(setting.text),
            // subtitle: Text(setting.description),
            trailing:
              Switch(
                value: setting.value,
                onChanged: (bool value) {
                  setState(() {
                    manager.set(key, value);
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

    return Container();
  }

  Widget buildPremiumSettingWidget(String key, Setting setting) {
    switch (setting.type) {
      case bool:
        {
          return ListTile(
            title: Text(setting.text,
                style: TextStyle(color: !isPremium ? Colors.grey[500] : Theme.of(context).accentColor)),
            // subtitle: Text(setting.description,
            //     style: TextStyle(color: !isPremium ? Colors.grey[500] : Theme.of(context).accentColor)),
            trailing: Switch(
              value: !isPremium ? false : setting.value,
              onChanged: !isPremium
                  ? (bool value) {}
                  : (bool value) {
                      setState(() {
                        manager.set(key, value);

                        if (key == "darkMode") {
                          Provider.of<ThemeProvider>(context, listen: false).setTheme(value);
                        }
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

    return Container();
  }
}
