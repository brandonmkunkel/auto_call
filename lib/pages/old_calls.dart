import 'package:auto_call/pages/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/old_call_manager.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/pages/call_session.dart';


enum oldCallEnum { delete, load }

class OldCallsPage extends StatefulWidget {
  static String routeName = "/old_calls";
  final String title = "Old Calls";
  final String label = "Old Calls";

  @override
  OldCallsState createState() => new OldCallsState();
}

class OldCallsState extends State<OldCallsPage> {
//  OldCallManager manager;
  var callHistoryFiles = new Container();
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
              future: showOldCalls(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return snapshot.hasData
                    ? snapshot.data
                    : Center(child: SizedBox(width: 50.0, height: 50.0, child: const CircularProgressIndicator()));

                ///load until snapshot.hasData resolves to true
              },
            ))
          ],
        ));
  }

  Future<Widget> showOldCalls() async {
    files = await FileManager.findOldCalls();

    return ListView(
        children: List<Widget>.generate(files.length, (int index) {
      return ListTile(
        title: Text(files[index]),
//        onLongPress: () {multiSelect=true;},
//        leading: multiSelect ? Checkbox(value: selected[index], onChanged: (bool value){selected[index]=!selected[index];}) : null,
        trailing: _popUpFile(context, index),
      );
    }));
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
                arguments: await readFileAsync(files[index].toString()),
            );
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
              value: oldCallEnum.delete,
              child: Text('Delete'),
            )
          ];
        });
  }
}



