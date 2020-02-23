import 'package:flutter/material.dart';

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
  PhoneList callList;

  @override
  void initState() {
    super.initState();
  }

  void changeCallState() async {
    // Call the number
    locator.get<CallsAndMessagesService>().call(callList.people[iterator].number);
//    bool callComplete = await launchCall(callList.people[iterator].number);
    launchCall(callList.people[iterator].number);

//    if (inCall) {
//      // If we are in the call then we should not do anything right now
//
//    } else {
//      // If We are not in the call, then we need to do another call
//      locator.get<CallsAndMessagesService>().call(callList.people[iterator].number);
//    }

    locator.get<CallsAndMessagesService>().call(callList.people[iterator].number);

    setState(() {
//      inCall = !inCall;

      callList.people[iterator].called = true;
      nextCall();
    });
  }

  void checkCallState() {
    firstUncalled = callList.people.indexWhere((Person p) {return !p.called;});
    lastUncalled = callList.people.lastIndexWhere((Person p) {return !p.called;});

    if (firstUncalled == -1 && lastUncalled == -1) {
      complete = true;
      print("Calls are complete yo");
    }
  }

  void nextCall() {
    checkCallState();

    if (iterator == callList.people.length-1) {
      iterator = firstUncalled;
    } else if (callList.people[iterator].called) {
      if (iterator >= lastUncalled) {
        iterator = firstUncalled;
      } else {
        while (callList.people[iterator].called) {
          iterator++;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    callList = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        drawer: AppDrawer(context),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
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
        body: Center(
          child: Column(
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
                            iterator < callList.people.length - 1 ? iterator++ : iterator = callList.people.length - 1;

                            checkCallState();

                            if (iterator == callList.people.length-1) {
                              iterator = firstUncalled;
                            } else if (callList.people[iterator].called) {
                              if (iterator >= lastUncalled) {
                                iterator = firstUncalled;
                              } else {
                                while (callList.people[iterator].called) {
                                  iterator++;
                                }
                              }
                            }
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
        ));
  }

  TextStyle calledTheme(bool called) {
    return TextStyle(
      color: called ? Colors.grey[500] : Colors.black,
    );
  }

  Widget animatedTable(BuildContext context) {
    return DataTable(
      horizontalMargin: 10.0,
      columnSpacing: 10.0,
      columns: [
            DataColumn(
              label: Text("", style: TextStyle(fontSize: _titleFontSize)),
              numeric: false,
            ),
//            DataColumn(
//              label: Text("", style: TextStyle(fontSize: _titleFontSize)),
//              numeric: true,
//            ),
            DataColumn(
              label: Text("#", style: TextStyle(fontSize: _titleFontSize)),
              numeric: true,
            ),
            DataColumn(
                label: Text("Name", style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold)),
                numeric: false),
            DataColumn(
                label: Text("Phone", style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold)),
                numeric: false),
//        DataColumn(
//            label: Text("Called", style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold)),
//            numeric: false),
            DataColumn(
                label: Text("Comment", style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold)),
                numeric: false),
            DataColumn(
                label: Text("Outcome", style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold)),
                numeric: false),
          ] +
          List.generate(callList.additionalLabels.length, (int idx) {
            return DataColumn(
                label: Text(callList.additionalLabels[idx],
                    style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold)),
                numeric: false);
          }),
      rows: callList.people
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
//                              width: 25.0,
                              child: i == iterator ? Icon(Icons.forward) : IconButton(
                                  icon: callList.people[i].called ? Icon(Icons.check_circle, color: Colors.green,) : Icon(Icons.check_circle, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      callList.people[i].called = !callList.people[i].called;
                                    });
                                  }),
                            ),
                            placeholder: true, onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
//                        DataCell(Checkbox(
//                            value: callList.people[i].called,
//                            onChanged: (bool value) {
//                              setState(() {
//                                callList.people[i].called = value;
//                              });
//                            })),

                        DataCell(Text(i.toString(), style: calledTheme(callList.people[i].called)), placeholder: false,
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                        DataCell(Text(callList.people[i].name, style: calledTheme(callList.people[i].called)),
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                        DataCell(Text(callList.people[i].number, style: calledTheme(callList.people[i].called)),
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                        DataCell(Text(callList.people[i].comment, style: calledTheme(callList.people[i].called)),
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                        DataCell(Text(callList.people[i].outcome, style: calledTheme(callList.people[i].called)),
                            onTap: () {
                          setState(() {
                            iterator = i;
                          });
                        }),
                      ] +
                      List.generate(callList.additionalLabels.length, (int idx) {
                        return DataCell(
                            Text(
                                callList
                                    .people[i].additionalData[callList.labelMapping[callList.additionalLabels[idx]]],
                                style: calledTheme(callList.people[i].called)), onTap: () {
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
