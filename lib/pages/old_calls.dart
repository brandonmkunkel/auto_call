import 'package:flutter/material.dart';

import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/pages/call_session.dart';

enum oldCallEnum { load, email, delete }

class OldCallsPage extends StatefulWidget {
  static const String routeName = "/old_calls";
  final String title = "Old Calls";
  final String label = "Old Calls";

  @override
  OldCallsState createState() => new OldCallsState();
}

class OldCallsState extends State<OldCallsPage> {
  List<String> files;
  bool multiSelect = false;
  List<bool> selected = [];

  void toggleMultiSelect() {
    multiSelect = !multiSelect;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(context),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                    child: Text("Old Call Sessions",
                        textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline))),
            Expanded(
                child: FutureBuilder(
              future: showOldCalls(context),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return snapshot.hasData
                    ? snapshot.data
                    : Center(child: SizedBox(width: 50.0, height: 50.0, child: const CircularProgressIndicator()));
              },
            ))
          ],
        ));
  }

  Future<Widget> showOldCalls(BuildContext context) async {
    files = await FileManager.findOldCalls();

    return files.isNotEmpty
        ? ListView(
            children: List<Widget>.generate(files.length, (int index) {
            return ListTile(
              title: Text(files[index]),
//        onLongPress: () {multiSelect=true;},
//        leading: multiSelect ? Checkbox(value: selected[index], onChanged: (bool value){selected[index]=!selected[index];}) : null,
              trailing: _popUpFile(context, index),
            );
          }))
        : Container(child: Text("No old call sessions found.", style: Theme.of(context).textTheme.subhead));
  }

  void showMenuSelection(oldCallEnum value) {
//    showInSnackBar('You selected: $value');
  }

  Widget _popUpFile(BuildContext context, int index) {
    return PopupMenuButton(
        onCanceled: () {
          print('You have not chosen anything');
        },
        tooltip: 'Select option for the file',
        onSelected: (oldCallEnum _enum) async {
          if (_enum == oldCallEnum.load) {
            Navigator.pushNamed(
              context,
              CallSessionPage.routeName,
//              arguments: await readFileAsync(files[index].toString()),
              arguments: FileManager(files[index].toString()),
            );
          } else if (_enum == oldCallEnum.email){
            print("trying to email");
          } else if (_enum == oldCallEnum.delete) {
            await FileManager.deleteFile(files[index].toString());
            setState(() {});
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<oldCallEnum>(
              value: oldCallEnum.load,
              child: Text('Load'),
            ),
            PopupMenuItem<oldCallEnum>(
              value: oldCallEnum.email,
              child: Text('Email'),
            ),
            PopupMenuItem<oldCallEnum>(
              value: oldCallEnum.delete,
              child: Text('Delete'),
            )
          ];
        });
  }
}
