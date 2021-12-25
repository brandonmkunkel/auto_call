import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

import 'package:auto_call/classes/setting.dart';
import 'package:auto_call/pages/upgrade.dart';
import 'package:auto_call/ui/widgets/permission_widget.dart';
import 'package:auto_call/ui/widgets/phone_contacts.dart';

class ContactsPage extends StatefulWidget {
  static const String routeName = "/contacts";
  final String title = "Contacts";

  @override
  ContactsState createState() => new ContactsState();
}

class ContactsState extends State<ContactsPage> {
  Map<int, bool> selected = {};
  List<Contact> contacts = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: [
              Tab(text: "App Contacts"),
              Tab(text: "Phone Contacts"),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(children: [
            AppContactsWidget(),
            PermissionsWidget(requestedPermission: Permission.contacts, child: PhoneContactsPage())
          ]),
        ),
      ),
    );
  }
}

///
/// The [AppContactsWidget] is used to interact with the contacts that the User contacted in past call sessions
///
class AppContactsWidget extends StatefulWidget {
  @override
  AppContactsState createState() => new AppContactsState();
}

class AppContactsState extends State<AppContactsWidget> {
  @override
  Widget build(BuildContext context) {
    return UpgradePromptWidget(
        requiredAccountType: AccountType.premium,
        featureName: "contact tracking",
        child: Center(
            child: Text("This app does not save your contacts yet.", style: Theme.of(context).textTheme.subtitle1)));
  }
}
