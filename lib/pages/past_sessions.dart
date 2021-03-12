import 'package:flutter/material.dart';
import 'dart:io';

import 'package:auto_call/pages/file_selector.dart';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/pages/call_page.dart';
import 'package:auto_call/ui/prompts/errors.dart';

enum oldCallEnum { load, delete }

class PastSessionsPage extends StatefulWidget {
  static const String routeName = "/past_sessions";
  static const String label = "Past Sessions";
  final String title = "Past Sessions";

  @override
  PastSessionsState createState() => new PastSessionsState();
}

class PastSessionsState extends State<PastSessionsPage> {
  Future<List<String>> oldCallsFuture = FileManager.findOldCalls(recentFirst: true);

  Map<int, bool> selected = Map<int, bool>();
  List<String> files;

  /// Whether multi select is on
  bool get multiSelect => selected.containsValue(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: FutureBuilder(
              future: oldCallsFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  files = snapshot.data ?? [];
                  print("redoing");
                  return showPastSessions(context, files);
                }

                if (snapshot.hasError) {
                  return GeneralErrorWidget(errorText: "Error loading old calls", error: snapshot.error);
                }

                // Loading Screen
                return Center(child: SizedBox(width: 50.0, height: 50.0, child: const CircularProgressIndicator()));
              },
        ),
      ),
      floatingActionButton: multiSelect
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                    icon: Icon(Icons.close),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: Text("Cancel"),
                    heroTag: "cancel_selected",
                    onPressed: () async {
                      setState(() {
                        selected.clear();
                      });
                    }),
                FloatingActionButton.extended(
                    icon: Icon(Icons.delete),
                    backgroundColor: Colors.red,
                    label: Text("Delete"),
                    heroTag: "delete_selected",
                    onPressed: () async {
                      selected.forEach((key, value) async {
                        if (value) {
                          await FileManager.deleteFile(files[key]);
                        }
                      });

                      setState(() {
                        selected.clear();
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
                    subtitle: Text("Date Modified: ${FileManager.getDateModified(oldCalls[index])}"),
                    trailing: PopupMenuButton(
                        tooltip: 'Select option for the file',
                        onSelected: (oldCallEnum _enum) async {
                          if (_enum == oldCallEnum.load) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    CallSessionPage(fileManager: FileManager.fromFile(oldCalls[index]))));
                          } else if (_enum == oldCallEnum.delete) {
                            await FileManager.deleteFile(oldCalls[index]);
                          }

                          // Trigger widget rebuilds
                          setState(() {});
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<oldCallEnum>(value: oldCallEnum.load, child: Text('Load')),
                            PopupMenuItem<oldCallEnum>(value: oldCallEnum.delete, child: Text('Delete'))
                          ];
                        }),
                    leading: selected.containsValue(true)
                        ? Checkbox(
                            value: selected[index] ?? false,
                            activeColor: Theme.of(context).buttonColor,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("No call sessions found.", style: Theme.of(context).textTheme.subtitle1),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => FileSelectorPage()));
                  },
                  child: Text("Start a Call Session"),
                )
              ],
            ),
          );
  }
}
