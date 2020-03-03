import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/ui/drawer.dart';
//import 'package:auto_call/ui/call_table.dart';
import 'package:auto_call/services/calls_and_messages_service.dart';

class CallSessionPage extends StatefulWidget {
  static const String routeName = "/call_session";
  final String title = "Call Session";
  final String label = "Call Session";
  final FileManager fileManager;

  CallSessionPage({Key key, @required this.fileManager}) : super(key: key);

  @override
  CallSessionState createState() => new CallSessionState();
}

class CallSessionState extends State<CallSessionPage> {
  bool inCall = false;
  FocusNode _focusNode;

  // Getter for file manager from widget parent
  FileManager get fileManager => widget.fileManager;

  @override
  void initState() {
//    tableSource = CallTableSource(fileManager);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode?.dispose();
  }

  Future<bool> monitorCallState() async {
    // In Call prior to starting the call
    inCall = true;

    // Call the number
    locator.get<CallsAndMessagesService>().call(fileManager.phoneList.currentPerson().phone);
//    bool callComplete = await launchCall(fileManager.phoneList.currentPerson().number);
//    launchCall(fileManager.phoneList.currentPerson().phone);

//    if (inCall) {
//      // If we are in the call then we should not do anything right now
//
//    } else {
//      // If We are not in the call, then we need to do another call
//      locator.get<CallsAndMessagesService>().call(fileManager.phoneList.currentPerson().number);
//    }


    locator.get<CallsAndMessagesService>().call(fileManager.phoneList.currentPerson().phone);

    // report that the call is over
    return false;
  }

  void makeCall() async {
    inCall = true;
    inCall = await monitorCallState();

    // On Call completion
    fileManager.phoneList.currentPerson().called = true;
    fileManager.phoneList.advanceIterator();

    // Update the Widgets on this page
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                      fileManager.phoneList.reverseIterator();
                      setState(() {});
                    },
                    heroTag: "btn_back",
                    tooltip: "Back",
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      makeCall()  ;
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
                      fileManager.phoneList.advanceIterator();
                      setState(() {});
                    },
                    heroTag: "btn_next",
                    tooltip: "Call",
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
        fontSize: 18.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.body1.color);
  }

  void setStateIterator(int i) {
    setState(() {
      FocusScope.of(context).unfocus();
      fileManager.phoneList.iterator = i;
    });
  }

  Widget animatedTable(BuildContext context) {
    return DataTable(
//      source: tableSource,
//      header: Container(),
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
            DataColumn(label: Text("Note", style: headerStyle(context)), numeric: false),
            DataColumn(label: Text("Outcome", style: headerStyle(context)), numeric: false),
          ],
      rows: fileManager.phoneList.people
          .asMap()
          .map((i, person) => MapEntry(
              i,
              DataRow.byIndex(
                  index: i,
                  selected: i == fileManager.phoneList.iterator ? true : false,
                  cells: [
                        DataCell(
                            Container(
                              width: 50.0,
                              alignment: Alignment.center,
                              child: i == fileManager.phoneList.iterator
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
                      ] +
                      List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
                        return DataCell(
                            Text(fileManager.phoneList.people[i].additionalData[idx],
                                style: calledTextColor(context, fileManager.phoneList.people[i].called)),
                            onTap: () => setStateIterator(i));
                      }) +
                      [
//                        DataCell(
//                            Text(fileManager.phoneList.people[i].email,
//                                style: calledTheme(fileManager.phoneList.people[i].called)), onTap: () {
//                          setState(() {
//                            fileManager.phoneList.iterator = i;
//                          });
//                        }),
                        DataCell(
                            TextFormField(
                              initialValue: fileManager.phoneList.people[i].note,
                              autofocus: false,
                              onChanged: (String text) {
                                fileManager.phoneList.people[i].note = text;
                              },
                              onTap: () {
                                FocusScope.of(context).requestFocus(_focusNode);
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                              },
                              onSaved: (String text) {
                                fileManager.phoneList.people[i].note = text;
                                FocusScope.of(context).unfocus();
                              },
                              decoration: InputDecoration(
                                  hintStyle: calledTextColor(context, fileManager.phoneList.people[i].called),
                                  labelStyle: calledTextColor(context, fileManager.phoneList.people[i].called),
                                  border: InputBorder.none,
                                  hintText: '..........'),
                            ),
                            onTap: () => setStateIterator(i)),
                        DataCell(
                            DropdownButton<String>(
                                value: fileManager.phoneList.people[i].outcome,
                                onChanged: (String outcome) {
                                  fileManager.phoneList.people[i].outcome = outcome;
                                  setState(() {});
                                },
//                                icon: Icon(Icons.arrow_downward),
//                                iconSize: 24,
                                elevation: 16,
                                items: <String>['None', 'Voicemail', 'Answered', 'Success', 'Follow Up']
                                    .map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList()),
                            onTap: () => setStateIterator(i)),
                      ])))
          .values
          .toList(),
    );
  }
}

