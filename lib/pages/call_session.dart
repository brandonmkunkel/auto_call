import 'package:flutter/material.dart';

import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/ui/drawer.dart';
//import 'package:auto_call/ui/call_table.dart';
import 'package:auto_call/services/calls_and_messages_service.dart';

class CallSessionPage extends StatefulWidget {
  static String routeName = "/call_queue";
  final String title = "Call Queue";
  final String label = "Call Queue";
  FileManager fileManager;

  CallSessionPage({Key key, @required this.fileManager}) : super(key: key);

  @override
  CallSessionState createState() => new CallSessionState();
}

class CallSessionState extends State<CallSessionPage> {
  final double _titleFontSize = 18.0;
  final double _fontSize = 18.0;
  int firstUncalled = 0;
  int lastUncalled = 0;
  int iterator = 0;
  bool complete = false;
  bool inCall = false;
  FileManager fileManager;

  FocusNode _focusNode;
  List<FocusNode> _focusNodeList = [];

  @override
  void initState() {
    super.initState();
    _focusNodeList = [];
//    _focusNode = FocusNode();
//    _focusNode.addListener(() {
////      print("_focusNode.hasFocus");
//    });
  }

  @override
  void dispose() {
    super.dispose();
//    _focusNode.dispose();

    for (var node in _focusNodeList) {
      node.dispose();
    }
  }

  void changeCallState() async {
    // Call the number
    locator.get<CallsAndMessagesService>().call(fileManager.phoneList.people[iterator].phone);
//    bool callComplete = await launchCall(fileManager.phoneList.people[iterator].number);
    launchCall(fileManager.phoneList.people[iterator].phone);

//    if (inCall) {
//      // If we are in the call then we should not do anything right now
//
//    } else {
//      // If We are not in the call, then we need to do another call
//      locator.get<CallsAndMessagesService>().call(fileManager.phoneList.people[iterator].number);
//    }

    locator.get<CallsAndMessagesService>().call(fileManager.phoneList.people[iterator].phone);

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
          SaveButton(fileManager: fileManager),
//          IconButton(
//            icon: Icon(Icons.save, color: Theme.of(context).buttonColor),
//            iconSize: 40.0,
//            onPressed: () async {
////              savedSnackBar(context);
////              await fileManager.savePhoneList();
//            },
//          ),
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
              scrollDirection: Axis.horizontal,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
//                      child: CallTable(),
                      child: animatedTable(context),
                    )
                  ]),
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

  TextStyle calledTextColor(BuildContext context, bool called) {
    return TextStyle(color: called ? Theme.of(context).disabledColor : Theme.of(context).textTheme.body1.color);
  }

  Color calledIconColor(buildContext, bool called) {
    return called ? Theme.of(context).accentColor : Theme.of(context).disabledColor;
  }

  TextStyle headerStyle(BuildContext context) {
    return TextStyle(
        fontSize: _titleFontSize, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.body1.color);
  }

  void setStateIterator(int i) {
    setState(() {
      iterator = i;
    });
  }

  Widget animatedTable(BuildContext context) {
    return DataTable(
      horizontalMargin: 0.0,
      columnSpacing: 10.0,
      columns: [
            DataColumn(label: Text("", style: headerStyle(context)), numeric: false),
            DataColumn(label: Text("#", style: headerStyle(context)), numeric: false),
            DataColumn(label: Text("Name", style: headerStyle(context)), numeric: false),
            DataColumn(label: Text("Phone", style: headerStyle(context)), numeric: false),
          ] +
          List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
            return DataColumn(
                label: Text(fileManager.phoneList.additionalLabels[idx], style: headerStyle(context)), numeric: false);
          }) +
          [
//            DataColumn(label: Text("Email", style: headerStyle(context)), numeric: false),
            DataColumn(label: Text("Comment", style: headerStyle(context)), numeric: false),
            DataColumn(label: Text("Outcome", style: headerStyle(context)), numeric: false),
          ],
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
                                      icon: Icon(Icons.check_circle,
                                          color: calledIconColor(context, fileManager.phoneList.people[i].called)),
                                      onPressed: () {
                                        setState(() {
                                          fileManager.phoneList.people[i].called =
                                              !fileManager.phoneList.people[i].called;
                                        });
                                      }),
                            ),
                            placeholder: true,
                            onTap: () => setStateIterator(i)),
//                        DataCell(Checkbox(
//                            value: fileManager.phoneList.people[i].called,
//                            onChanged: (bool value) {
//                              setState(() {
//                                fileManager.phoneList.people[i].called = value;
//                              });
//                            })),

                        DataCell(
                            Text(i.toString(), style: calledTextColor(context, fileManager.phoneList.people[i].called)),
                            placeholder: false,
                            onTap: () => setStateIterator(i)),
                        DataCell(
                            Text(fileManager.phoneList.people[i].name,
                                style: calledTextColor(context, fileManager.phoneList.people[i].called)),
                            onTap: () => setStateIterator(i)),
                        DataCell(
                            Text(fileManager.phoneList.people[i].phone,
                                style: calledTextColor(context, fileManager.phoneList.people[i].called)),
                            onTap: () => setStateIterator(i)),
//                        DataCell(
//                            Text(fileManager.phoneList.people[i].email,
//                                style: calledTheme(fileManager.phoneList.people[i].called)), onTap: () {
//                          setState(() {
//                            iterator = i;
//                          });
//                        }),
                      ] +
                      List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
                        return DataCell(
                            Text(fileManager.phoneList.people[i].additionalData[idx],
                                style: calledTextColor(context, fileManager.phoneList.people[i].called)),
                            onTap: () => setStateIterator(i));
                      }) +
                      [
                        DataCell(
                            TextFormField(
                              autofocus: false,
//                              onChanged: (String text) {
//                                fileManager.phoneList.people[i].comment = text;
//                                FocusScope.of(context).unfocus();
//                              },
                              onTap: () {
                                FocusScope.of(context).requestFocus(_focusNode);
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                              },
                              onSaved: (String text) {
                                fileManager.phoneList.people[i].comment = text;
                                FocusScope.of(context).unfocus();
                              },
                              decoration: InputDecoration(
                                  hintStyle: calledTextColor(context, fileManager.phoneList.people[i].called),
                                  labelStyle: calledTextColor(context, fileManager.phoneList.people[i].called),
                                  border: InputBorder.none,
                                  hintText: '..................'),
                            ),
//                            Text(fileManager.phoneList.people[i].comment,
//                                style: calledTheme(fileManager.phoneList.people[i].called)),
                            onTap: () => setStateIterator(i)),
                        DataCell(
                            Text(fileManager.phoneList.people[i].outcome,
                                style: calledTextColor(context, fileManager.phoneList.people[i].called)),
                            onTap: () => setStateIterator(i)),
                      ])))
          .values
          .toList(),
    );
  }
}

class SaveButton extends StatelessWidget {
  final FileManager fileManager;
  SaveButton({this.fileManager});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.save, color: Theme.of(context).buttonColor),
      iconSize: 40.0,
      onPressed: () async {
        SnackBar snackBar = SnackBar(
//          content: Text("Saved file to" + FileManager.updatedFilePath(fileManager.path)),
          content: Text("File saved to "+ await FileManager.savedFilePath(fileManager.path)),
          backgroundColor: Colors.grey[600],
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );

        // Find the Scaffold in the widget tree and use
        // it to show a SnackBar.
        Scaffold.of(context).showSnackBar(snackBar);
        await fileManager.saveCallSession();
      },
    );
  }
}

class AfterCallPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
