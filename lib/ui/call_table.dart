import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/settings_manager.dart';
import 'package:auto_call/ui/prompts/pre_session_prompt.dart';
import 'package:auto_call/ui/widgets/call_table_widgets.dart';

class CallTable extends StatefulWidget {
  final ScrollController scrollController;
  final FileManager manager;
  final List<TextEditingController> textControllers;
  final List<bool> acceptedColumns;

  CallTable(
      {Key key,
      @required this.manager,
      @required this.scrollController,
      @required this.textControllers,
      this.acceptedColumns})
      : super(key: key);

  @override
  _CallTableState createState() => _CallTableState();
}

class _CallTableState extends State<CallTable> {
  bool showCallNotes = false;
  bool additionalColumns = false;
  bool editColumns = false;
  List<bool> acceptedColumns = [];
  double rowSize = kMinInteractiveDimension;
  List<FocusNode> focusNodes = [];

  // Getter for the FileManager
  FileManager get fileManager => widget.manager;

  @override
  void initState() {
    for (int idx = 0; idx < fileManager.phoneList.people.length; idx++) {
      // Text Editors for tracking text and passing between widgets
      widget.textControllers.add(TextEditingController(text: fileManager.phoneList.people[idx].note));

      // Focus Nodes for focusing on text editing
      focusNodes.add(FocusNode());
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    focusNodes.forEach((focusNode) => focusNode?.dispose());
  }

  // Update the Scroll controller based on the given item offset
  void updateController(int iteratorOffset) {
    widget.scrollController.animateTo(
      widget.scrollController.offset + rowSize * iteratorOffset,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 400),
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

  @override
  Widget build(BuildContext context) {
    // Get Additional Settings for the call table from the SettingsManager
    showCallNotes = globalSettingManager.getSetting("showNotes");
    additionalColumns =
        globalSettingManager.isPremium() ? globalSettingManager.getSetting("additionalColumns") : false;

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Expanded(
          child: SingleChildScrollView(
        controller: widget.scrollController,
        scrollDirection: Axis.vertical,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: <Widget>[
                    DataTable(
                      horizontalMargin: showCallNotes || additionalColumns ? 0.0 : 20.0,
                      columnSpacing: showCallNotes || additionalColumns ? 10.0 : 30.0,
                      dataRowHeight: rowSize,
                      columns: [
                            DataColumn(label: HeaderText("#"), numeric: true),
                            DataColumn(label: HeaderText("Name"), numeric: false),
                            DataColumn(label: HeaderText("Phone"), numeric: false),
                          ] +

                          // Use additionalColumns to add user columns
                          (additionalColumns
                              ? List.generate(
                                  fileManager.phoneList.additionalLabels.length,
                                  (int idx) => DataColumn(
                                      label: HeaderText(fileManager.phoneList.additionalLabels[idx]), numeric: false))
                              : []) +

                          // Use bareMinimum to hide the call Note and Result
                          (showCallNotes
                              ? [
                                  DataColumn(label: HeaderText("Note"), numeric: false),
                                  DataColumn(label: HeaderText("Result"), numeric: false),
                                ]
                              : []),
                      rows: List<DataRow>.generate(fileManager.phoneList.people.length, (i) => rowBuilder(context, i)),
                    ),
                  ])),
              Container(
                  height: rowSize,
                  alignment: Alignment.center,
                  child: Text("End of Phone List", textAlign: TextAlign.center)),
              Container(height: rowSize * 1.5)
            ]),
      )),
    ]);
  }

  DataRow rowBuilder(BuildContext context, int i) {
    return DataRow.byIndex(
        index: i,
        selected: i == fileManager.phoneList.iterator ? true : false,
        cells: [
              DataCell(
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    i == fileManager.phoneList.iterator
                        ? SizedBox(
                            width: 36.0,
                            child: Icon(
                              Icons.forward,
                              color: Theme.of(context).iconTheme.color,
                            ))
                        : SizedBox(
                            width: 36.0,
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: Icon(Icons.check_circle,
                                    color: fileManager.phoneList.people[i].called
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).disabledColor),
                                onPressed: () {
                                  setState(() {
                                    fileManager.phoneList.people[i].called = !fileManager.phoneList.people[i].called;
                                  });
                                })),
                    CalledText(text: (i + 1).toString(), called: fileManager.phoneList.people[i].called)
                  ]),
                  onTap: () => setStateIterator(i)),
              DataCell(
                  CalledText(
                      text: fileManager.phoneList.people[i].name, called: fileManager.phoneList.people[i].called),
                  onTap: () => setStateIterator(i)),
              DataCell(
                  CalledText(
                      text: fileManager.phoneList.people[i].phone, called: fileManager.phoneList.people[i].called),
                  onTap: () => setStateIterator(i)),
            ] +

            // Additional Columns
            (additionalColumns
                ? List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
                    return DataCell(
                        CalledText(
                            text: fileManager.phoneList.people[i].additionalData[idx],
                            called: fileManager.phoneList.people[i].called),
                        onTap: () => setStateIterator(i));
                  })
                : []) +
            (showCallNotes
                ? [
                    DataCell(
                        TextFormField(
                          controller: widget.textControllers[i],
                          focusNode: focusNodes[i],
                          style: TextStyle(
                              color: fileManager.phoneList.people[i].called
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context).textTheme.bodyText1.color),
                          autofocus: false,
                          onChanged: (String text) {
                            fileManager.phoneList.people[i].note = text;
                          },
                          onFieldSubmitted: (String text) {
                            fileManager.phoneList.people[i].note = text;
                            focusNodes[i].unfocus();
                          },
                          decoration: InputDecoration(border: InputBorder.none, hintText: '..........'),
                        ),
                        onTap: () => setStateIterator(i)),
                    DataCell(
//                        ButtonTheme(
//                        alignedDropdown: true,
//                            child: DropdownButton<String>(
                        DropdownButton<String>(
                            value: fileManager.phoneList.people[i].result.isEmpty
                                ? null
                                : fileManager.phoneList.people[i].result,
                            onChanged: (String outcome) {
                              setState(() {
                                focusNodes[i].unfocus();
                                fileManager.phoneList.people[i].result = outcome;
                              });
                            },
                            hint: Text("Result"),
                            isDense: true,
                            isExpanded: false,
                            items: Person.resultMap.keys
                                .where((String outcome) => outcome.isNotEmpty)
                                .toList()
                                .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Align(
                                        child: CalledText(text: value, called: fileManager.phoneList.people[i].called),
                                        alignment: Alignment.centerRight),
//                                        child: CalledText(text: value, called: fileManager.phoneList.people[i].called),
                                  ),
                                )
                                .toList()
//    )
                            ),
                        onTap: () => setStateIterator(i)),
                  ]
                : []));
  }
}