//class CallTableSource extends DataTableSource {
//  final FileManager fileManager;
//  CallTableSource(this.fileManager);
//
////  void _sort<T>(Comparable<T> getField(Result d), bool ascending) {
////    _results.sort((Result a, Result b) {
////      if (!ascending) {
////        final Result c = a;
////        a = b;
////        b = c;
////      }
////      final Comparable<T> aValue = getField(a);
////      final Comparable<T> bValue = getField(b);
////      return Comparable.compare(aValue, bValue);
////    });
////    notifyListeners();
////  }
//
//  int _selectedCount = 0;
//
//  @override
//  DataRow getRow(int i) {
//    assert(i >= 0);
//    if (i >= fileManager.phoneList.people.length) return null;
//    final Person person = fileManager.phoneList.people[i];
//    return DataRow.byIndex(
//        index: i,
//        selected: i == fileManager.phoneList.iterator ? true : false,
//        cells: [
//          DataCell(
//            Container(
//              width: 50.0,
//              alignment: Alignment.center,
//              child: i == fileManager.phoneList.iterator
//                  ? Icon(Icons.forward)
//                  : IconButton(
//                  icon: Icon(Icons.check_circle,
//                      color: calledIconColor(fileManager.phoneList.people[i].called)),
//                  onPressed: () {
//                    fileManager.phoneList.people[i].called =
//                    !fileManager.phoneList.people[i].called;
//                    notifyListeners();
//                  }),
//            ),
//            placeholder: true,
////                            onTap: () => setStateIterator(i),
//          ),
//          DataCell(
//            Text(i.toString(), style: calledTextColor(fileManager.phoneList.people[i].called)),
//            placeholder: false,
////                            onTap: () => setStateIterator(i),
//          ),
//          DataCell(
//            Text(fileManager.phoneList.people[i].name,
//                style: calledTextColor(fileManager.phoneList.people[i].called)),
////                            onTap: () => setStateIterator(i),
//          ),
//          DataCell(
//            Text(fileManager.phoneList.people[i].phone,
//                style: calledTextColor(fileManager.phoneList.people[i].called)),
////                            onTap: () => setStateIterator(i),
//          ),
////                        DataCell(
////                            Text(fileManager.phoneList.people[i].email,
////                                style: calledTheme(fileManager.phoneList.people[i].called)), onTap: () {
////                          setState(() {
////                            fileManager.phoneList.iterator = i;
////                          });
////                        }),
//        ] +
//            List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
//              return DataCell(
//                Text(fileManager.phoneList.people[i].additionalData[idx],
//                    style: calledTextColor(fileManager.phoneList.people[i].called)),
////                            onTap: () => setStateIterator(i),
//              );
//            }) +
//            [
//              DataCell(
//                TextFormField(
//                  autofocus: false,
//                  onChanged: (String text) {
//                    fileManager.phoneList.people[i].note = text;
////                                FocusScope.of(context).unfocus();
//                  },
////                              onTap: () {
////                                FocusScope.of(context).requestFocus(_focusNode);
////                              },
////                              onEditingComplete: () {
////                                FocusScope.of(context).unfocus();
////                              },
////                              onSaved: (String text) {
////                                fileManager.phoneList.people[i].note = text;
////                                FocusScope.of(context).unfocus();
////                              },
//                  decoration: InputDecoration(
//                      hintStyle: calledTextColor(fileManager.phoneList.people[i].called),
//                      labelStyle: calledTextColor(fileManager.phoneList.people[i].called),
//                      border: InputBorder.none,
//                      hintText: '..........'),
//                ),
////                            Text(fileManager.phoneList.people[i].note,
////                                style: calledTheme(fileManager.phoneList.people[i].called)),
////                            onTap: () => setStateIterator(i),
//              ),
//              DataCell(
//                DropdownButton<String>(
//                    value: fileManager.phoneList.people[i].outcome,
//                    onChanged: (String outcome) {
//                      fileManager.phoneList.people[i].outcome = outcome;
//                    },
////                                icon: Icon(Icons.arrow_downward),
////                                iconSize: 24,
//                    elevation: 16,
//                    items: <String>['None', 'Voicemail', 'Answered', 'Success', 'Follow Up']
//                        .map<DropdownMenuItem<String>>(
//                          (String value) {
//                        return DropdownMenuItem<String>(
//                          value: value,
//                          child: Text(value),
//                        );
//                      },
//                    ).toList()),
////                            onTap: () => setStateIterator(i),
//              ),
////                        DataCell(
////                          Text(fileManager.phoneList.people[i].outcome,
////                              style: calledTextColor(context, fileManager.phoneList.people[i].called)),
////                          onTap: () => setStateIterator(i),
////                        ),
//            ]);
//
//  }
//
//  @override
//  int get rowCount => fileManager.phoneList.people.length;
//
//  @override
//  bool get isRowCountApproximate => false;
//
//  @override
//  int get selectedRowCount => _selectedCount;
//
//  TextStyle calledTextColor(bool called) {
//    return TextStyle(color: Colors.white);
////    return TextStyle(color: called ? Theme.of(context).disabledColor : Theme.of(context).textTheme.body1.color);
//  }
//
//  Color calledIconColor(bool called) {
//    return Colors.white;
////    return called ? Theme.of(context).accentColor : Theme.of(context).disabledColor;
//  }
//
////  void _selectAll(bool checked) {
////    for (Person person in phoneList.people) person.selected = checked;
////    _selectedCount = checked ? phoneList.people.length : 0;
////    notifyListeners();
////  }
//}

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
          content: Text("File saved to " + await FileManager.savedFilePath(fileManager.path)),
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
        await fileManager.saveToOldCalls();
      },
    );
  }
}

