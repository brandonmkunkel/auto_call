import 'package:flutter/material.dart';

import 'package:auto_call/ui/widgets/phone_contacts.dart';

class ContactsPage extends StatefulWidget {
  static const String routeName = "/contacts";
  final String title = "Contacts";
  final String label = "Contacts";

  @override
  ContactsState createState() => new ContactsState();
}

class ContactsState extends State<ContactsPage> {
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
        body: TabBarView(children: [AppContactsWidget(), PhoneContactsWidget()]),
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
    return Center(
        child: Text(
      "This app does not save your contacts yet.",
      style: Theme.of(context).textTheme.subtitle1,
      textAlign: TextAlign.center,
    ));
  }
}

