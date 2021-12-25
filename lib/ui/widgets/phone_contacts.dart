import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:intl/intl.dart';

import 'package:auto_call/ui/call_session_widget.dart';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/classes/phone_list.dart';
import 'package:auto_call/ui/prompts/errors.dart';

/// iOS only: Localized labels language setting is equal to CFBundleDevelopmentRegion value (Info.plist) of the iOS project
/// Set iOSLocalizedLabels=false if you always want english labels whatever is the CFBundleDevelopmentRegion value.
const bool iOSLocalizedLabels = false;

///
/// The [PhoneContactsWidget] Widget is used to interact with the user's local contacts
///
class PhoneContactsPage extends StatefulWidget {
  @override
  PhoneContactsPageState createState() => new PhoneContactsPageState();
}

class PhoneContactsPageState extends State<PhoneContactsPage> {
  Future<Iterable<Contact>> contactsFuture = ContactsService.getContacts(withThumbnails: true);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: contactsFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return GeneralErrorWidget(errorText: "Error loading phone contacts", error: snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          List<Contact> contacts = snapshot.data.where((Contact c) => c.phones?.isNotEmpty).toList();

          return contacts.isEmpty
              ? Center(child: Text("No contacts found!", style: Theme.of(context).textTheme.subtitle1))
              : PhoneContactsWidget(contacts: contacts);
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
    );
  }
}

class PhoneContactsWidget extends StatefulWidget {
  final List<Contact> contacts;

  PhoneContactsWidget({required this.contacts});

  @override
  _PhoneContactsWidgetState createState() => _PhoneContactsWidgetState();
}

class _PhoneContactsWidgetState extends State<PhoneContactsWidget> {
  // Map of selected contacts, used for various operations
  Map<int, bool> selected = {};

  /// Whether multi select is on
  bool get multiSelect => selected.containsValue(true);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: widget.contacts.length,
          itemBuilder: (BuildContext context, int index) {
            Contact c = widget.contacts.elementAt(index);
            return ListTile(
              onTap: () async {
                setState(() {
                  select(index);
                });
              },
              onLongPress: () {
                setState(() {
                  select(index);
                });
              },
              leading: IconButton(
                icon: multiSelect && selected[index] == true
                    ? Icon(Icons.check_circle, color: Theme.of(context).buttonTheme.colorScheme?.primary)
                    : (c.avatar != null && (c.avatar?.length ?? 0) > 0)
                        ? CircleAvatar(backgroundImage: MemoryImage(c.avatar as Uint8List))
                        : CircleAvatar(child: Text(c.initials())),
                onPressed: () {
                  setState(() {
                    select(index);
                  });
                },
                iconSize: 40.0,
                padding: EdgeInsets.all(0),
                alignment: Alignment.centerLeft,
              ),
              trailing: Text(c.phones?.elementAt(0).value as String),
              title: Text(c.displayName ?? ""),
            );
          },
        ),
        selected.length >= 2
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  FloatingActionButton.extended(
                      onPressed: () {
                        setState(() {
                          selected.clear();
                        });
                      },
                      backgroundColor: Colors.grey,
                      heroTag: "cancel",
                      label: Text("Cancel"),
                      icon: Icon(Icons.cancel)),
                  FloatingActionButton.extended(
                      onPressed: () {
                        // Remove all "false" entries in the map
                        selected.removeWhere((key, value) => value == false);

                        // Start a call session
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CallSessionWidget(
                                fileManager: FileManager.fromFile("from_calls.csv"),
                                phoneList: PhoneList.fromContacts(
                                    selected.entries.map((e) => widget.contacts[e.key]).toList()))));
                      },
                      heroTag: "start a call session",
                      label: Text("Start a Call Session"),
                      icon: Icon(Icons.phone)),
                ]))
            : Container(),
      ],
    );
  }

  void select(int index) {
    if (selected[index] == null) {
      selected[index] = true;
    } else {
      selected.remove(index);
    }
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = widget.contacts.indexWhere((c) => c.identifier == contact.identifier);
      widget.contacts[id] = contact;
    });
  }
}

class ContactDetailsPage extends StatelessWidget {
  ContactDetailsPage(this._contact, {required this.onContactDeviceSave});

  final Contact _contact;
  final Function(Contact) onContactDeviceSave;

  _openExistingContactOnDevice(BuildContext context) async {
    try {
      var contact = await ContactsService.openExistingContact(_contact, iOSLocalizedLabels: iOSLocalizedLabels);
      onContactDeviceSave(contact);
      Navigator.of(context).pop();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.displayName ?? ""),
        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.share),
//            onPressed: () => shareVCFCard(context, contact: _contact),
//          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => ContactsService.deleteContact(_contact),
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UpdateContactsPage(
                  contact: _contact,
                ),
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.edit), onPressed: () => _openExistingContactOnDevice(context)),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("First Name"),
            trailing: Text(_contact.givenName ?? ""),
          ),
          ListTile(
            title: Text("Middle name"),
            trailing: Text(_contact.middleName ?? ""),
          ),
          ListTile(
            title: Text("Last name"),
            trailing: Text(_contact.familyName ?? ""),
          ),
          ListTile(
            title: Text("Prefix"),
            trailing: Text(_contact.prefix ?? ""),
          ),
          ListTile(
            title: Text("Suffix"),
            trailing: Text(_contact.suffix ?? ""),
          ),
          ListTile(
            title: Text("Birthday"),
            trailing:
                Text(_contact.birthday != null ? DateFormat('dd-MM-yyyy').format(_contact.birthday as DateTime) : ""),
          ),
          ListTile(
            title: Text("Company"),
            trailing: Text(_contact.company ?? ""),
          ),
          ListTile(
            title: Text("Job"),
            trailing: Text(_contact.jobTitle ?? ""),
          ),
          ListTile(
            title: Text("Account Type"),
            trailing: Text((_contact.androidAccountType != null) ? _contact.androidAccountType.toString() : ""),
          ),
          AddressesTile(_contact.postalAddresses as List<PostalAddress>),
          ItemsTile("Phones", _contact.phones as List<Item>),
          ItemsTile("Emails", _contact.emails as List<Item>)
        ],
      ),
    );
  }
}

