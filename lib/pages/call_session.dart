import 'package:flutter/material.dart';

import 'package:auto_call/services/calls_and_messages_service.dart';
import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/call_table.dart';
import 'package:auto_call/services/settings_manager.dart';

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
  double rowSize = kMinInteractiveDimension;
  FocusNode _focusNode;
  ScrollController _controller;

  // Getter for file manager from widget parent
  FileManager get fileManager => widget.fileManager;

  @override
  void initState() {
//    tableSource = CallTableSource(fileManager);
    _controller = ScrollController(keepScrollOffset: true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode?.dispose();
    _controller?.dispose();
  }

  Future<void> readFile() async {
    await fileManager.readFile();
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

    // Update the Widgets on this page
    setState(() {
      fileManager.phoneList.currentPerson().called = true;
    });
  }

  // Update the Scroll controller based on the given item offset
  void updateController(int iteratorOffset) {
    _controller.animateTo(
      _controller.offset + rowSize * iteratorOffset,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 500),
    );
  }

  void setStateIterator(int i) {
    setState(() {
      FocusScope.of(context).unfocus();

      // Only do a scroll update if the selected item is kinda far away, to avoid annoying scroll animations
      int desiredOffset = i - fileManager.phoneList.iterator;
      updateController(desiredOffset.abs() > 5 ? desiredOffset : 0);
      fileManager.phoneList.iterator = i;
    });
  }

  TextStyle calledTextColor(BuildContext context, bool called) {
    return TextStyle(color: called ? Theme.of(context).disabledColor : Theme.of(context).textTheme.body1.color);
  }

  TextStyle headerStyle(BuildContext context) {
    return TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.body1.color);
  }

  Future callTableFuture() async {
    if (fileManager.phoneList == null) {
      await fileManager.readFile();
    }
    return fileManager.phoneList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(context),
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: true,
        actions: <Widget>[
          SaveButton(fileManager: fileManager),
          IconButton(
            icon: Icon(Icons.cancel, color: Theme.of(context).accentColor),
            iconSize: 40.0,
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: callTableFuture(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return !snapshot.hasData
                ? Center(child: SizedBox(width: 50.0, height: 50.0, child: const CircularProgressIndicator()))
                : Stack(children: [
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                      Expanded(
                          child: SingleChildScrollView(
                        controller: _controller,
                        scrollDirection: Axis.vertical,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(children: <Widget>[
                                    DataTable(
                                      horizontalMargin: 0.0,
                                      columnSpacing: 10.0,
                                      dataRowHeight: rowSize,
                                      columns: [
                                            DataColumn(label: Text("", style: headerStyle(context)), numeric: false),
                                            DataColumn(label: Text("#", style: headerStyle(context)), numeric: false),
                                            DataColumn(
                                                label: Text("Name", style: headerStyle(context)), numeric: false),
                                            DataColumn(
                                                label: Text("Phone", style: headerStyle(context)), numeric: false),
                                          ] +
                                          List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
                                            return DataColumn(
                                                label: Text(fileManager.phoneList.additionalLabels[idx],
                                                    style: headerStyle(context)),
                                                numeric: false);
                                          }) +
                                          [
//            DataColumn(label: Text("Email", style: headerStyle(context)), numeric: false),
                                            DataColumn(
                                                label: Text("Note", style: headerStyle(context)), numeric: false),
                                            DataColumn(
                                                label: Text("Outcome", style: headerStyle(context)), numeric: false),
                                          ],
                                      rows: fileManager.phoneList.people
                                          .asMap()
                                          .map((i, person) => MapEntry(i, rowBuilder(context, i)))
                                          .values
                                          .toList(),
                                    ),
                                  ])),
                              Container(
                                  height: rowSize,
                                  alignment: Alignment.center,
                                  child: Text("End of Phone List", textAlign: TextAlign.center)),
                              Container(height: rowSize * 2.0)
                            ]),
                      )),
                    ]),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: fileManager.phoneList.isComplete()
                          ? Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Theme.of(context).backgroundColor.withOpacity(1.0),
                                        Theme.of(context).backgroundColor.withOpacity(0.0)
                                      ])),
                              child: FloatingActionButton.extended(
                                  label: Text('Calls Completed'),
                                  icon: Icon(Icons.check_circle),
                                  onPressed: () {
                                    print("call_session.dart: COMPLETED");
                                  }))
                          : Container(
//              padding: EdgeInsets.symmetric(vertical: 10.0),
                              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Theme.of(context).scaffoldBackgroundColor.withOpacity(1.0),
                                        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0)
                                      ])),
                              child: Row(
                                children: <Widget>[
                                  FloatingActionButton.extended(
                                    label: Text('Back'),
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      setState(() {
                                        int origIterator = fileManager.phoneList.iterator;
                                        fileManager.phoneList.reverseIterator();
                                        int offset = fileManager.phoneList.iterator - origIterator;
                                        updateController(offset);
                                      });
                                    },
                                    heroTag: "btn_back",
                                    tooltip: "Back",
                                  ),
                                  FloatingActionButton(
                                    onPressed: () {
//                                      makeCall();

                                      afterCallPrompt(context, fileManager.phoneList.iterator);

                                      setState(() {
                                        // Advance iterator and update the scroll controller
                                        int origIterator = fileManager.phoneList.iterator;
                                        fileManager.phoneList.advanceIterator();
                                        int offset = fileManager.phoneList.iterator - origIterator;
                                        updateController(offset);
                                      });
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
                                        int origIterator = fileManager.phoneList.iterator;
                                        fileManager.phoneList.advanceIterator();
                                        int offset = fileManager.phoneList.iterator - origIterator;
                                        updateController(offset);
                                      });
                                    },
                                    heroTag: "btn_next",
                                    tooltip: "Call",
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              )
                              // fill in required params
                              ),
                    )
                  ]);
          }),
    );
  }

