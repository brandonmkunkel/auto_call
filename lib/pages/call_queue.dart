import 'package:flutter/material.dart';

import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/services/calls_and_messages_service.dart';

class CallQueuePage extends StatefulWidget {
  static String routeName = "/call_queue";
  final String title = "Call Queue";

  @override
  CallQueueState createState() => new CallQueueState();
}

class CallQueueState extends State<CallQueuePage> {
  final double _titleFontSize = 18.0;
  final double _fontSize = 18.0;
  int firstUncalled = 0;
  int lastUncalled = 0;
  int iterator = 0;
  bool complete = false;
  bool inCall = false;
  FileManager fileManager;

  void changeCallState() async {
    // Call the number
    locator.get<CallsAndMessagesService>().call(fileManager.phoneList.people[iterator].number);
//    bool callComplete = await launchCall(fileManager.phoneList.people[iterator].number);
    launchCall(fileManager.phoneList.people[iterator].number);

//    if (inCall) {
//      // If we are in the call then we should not do anything right now
//
//    } else {
//      // If We are not in the call, then we need to do another call
//      locator.get<CallsAndMessagesService>().call(fileManager.phoneList.people[iterator].number);
//    }

    locator.get<CallsAndMessagesService>().call(fileManager.phoneList.people[iterator].number);

    setState(() {
//      inCall = !inCall;

      fileManager.phoneList.people[iterator].called = true;
      nextCall();
    });
  }

  void checkCallState() {
    firstUncalled = fileManager.phoneList.people.indexWhere((Person p) {
      return !p.called;
    });
    lastUncalled = fileManager.phoneList.people.lastIndexWhere((Person p) {
      return !p.called;
    });

    if (firstUncalled == -1 && lastUncalled == -1) {
      complete = true;
      iterator = -1;
    }
  }

  void advanceIterator() {
    int nextIterator = iterator + 1;

    // Check to see if the next call is the last
    if (nextIterator > lastUncalled) {
      nextIterator = firstUncalled;
    } else if (fileManager.phoneList.people[nextIterator].called) {
      // If the Next entry has been called already, skip
      if (nextIterator > lastUncalled) {
        nextIterator = firstUncalled;
      } else {
        while (fileManager.phoneList.people[nextIterator].called) {
          nextIterator++;
        }
      }
    }

    iterator = nextIterator;
  }

  void nextCall() {
    checkCallState();
    advanceIterator();
  }

  @override
  Widget build(BuildContext context) {
    fileManager = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        drawer: AppDrawer(context),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save, color: Theme.of(context).buttonColor),
              iconSize: 40.0,
              onPressed: () async {
                await fileManager.saveFile();
              },
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: Theme.of(context).buttonColor),
              iconSize: 40.0,
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: Text(widget.title),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      animatedTable(context),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                  child: Center(
                      child: Row(
                    children: <Widget>[
                      FloatingActionButton.extended(
                        label: Text('Back'),
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            iterator > 0 ? iterator-- : iterator = 0;
                          });
                        },
                        heroTag: "btn_back",
                        tooltip: "Back",
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          changeCallState();
                        },
                        heroTag: "btn_call",
                        tooltip: "Call",
                        child: inCall ? Icon(Icons.cancel) : Icon(Icons.call),
                        backgroundColor: inCall ? Colors.red : Theme.of(context).accentColor,
                      ),
                      FloatingActionButton.extended(
                        label: Text('Next'),
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          setState(() {
                            checkCallState();
                            advanceIterator();
                          });
                        },
                        heroTag: "btn_next",
                        tooltip: "Next Call",
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ))
                  // fill in required params
                  ),
            ],
          ),
        );
  }

  TextStyle calledTheme(bool called) {
    return TextStyle(
      color: called ? Colors.grey[500] : Colors.black,
    );
  }

  Widget animatedTable(BuildContext context) {
    TextStyle headerStyle = TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold);

    return DataTable(
      horizontalMargin: 0.0,
      columnSpacing: 10.0,
      columns: [
            DataColumn(
              label: Text("", style: headerStyle),
              numeric: false,
            ),
//            DataColumn(
//              label: Text("", style: TextStyle(fontSize: _titleFontSize)),
//              numeric: true,
//            ),
            DataColumn(
              label: Text("#", style: headerStyle),
              numeric: false,
            ),
            DataColumn(
                label: Text("Name", style: headerStyle),
                numeric: false),
            DataColumn(
                label: Text("Phone", style: headerStyle),
                numeric: false),
//        DataColumn(
//            label: Text("Called", style: headerStyle),
//            numeric: false),
            DataColumn(
                label: Text("Comment", style: headerStyle),
                numeric: false),
            DataColumn(
                label: Text("Outcome", style: headerStyle),
                numeric: false),
          ] +
          List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
            return DataColumn(
                label: Text(fileManager.phoneList.additionalLabels[idx], style: headerStyle),
                numeric: false);
          }),
      rows: fileManager.phoneList.people
          .asMap()
          .map((i, person) => MapEntry(
              i,
              DataRow.byIndex(
                  index: i,
                  selected: i == iterator ? true : false,
//                  onSelectChanged: (bool selected) {
//                    if (selected) {
//                      iterator=i;
//                      selected = selected;
//                    }
//                  },
                  cells: [
                        DataCell(
                            Container(
                              width: 50.0,
                              alignment: Alignment.center,
                              child: i == iterator
                                  ? Icon(Icons.forward)
                                  : IconButton(
                                      icon: fileManager.phoneList.people[i].called
                                          ? Icon(Icons.check_circle, color: Colors.green)
                                          : Icon(Icons.check_circle, color: Colors.grey[300]),
                                      onPressed: () {
                                        setState(() {
                                          fileManager.phoneList.people[i].called = !fileManager.phoneList.people[i].called;
                                        });
                                      }),
                            ),
                            placeholder: true, onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
//                        DataCell(Checkbox(
//                            value: fileManager.phoneList.people[i].called,
//                            onChanged: (bool value) {
//                              setState(() {
//                                fileManager.phoneList.people[i].called = value;
//                              });
//                            })),

                        DataCell(Text(i.toString(), style: calledTheme(fileManager.phoneList.people[i].called)), placeholder: false,
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                        DataCell(Text(fileManager.phoneList.people[i].name, style: calledTheme(fileManager.phoneList.people[i].called)),
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                        DataCell(Text(fileManager.phoneList.people[i].number, style: calledTheme(fileManager.phoneList.people[i].called)),
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                        DataCell(Text(fileManager.phoneList.people[i].comment, style: calledTheme(fileManager.phoneList.people[i].called)),
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                        DataCell(Text(fileManager.phoneList.people[i].outcome, style: calledTheme(fileManager.phoneList.people[i].called)),
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                      ] +
                      List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
                        return DataCell(
                            Text(
                                fileManager.phoneList
                                    .people[i].additionalData[fileManager.phoneList.labelMapping[fileManager.phoneList.additionalLabels[idx]]],
                                style: calledTheme(fileManager.phoneList.people[i].called)), onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        });
                      }))))
          .values
          .toList(),
    );
  }
}
