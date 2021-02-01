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
    Color accentColor = Theme.of(context).accentColor;
    // Color accentColor = Theme.of(context).floatingActionButtonTheme.backgroundColor;

    Map<String, Setting> standardSettings = globalSettingManager.standardSettings();
    Map<String, Setting> premiumSettings = globalSettingManager.premiumSettings();
    Map<String, Setting> enterpriseSettings = globalSettingManager.enterpriseSettings();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Scrollbar(
          child: SingleChildScrollView(
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
          Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                  children: standardSettings.entries.map((entry) {
                return buildStandardSettingWidget(entry.key, entry.value);
              }).toList())),

          // Setting Divider
          Divider(),

          // Premium Settings Label (changes if the premium user changes)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(Icons.stars, color: isPremium ? accentColor : Colors.grey[500]),
              Text(
                isPremium ? "Premium Settings" : "Available Only for Premium Accounts",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isPremium ? accentColor : Colors.grey[500],
                    fontSize: Theme.of(context).primaryTextTheme.subtitle1.fontSize),
              ),
              Icon(Icons.stars, color: isPremium ? accentColor : Colors.grey[500]),
            ],
          ),

          // Premium Settings
          Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: premiumSettings.entries.map((entry) {
                  return buildPremiumSettingWidget(entry.key, entry.value);
                }).toList(),
              )),

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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Scaffold(appBar: AppBar(title: Text("Terms and Conditions:")), body: termsAndConditions())));
                },
              ),
              ListTile(
                dense: true,
                title: Text("Privacy Policy"),
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Scaffold(appBar: AppBar(title: Text("Privacy Policy:")), body: privacyPolicy())));
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
    );
  }

  Widget buildStandardSettingWidget(String key, Setting setting) {
    switch (setting.type) {
      case bool:
        {
          return ListTile(
            title: Text(setting.text),
            // subtitle: Text(setting.description),
            trailing: Switch(
              value: setting.value,
              activeColor: Theme.of(context).accentColor,
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
              activeColor: Theme.of(context).accentColor,
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
