import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:auto_call/ui/widgets/permission_widget.dart';

///
/// The [PhoneContactsWidget] Widget is used to interact with the user's local contacts
///
class PhoneContactsWidget extends StatefulWidget {
  @override
  PhoneContactsState createState() => new PhoneContactsState();
}

class PhoneContactsState extends State<PhoneContactsWidget> {
  Future<Iterable<Contact>> futureContacts = ContactsService.getContacts(withThumbnails: true);

  /// Whether multi select is on
  Map<int, bool> selected = Map<int, bool>();
  bool get multiSelect => selected.containsValue(true);

  @override
  Widget build(BuildContext context) {
    // Show the contact information
    return PermissionsWidget(requestedPermission: Permission.contacts,
      child: FutureBuilder(
        future: futureContacts,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<Contact> contacts = snapshot.data.where((Contact c) => c.phones.isNotEmpty).toList();

            return contacts.isEmpty
                ? Center(
              child: Text("No contacts found!", style: Theme.of(context).textTheme.subtitle1),
            )
                : ListView.builder(
              itemCount: contacts.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact c = contacts.elementAt(index);
                return ListTile(
                  onTap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (BuildContext context) => ContactDetailsPage(
                    //       c,
                    //       onContactDeviceSave:
                    //       contactOnDeviceHasBeenUpdated,
                    //     )));
                  },
                  onLongPress: () {
                    selected[index] = true;
                  },
                  leading: (c.avatar != null && c.avatar.length > 0)
                      ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                      : CircleAvatar(child: Text(c.initials())),
                  trailing: Text(c.phones.elementAt(0).value),
                  title: Text(c.displayName ?? ""),
                );
              },
            );
          }

          // If the contacts haven't been loaded yet
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(),
            Container(
              padding: EdgeInsets.all(40.0),
              child: Text(
                "Loading App Contacts",
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
            )
          ]);
        },
      ),
    );
  }
}