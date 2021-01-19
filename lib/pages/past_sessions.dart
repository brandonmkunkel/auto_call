import 'package:auto_call/pages/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/pages/call_page.dart';

enum oldCallEnum { load, delete }

class PastSessionsPage extends StatefulWidget {
  static const String routeName = "/old_calls";
  final String title = "Old Call Sessions";
  final String label = "Old Call Sessions";

  @override
  PastSessionsState createState() => new PastSessionsState();
}

class PastSessionsState extends State<PastSessionsPage> {
  Map<int, bool> selected = Map<int, bool>();
  List<String> files;

  /// Whether multi select is on
  bool get multiSelect => selected.containsValue(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder(
            future: FileManager.findOldCalls(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                files = snapshot.data;
                return showPastSessions(context, snapshot.data);
              }

              if (snapshot.hasError) {
                return Column(children: <Widget>[
                  Icon(Icons.error_outline, color: Colors.red, size: 50.0),
                  Padding(padding: const EdgeInsets.only(top: 16), child: Text('Error: ${snapshot.error}'))
                ]);
              }

              // Loading Screen
              return Center(child: SizedBox(width: 50.0, height: 50.0, child: const CircularProgressIndicator()));
            },
          ))
        ],
      ),
      floatingActionButton: multiSelect
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                    icon: Icon(Icons.close_rounded),
                    backgroundColor: Colors.grey,
                    label: Text("Cancel"),
                    onPressed: () async {
                      setState(() {
                        selected.clear();
                      });
                    }),
                FloatingActionButton.extended(
                    icon: Icon(Icons.delete),
                    backgroundColor: Colors.red,
                    label: Text("Delete"),
                    onPressed: () async {
                      selected.forEach((key, value) async {
                        if (value) {
                          await FileManager.deleteFile(files[key]);
                          print("deleted ${files[key]}");
                        }

                        setState(() {
                          selected.clear();
                        });
                      });
                    })
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget showPastSessions(BuildContext context, List<String> oldCalls) {
    return oldCalls.isNotEmpty
        ? Scrollbar(
            child: ListView.separated(
                itemCount: oldCalls.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    title: Text(FileManager.getFileName(oldCalls[index])),
                    trailing: _popUpFile(context, index),
                    leading: selected.containsValue(true)
                        ? Checkbox(
                            value: selected[index] ?? false,
                            onChanged: (bool value) {
                              setState(() {
                                selected[index] = value;
                              });
                            })
                        : Container(
                            child: IconButton(
                            icon: Icon(Icons.insert_drive_file),
                            onPressed: () {
                              setState(() {
                                selected[index] = true;
                              });
                            },
                          )),
                    onTap: () {
                      setState(() {
                        selected[index] = selected.containsKey(index) ? !selected[index] : true;
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        selected[index] = true;
                      });
                    },
                  );
                }))
        : Container(
            padding: EdgeInsets.all(20.0),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text("No old call sessions found.", style: Theme.of(context).textTheme.subtitle1),
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => FileSelectorPage()));
                  },
                  child: Text("Start a Call Session"),
                )
              ],
            ),
          );
  }

  Widget _popUpFile(BuildContext context, int index) {
    return PopupMenuButton(
        tooltip: 'Select option for the file',
        onSelected: (oldCallEnum _enum) async {
          if (_enum == oldCallEnum.load) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CallSessionPage(fileManager: FileManager.fromFile(files[index].toString()))));
          } else if (_enum == oldCallEnum.delete) {
            await FileManager.deleteFile(files[index].toString());
          }

          // Trigger widget rebuilds
          setState(() {});
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<oldCallEnum>(value: oldCallEnum.load, child: Text('Load')),
            PopupMenuItem<oldCallEnum>(value: oldCallEnum.delete, child: Text('Delete'))
          ];
        });
  }
}
