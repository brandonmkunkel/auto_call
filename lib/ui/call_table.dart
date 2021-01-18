import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/services/settings_manager.dart';
import 'package:auto_call/ui/prompts/pre_session_prompt.dart';
import 'package:auto_call/ui/widgets/call_table_widgets.dart';

class CallTable extends StatefulWidget {
  final FileManager fileManager;
  final PhoneList phoneList;
  final ScrollController scrollController;
  final List<TextEditingController> textControllers;
  final List<bool> acceptedColumns;

  CallTable(
      {Key key,
      @required this.fileManager,
      @required this.phoneList,
      @required this.scrollController,
      @required this.textControllers,
      this.acceptedColumns})
      : super(key: key);

  @override
  _CallTableState createState() => _CallTableState();
}

class _CallTableState extends State<CallTable> {
  bool editColumns = false;
  List<bool> acceptedColumns = [];
  double rowSize = kMinInteractiveDimension;
  List<FocusNode> focusNodes = [];

  // Getter for the FileManager
  FileManager get fileManager => widget.fileManager;

  bool get showCallNotes => globalSettingManager.get("showNotes");
  bool get additionalColumns => globalSettingManager.isPremium() ? globalSettingManager.get("additionalColumns") : false;

  @override
  void initState() {
    for (int idx = 0; idx < widget.phoneList.people.length; idx++) {
      // Text Editors for tracking text and passing between widgets
      widget.textControllers.add(TextEditingController(text: widget.phoneList.people[idx].note));

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
      int desiredOffset = i - widget.phoneList.iterator;
      updateController(desiredOffset.abs() > 5 ? desiredOffset : 0);
      widget.phoneList.iterator = i;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                            const DataColumn(label: const HeaderText("#"), numeric: true),
                            const DataColumn(label: const HeaderText("Name"), numeric: false),
                            const DataColumn(label: const HeaderText("Phone"), numeric: false),
                          ] +

                          // Use additionalColumns to add user columns
                          (additionalColumns
                              ? List.generate(
                                  widget.phoneList.additionalLabels.length,
                                  (int idx) => DataColumn(
                                      label: HeaderText(widget.phoneList.additionalLabels[idx]), numeric: false))
                              : []) +

                          // Use bareMinimum to hide the call Note and Result
                          (showCallNotes
                              ? [
                                  const DataColumn(label: const HeaderText("Note"), numeric: false),
                                  const DataColumn(label: const HeaderText("Result"), numeric: false),
                                ]
                              : []),
                      rows: List<DataRow>.generate(widget.phoneList.people.length, (i) => rowBuilder(context, i)),
                    ),
                  ])),
              Container(
                  padding: EdgeInsets.only(top: 0.5 * rowSize),
                  height: rowSize * 2.5,
                  alignment: Alignment.topCenter,
                  child: const Text("End of Phone List", textAlign: TextAlign.center)),
            ]),
      )),
    ]);
  }

  DataRow rowBuilder(BuildContext context, int i) {
    return DataRow.byIndex(
        index: i,
        selected: i == widget.phoneList.iterator ? true : false,
        cells: [
              DataCell(
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    i == widget.phoneList.iterator
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
                                    color: widget.phoneList.people[i].called
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).disabledColor),
                                onPressed: () {
                                  setState(() {
                                    widget.phoneList.people[i].called = !widget.phoneList.people[i].called;
                                  });
                                })),
                    CalledText(text: (i + 1).toString(), called: widget.phoneList.people[i].called)
                  ]),
                  onTap: () => setStateIterator(i)),
              DataCell(CalledText(text: widget.phoneList.people[i].name, called: widget.phoneList.people[i].called),
                  onTap: () => setStateIterator(i)),
              DataCell(CalledText(text: widget.phoneList.people[i].phone, called: widget.phoneList.people[i].called),
                  onTap: () => setStateIterator(i)),
            ] +

            // Additional Columns
            (additionalColumns
                ? List.generate(widget.phoneList.additionalLabels.length, (int idx) {
                    return DataCell(
                        CalledText(
                            text: widget.phoneList.people[i].additionalData[idx],
                            called: widget.phoneList.people[i].called),
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
                              color: widget.phoneList.people[i].called
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context).textTheme.bodyText1.color),
                          autofocus: false,
                          onChanged: (String text) {
                            widget.phoneList.people[i].note = text;
                          },
                          onFieldSubmitted: (String text) {
                            widget.phoneList.people[i].note = text;
                            focusNodes[i].unfocus();
                          },
                          decoration: const InputDecoration(border: InputBorder.none, hintText: '..........'),
                        ),
                        onTap: () => setStateIterator(i)),
                    DataCell(
//                        ButtonTheme(
//                        alignedDropdown: true,
//                            child: DropdownButton<String>(
                        DropdownButton<String>(
                            value: widget.phoneList.people[i].result.isEmpty ? null : widget.phoneList.people[i].result,
                            onChanged: (String outcome) {
                              setState(() {
                                focusNodes[i].unfocus();
                                widget.phoneList.people[i].result = outcome;
                              });
                            },
                            hint: const Text("Result"),
                            isDense: true,
                            isExpanded: false,
                            items: Person.resultMap.keys
                                .where((String outcome) => outcome.isNotEmpty)
                                .toList()
                                .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Align(
                                        child: CalledText(text: value, called: widget.phoneList.people[i].called),
                                        alignment: Alignment.centerRight),
//                                        child: CalledText(text: value, called: widget.phoneList.people[i].called),
                                  ),
                                )
                                .toList()),
                        onTap: () => setStateIterator(i)),
                  ]
                : []));
  }
}
