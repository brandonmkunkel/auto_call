import 'package:flutter/material.dart';

import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/services/calls_and_messages_service.dart';
import 'package:auto_call/services/streamline_call_services.dart';
import 'package:auto_call/services/animated_table.dart';

class CallQueuePage extends StatefulWidget {
  static String routeName = "/call_queue";
  final String title = "Call Queue";

  @override
  CallQueueState createState() => new CallQueueState();
}

class CallQueueState extends State<CallQueuePage> {
  final double _titleFontSize = 18.0;
  final double _fontSize = 18.0;
  int iterator = 0;
  bool inCall = false;
  PhoneList callList;
  Widget table;

  @override
  void initState() {
    super.initState();
  }

  void changeCallState() async {
    // Call the number
    locator.get<CallsAndMessagesService>().call(callList.people[iterator].number);
//    bool callComplete = await launchCall(callList.people[iterator].number);
//    launchCall(callList.people[iterator].number);

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

  void nextCall() {
    if (iterator < callList.people.length) {
      iterator++;
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      animatedTable(context),
//                    otherAnimatedTable(context),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                  child: Center(
                      child: Row(
                    children: <Widget>[
                      FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              iterator > 0 ? iterator-- : iterator = 0;
                            });
                          },
                          heroTag: "btn_back",
                          tooltip: "Back",
                          child: Icon(Icons.arrow_back)),
                      FloatingActionButton(
                        onPressed: () {
                          changeCallState();
                        },
                        heroTag: "btn_call",
                        tooltip: "Call",
                        child: inCall ? Icon(Icons.cancel) : Icon(Icons.call),
                        backgroundColor: inCall ? Colors.red : Theme.of(context).accentColor,
                      ),
                      FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              iterator < callList.people.length - 1
                                  ? iterator++
                                  : iterator = callList.people.length - 1;
                            });
                          },
                          heroTag: "btn_forward",
                          tooltip: "Forward",
                          child: Icon(Icons.arrow_forward)),
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

  Widget animatedTable(BuildContext context) {
    return DataTable(
      horizontalMargin: 16.0,
      columnSpacing: 16.0,
      columns: [
        DataColumn(
          label: Text("", style: TextStyle(fontSize: _titleFontSize)),
          numeric: false,
        ),

        DataColumn(
          label: Text("#", style: TextStyle(fontSize: _titleFontSize)),
          numeric: true,
        ),
        DataColumn(
            label: Expanded(
              child: Text("Name", style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold)),
            ),
            numeric: false),
        DataColumn(
            label:
                Expanded(child: Text("Phone", style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold))),
            numeric: false),
        DataColumn(
            label: Text("Called", style: TextStyle(fontSize: _titleFontSize, fontWeight: FontWeight.bold)),
            numeric: false),
      ],
      rows: callList.people
          .asMap()
          .map((i, person) => MapEntry(
              i,
              DataRow.byIndex(index: i, selected: i == iterator ? true : false,
//                  onSelectChanged: (bool selected) {
//                    if (selected) {
//                      iterator=i;
////                    selected = selected;
////                    log.add('row-selected: ${itemRow.index}');
//                    }
//                  },
                  cells: [
                    DataCell(
                        Container(
                          width: 10.0,
                          child: i == iterator ? Icon(Icons.forward) : Icon(null),
                        ),
                        placeholder: true, onTap: () {
                      setState(() {
                        iterator = i;
                      });
                    }),
                    DataCell(Text(i.toString(), style: Theme.of(context).textTheme.body1), placeholder: false,
                        onTap: () {
                      setState(() {
                        iterator = i;
                      });
                    }),
                    DataCell(Text(this.callList.people[i].name, style: Theme.of(context).textTheme.body1), onTap: () {
                      setState(() {
                        iterator = i;
                      });
                    }),
                    DataCell(Text(this.callList.people[i].number, style: Theme.of(context).textTheme.body1), onTap: () {
                      setState(() {
                        iterator = i;
                      });
                    }),
                    DataCell(Checkbox(
                        value: this.callList.people[i].called,
                        onChanged: (bool value) {
                          setState(() {
                            this.callList.people[i].called = value;
                          });
                        })),
                  ])))
          .values
          .toList(),
    );
  }

}
