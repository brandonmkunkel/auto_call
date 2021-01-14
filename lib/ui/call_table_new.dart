import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/settings_manager.dart';
import 'package:auto_call/ui/prompts/pre_session_prompt.dart';
import 'package:auto_call/ui/widgets/call_table_widgets.dart';

class NewCallTable extends StatefulWidget {
  final ScrollController scrollController;
  final FileManager manager;
  final List<TextEditingController> textControllers;
  final List<bool> acceptedColumns;

  NewCallTable(
      {Key key,
      @required this.manager,
      @required this.scrollController,
      @required this.textControllers,
      this.acceptedColumns})
      : super(key: key);

  @override
  _NewCallTableState createState() => _NewCallTableState();
}

class _NewCallTableState extends State<NewCallTable> {
  bool showCallNotes = false;
  bool additionalColumns = false;
  bool editColumns = false;
  List<bool> acceptedColumns = [];
  double rowSize = kMinInteractiveDimension;
  List<FocusNode> focusNodes = [];
  PhoneList phoneList;

  // Getter for the FileManager
  FileManager get fileManager => widget.manager;

  @override
  void initState() {
    for (int idx = 0; idx < phoneList.people.length; idx++) {
      // Text Editors for tracking text and passing between widgets
      widget.textControllers.add(TextEditingController(text: phoneList.people[idx].note));

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
      int desiredOffset = i - phoneList.iterator;
      updateController(desiredOffset.abs() > 5 ? desiredOffset : 0);
      phoneList.iterator = i;
    });
  }

  List columns() {
    return [
          HeaderText("#"),
          HeaderText("Name"),
          HeaderText("Phone"),
        ] +
        (additionalColumns
            // Use additionalColumns to add user columns
            ? List.generate(phoneList.additionalLabels.length,
                (int idx) => HeaderText(phoneList.additionalLabels[idx]))
            : []) +
        (showCallNotes
            // Use bareMinimum to hide the call Note and Result
            ? [
                HeaderText("Note"),
                HeaderText("Result"),
              ]
            : []);
  }

  @override
  Widget build(BuildContext context) {
    // Get Additional Settings for the call table from the SettingsManager
    showCallNotes = globalSettingManager.get("showNotes");
    additionalColumns = globalSettingManager.isPremium() ? globalSettingManager.get("additionalColumns") : false;

    return StickyHeadersTable(
      columnsLength: columns().length,
      // cellAlignments: CellAlignments.variableColumnAlignment,
      rowsLength: 10,
      columnsTitleBuilder: (i) => GestureDetector(
          // child: Text(widget.titleColumn[i]),
          child: Container(),
          onTap: () => setStateIterator(i),
          ),
      rowsTitleBuilder: (i) => GestureDetector(
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            i == phoneList.iterator
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
                        color: phoneList.people[i].called
                            ? Theme.of(context).accentColor
                            : Theme.of(context).disabledColor),
                    onPressed: () {
                      setState(() {
                        phoneList.people[i].called = !phoneList.people[i].called;
                      });
                    })),
            CalledText(text: (i + 1).toString(), called: phoneList.people[i].called)
          ]),
          onTap: () => setStateIterator(i),
          ),
      contentCellBuilder: (i, j) => GestureDetector(
        // child: Text(widget.data[i][j]),
        child: Container(),
        // color: getContentColor(i, j),
        onTap: () => setState(() {
          // selectedColumn = j;
          // selectedRow = i;
          setStateIterator(i);
        }),
      ),
      legendCell: Text('#'),
    );
  }

  DataRow rowBuilder(BuildContext context, int i) {
    return DataRow.byIndex(
        index: i,
        selected: i == phoneList.iterator ? true : false,
        cells: [
              DataCell(
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    i == phoneList.iterator
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
                                    color: phoneList.people[i].called
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).disabledColor),
                                onPressed: () {
                                  setState(() {
                                    phoneList.people[i].called = !phoneList.people[i].called;
                                  });
                                })),
                    CalledText(text: (i + 1).toString(), called: phoneList.people[i].called)
                  ]),
                  onTap: () => setStateIterator(i)),
              DataCell(
                  CalledText(
                      text: phoneList.people[i].name, called: phoneList.people[i].called),
                  onTap: () => setStateIterator(i)),
              DataCell(
                  CalledText(
                      text: phoneList.people[i].phone, called: phoneList.people[i].called),
                  onTap: () => setStateIterator(i)),
            ] +

            // Additional Columns
            (additionalColumns
                ? List.generate(phoneList.additionalLabels.length, (int idx) {
                    return DataCell(
                        CalledText(
                            text: phoneList.people[i].additionalData[idx],
                            called: phoneList.people[i].called),
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
                              color: phoneList.people[i].called
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context).textTheme.bodyText1.color),
                          autofocus: false,
                          onChanged: (String text) {
                            phoneList.people[i].note = text;
                          },
                          onFieldSubmitted: (String text) {
                            phoneList.people[i].note = text;
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
                            value: phoneList.people[i].result.isEmpty
                                ? null
                                : phoneList.people[i].result,
                            onChanged: (String outcome) {
                              setState(() {
                                focusNodes[i].unfocus();
                                phoneList.people[i].result = outcome;
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
                                        child: CalledText(text: value, called: phoneList.people[i].called),
                                        alignment: Alignment.centerRight),
//                                        child: CalledText(text: value, called: phoneList.people[i].called),
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
