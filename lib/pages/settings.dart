import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:auto_call/ui/theme.dart';
import 'package:auto_call/ui/drawer.dart';
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
  bool isPremium = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
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
              children: globalSettingManager.standardSettings().entries.map((entry) {
            return buildStandardSettingWidget(entry.key, entry.value);
          }).toList()),

          // Setting Divider
          Divider(),

          // Premium Settings Label (changes if the premium user changes)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(Icons.stars, color: manager.isPremium() ? Theme.of(context).accentColor : Colors.grey[500]),
              Text(
                manager.isPremium() ? "Premium Settings" : "Available Only for Premium Accounts",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: manager.isPremium() ? Theme.of(context).accentColor : Colors.grey[500],
                    fontSize: Theme.of(context).primaryTextTheme.subtitle1.fontSize),
              ),
              Icon(Icons.stars, color: manager.isPremium() ? Theme.of(context).accentColor : Colors.grey[500]),
            ],
          ),

          // Premium Settings
          Column(
            children: globalSettingManager.premiumSettings().entries.map((entry) {
              return buildPremiumSettingWidget(entry.key, entry.value);
            }).toList(),
          ),

          // Divider(),
          // Column(children: [
          //   Text("Change Log"),
          //   Text("Support"),
          //   Text("Terms and conditions"),
          //   Text("Privacy Policy")
          // ],
          // )
        ],
      )),
    );
  }

  Widget buildStandardSettingWidget(String key, Setting setting) {
    switch (setting.type) {
      case bool:
        {
          return ListTile(
            title: Text(setting.text),
            trailing: Switch(
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
  }

  Widget buildPremiumSettingWidget(String key, Setting settings) {
    switch (settings.type) {
      case bool:
        {
          return ListTile(
            title: Text(settings.text,
                style: TextStyle(color: !manager.isPremium() ? Colors.grey[500] : Theme.of(context).accentColor)),
            trailing: Switch(
              value: !manager.isPremium() ? false : settings.value,
              onChanged: !manager.isPremium()
                  ? (bool) {}
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
  }
}