class AddressesTile extends StatelessWidget {
  AddressesTile(this._addresses);

  final Iterable<PostalAddress> _addresses;

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text("Addresses")),
        Column(
          children: _addresses
              .map((a) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("Street"),
                          trailing: Text(a.street ?? ""),
                        ),
                        ListTile(
                          title: Text("Postcode"),
                          trailing: Text(a.postcode ?? ""),
                        ),
                        ListTile(
                          title: Text("City"),
                          trailing: Text(a.city ?? ""),
                        ),
                        ListTile(
                          title: Text("Region"),
                          trailing: Text(a.region ?? ""),
                        ),
                        ListTile(
                          title: Text("Country"),
                          trailing: Text(a.country ?? ""),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);

  final Iterable<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: _items
              .map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Text(i.label ?? ""),
                    trailing: Text(i.value ?? ""),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class AddContactPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  Contact contact = Contact();
  PostalAddress address = PostalAddress(label: "Home");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a contact"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _formKey.currentState?.save();
              contact.postalAddresses = [address];
              ContactsService.addContact(contact);
              Navigator.of(context).pop();
            },
            child: Icon(Icons.save, color: Colors.white),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'First name'),
                onSaved: (v) => contact.givenName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Middle name'),
                onSaved: (v) => contact.middleName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last name'),
                onSaved: (v) => contact.familyName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Prefix'),
                onSaved: (v) => contact.prefix = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Suffix'),
                onSaved: (v) => contact.suffix = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) => contact.phones = [Item(label: "mobile", value: v)],
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                onSaved: (v) => contact.emails = [Item(label: "work", value: v)],
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Company'),
                onSaved: (v) => contact.company = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Job'),
                onSaved: (v) => contact.jobTitle = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Street'),
                onSaved: (v) => address.street = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'City'),
                onSaved: (v) => address.city = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Region'),
                onSaved: (v) => address.region = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Postal code'),
                onSaved: (v) => address.postcode = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Country'),
                onSaved: (v) => address.country = v,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateContactsPage extends StatefulWidget {
  UpdateContactsPage({required this.contact});

  final Contact contact;

  @override
  _UpdateContactsPageState createState() => _UpdateContactsPageState();
}

class _UpdateContactsPageState extends State<UpdateContactsPage> {
  late Contact contact;
  PostalAddress address = PostalAddress(label: "Home");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Contact"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () async {
              _formKey.currentState?.save();
              contact.postalAddresses = [address];
              await ContactsService.updateContact(contact);
              Navigator.of(context).pop();
              // Navigator.of(context).pushReplacement(
              //     MaterialPageRoute(builder: (context) => ContactListPage()));
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: contact.givenName ?? "",
                decoration: const InputDecoration(labelText: 'First name'),
                onSaved: (v) => contact.givenName = v,
              ),
              TextFormField(
                initialValue: contact.middleName ?? "",
                decoration: const InputDecoration(labelText: 'Middle name'),
                onSaved: (v) => contact.middleName = v,
              ),
              TextFormField(
                initialValue: contact.familyName ?? "",
                decoration: const InputDecoration(labelText: 'Last name'),
                onSaved: (v) => contact.familyName = v,
              ),
              TextFormField(
                initialValue: contact.prefix ?? "",
                decoration: const InputDecoration(labelText: 'Prefix'),
                onSaved: (v) => contact.prefix = v,
              ),
              TextFormField(
                initialValue: contact.suffix ?? "",
                decoration: const InputDecoration(labelText: 'Suffix'),
                onSaved: (v) => contact.suffix = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) => contact.phones = [Item(label: "mobile", value: v)],
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                onSaved: (v) => contact.emails = [Item(label: "work", value: v)],
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                initialValue: contact.company ?? "",
                decoration: const InputDecoration(labelText: 'Company'),
                onSaved: (v) => contact.company = v,
              ),
              TextFormField(
                initialValue: contact.jobTitle ?? "",
                decoration: const InputDecoration(labelText: 'Job'),
                onSaved: (v) => contact.jobTitle = v,
              ),
              TextFormField(
                initialValue: address.street ?? "",
                decoration: const InputDecoration(labelText: 'Street'),
                onSaved: (v) => address.street = v,
              ),
              TextFormField(
                initialValue: address.city ?? "",
                decoration: const InputDecoration(labelText: 'City'),
                onSaved: (v) => address.city = v,
              ),
              TextFormField(
                initialValue: address.region ?? "",
                decoration: const InputDecoration(labelText: 'Region'),
                onSaved: (v) => address.region = v,
              ),
              TextFormField(
                initialValue: address.postcode ?? "",
                decoration: const InputDecoration(labelText: 'Postal code'),
                onSaved: (v) => address.postcode = v,
              ),
              TextFormField(
                initialValue: address.country ?? "",
                decoration: const InputDecoration(labelText: 'Country'),
                onSaved: (v) => address.country = v,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
