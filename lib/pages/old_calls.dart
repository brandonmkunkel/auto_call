import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/old_call_manager.dart';
import 'package:auto_call/ui/drawer.dart';

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
                    child: Text("Call Session History",
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
    List<String> files = await FileManager.findOldCalls();
//    print(["Files", files]);

    return ListView(
        children: List<Widget>.generate(files.length, (int index) {
      return ListTile(
        title: Text(files[index]),
//        onLongPress: () {multiSelect=true;},
//        leading: multiSelect ? Checkbox(value: selected[index], onChanged: (bool value){selected[index]=!selected[index];}) : null,
        trailing: IconButton(
            icon: Icon(Icons.expand_more),
            onPressed: () {
              PopupMenuButton(
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<oldCallEnum>>[
                        PopupMenuItem<oldCallEnum>(
                          value: oldCallEnum.load,
                          child: Text('Load'),
                        ),
                        PopupMenuItem<oldCallEnum>(
                          value: oldCallEnum.delete,
                          child: Text('Delete'),
                        )
                      ]);
            }),
      );
    }));
  }

  void showMenuSelection(oldCallEnum value) {
//    showInSnackBar('You selected: $value');
  }
}