//  Widget animatedTable(BuildContext context) {
//    return DataTable(
//      horizontalMargin: 0.0,
//      columnSpacing: 10.0,
//      dataRowHeight: rowSize,
//      columns: [
//            DataColumn(label: Text("", style: headerStyle(context)), numeric: false),
//            DataColumn(label: Text("#", style: headerStyle(context)), numeric: false),
//            DataColumn(label: Text("Name", style: headerStyle(context)), numeric: false),
//            DataColumn(label: Text("Phone", style: headerStyle(context)), numeric: false),
//          ] +
//          List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
//            return DataColumn(
//                label: Text(fileManager.phoneList.additionalLabels[idx], style: headerStyle(context)), numeric: false);
//          }) +
//          [
////            DataColumn(label: Text("Email", style: headerStyle(context)), numeric: false),
//            DataColumn(label: Text("Note", style: headerStyle(context)), numeric: false),
//            DataColumn(label: Text("Outcome", style: headerStyle(context)), numeric: false),
//          ],
//      rows:
//          fileManager.phoneList.people.asMap().map((i, person) => MapEntry(i, rowBuilder(context, i))).values.toList(),
//    );
//  }

  DataRow rowBuilder(BuildContext context, int i) {
    return DataRow.byIndex(
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
                                color: fileManager.phoneList.people[i].called
                                    ? Theme.of(context).accentColor
                                    : Theme.of(context).disabledColor),
                            onPressed: () {
                              setState(() {
                                fileManager.phoneList.people[i].called = !fileManager.phoneList.people[i].called;
                              });
                            }),
                  ),
                  placeholder: true,
                  onTap: () => setStateIterator(i)),
              DataCell(Text(i.toString(), style: calledTextColor(context, fileManager.phoneList.people[i].called)),
                  placeholder: false, onTap: () => setStateIterator(i)),
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
//                            SelectableText(fileManager.phoneList.people[i].email,
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
                        setState(() {
                          fileManager.phoneList.people[i].outcome = outcome;
                        });
                      },
//                                icon: Icon(Icons.arrow_downward),
//                                iconSize: 24,
                      elevation: 16,
                      items: <String>['None', 'Voicemail', 'Answered', 'Follow Up', 'Success']
                          .map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: calledTextColor(context, fileManager.phoneList.people[i].called)),
                          );
                        },
                      ).toList()),
                  onTap: () => setStateIterator(i)),
            ]);
  }

  void afterCallPrompt(BuildContext context, int i) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          title: Text("Call Completed to:"),
          content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(children: <Widget>[
                      ListTile(dense: true, contentPadding: EdgeInsets.all(0.0), title: Text("Name: "), trailing: Text("${fileManager.phoneList.people[i].name}")),
                      ListTile(dense: true, contentPadding: EdgeInsets.all(0.0), title: Text("Phone: "), trailing: Text("${fileManager.phoneList.people[i].phone}")),
                    ]),

                    Divider(),
                    TextFormField(
                      initialValue: fileManager.phoneList.people[i].note,
                      autofocus: false,
                      maxLines: 2,
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
                        setState(() {
                          fileManager.phoneList.people[i].note = text;
                        });
                        FocusScope.of(context).unfocus();
                      },
                      onFieldSubmitted: (String text) {
                        setState(() {
                          fileManager.phoneList.people[i].note = text;
                        });
                      },
                      decoration: InputDecoration(
                          labelText: "Note:", border: OutlineInputBorder(), hintText: 'Take a note here'),
                    ),
                    Divider(),
                    ListTile(
                      dense: true,
                      title: Text("Call Outcome:"),
                      trailing: DropdownButton<String>(
                          value: fileManager.phoneList.people[i].outcome,
                          onChanged: (String outcome) {
                            setState(() {
                              fileManager.phoneList.people[i].outcome = outcome;
                            });
                          },
                          elevation: 16,
                          items: <String>['None', 'Voicemail', 'Answered', 'Follow Up', 'Success']
                              .map<DropdownMenuItem<String>>(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            },
                          ).toList()),
                    ),
                  ]))),
          actions: <Widget>[
            FlatButton(
              child: Text("Done", style: Theme.of(context).accentTextTheme.button),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }
}

class SaveButton extends StatelessWidget {
  final FileManager fileManager;
  SaveButton({this.fileManager});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.save, color: Theme.of(context).accentColor),
      iconSize: 40.0,
      onPressed: () async {
        // Find the Scaffold in the widget tree and use
        // it to show a SnackBar.
        await fileManager.saveCallSession();
        await fileManager.saveToOldCalls();

        // Show the snack
        SnackBar snackBar = SnackBar(
          content: Text("File saved to " + await FileManager.savedFilePath(fileManager.path)),
          backgroundColor: Colors.grey[600],
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () async {
              // SDelete the files that were just saved
              await FileManager.deleteFile(await FileManager.savedFilePath(fileManager.path));
              await FileManager.deleteFile(await FileManager.oldCallsPath(fileManager.path));
            },
          ),
        );

        // Show the snackbar
        Scaffold.of(context).showSnackBar(snackBar);
      },
    );
  }
}
