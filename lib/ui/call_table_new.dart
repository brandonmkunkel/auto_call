import 'package:flutter/material.dart';

import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/services/settings_manager.dart';
import 'package:auto_call/ui/prompts/pre_session_prompt.dart';
import 'package:auto_call/ui/widgets/call_table_widgets.dart';

class TableCell extends StatelessWidget {
  TableCell.content({
    @required this.child,
    this.textStyle,
    this.cellDimensions = CellDimensions.base,
    this.onTap,
  })  : cellWidth = cellDimensions.contentCellWidth,
        cellHeight = cellDimensions.contentCellHeight,
        _padding = EdgeInsets.symmetric(horizontal: 5.0);

  TableCell.legend({
    @required this.child,
    this.textStyle,
    this.cellDimensions = CellDimensions.base,
    this.onTap,
  })  : cellWidth = cellDimensions.stickyLegendWidth,
        cellHeight = cellDimensions.stickyLegendHeight,
        _padding = EdgeInsets.only(left: 24.0);

  TableCell.stickyRow({
    @required this.child,
    this.textStyle,
    this.cellDimensions = CellDimensions.base,
    this.onTap,
  })  : cellWidth = cellDimensions.contentCellWidth,
        cellHeight = cellDimensions.stickyLegendHeight,
        _padding = EdgeInsets.zero;

  TableCell.stickyColumn({
    @required this.child,
    this.textStyle,
    this.cellDimensions = CellDimensions.base,
    this.onTap,
  })  : cellWidth = cellDimensions.stickyLegendWidth,
        cellHeight = cellDimensions.contentCellHeight,
        _padding = EdgeInsets.only(left: 24.0);

  final CellDimensions cellDimensions;

  final Widget child;
  final Function onTap;

  final double cellWidth;
  final double cellHeight;

  final EdgeInsets _padding;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cellWidth,
        height: cellHeight,
        padding: _padding,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                child: child,
              ),
            ),
            // Divider(),
          ],
        ),
        // decoration: BoxDecoration(
        //     border: Border(
        //       left: BorderSide(color: _colorHorizontalBorder),
        //       right: BorderSide(color: _colorHorizontalBorder),
        //     ),
        //     color: Theme.of(context).backgroundColor),
      ),
    );
  }
}

class NewCallTable extends StatefulWidget {
  final PhoneList phoneList;
  final ScrollController scrollController;
  final List<TextEditingController> textControllers;
  final List<bool> acceptedColumns;

  NewCallTable(
      {Key key,
      @required this.phoneList,
      @required this.scrollController,
      @required this.textControllers,
      this.acceptedColumns})
      : super(key: key);

  @override
  _NewCallTableState createState() => _NewCallTableState();
}

class _NewCallTableState extends State<NewCallTable> {
  bool editColumns = false;
  List<bool> acceptedColumns = [];
  double rowSize = kMinInteractiveDimension;
  List<FocusNode> focusNodes = [];

  /// Getter for widget phone list
  PhoneList get phoneList => widget.phoneList;

  bool get showCallNotes => globalSettingManager.get("showNotes");
  bool get additionalColumns =>
      globalSettingManager.isPremium() ? globalSettingManager.get("additionalColumns") : false;

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
          // HeaderText("#"),
          HeaderText("Name"),
          HeaderText("Phone"),
        ] +
        (additionalColumns
            // Use additionalColumns to add user columns
            ? List.generate(phoneList.additionalLabels.length, (int idx) => HeaderText(phoneList.additionalLabels[idx]))
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
    return Scrollbar(
        controller: widget.scrollController,
        child: ListView.separated(
          controller: widget.scrollController,
          scrollDirection: Axis.vertical,
          itemCount: phoneList.people.length,
          separatorBuilder: (context, i) => Divider(),
          itemBuilder: (context, i) => ListTile(
            leading: Container(
                width: 80.0,
                alignment: Alignment.centerLeft,
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  i == widget.phoneList.iterator
                      ? IconButton(
                          padding: const EdgeInsets.all(0.0),
                          icon: Icon(Icons.forward, color: Theme.of(context).iconTheme.color),
                          onPressed: () {},
                        )
                      : IconButton(
                          padding: const EdgeInsets.all(0.0),
                          icon: Icon(Icons.check_circle,
                              color: widget.phoneList.people[i].called
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).disabledColor),
                          onPressed: () {
                            setState(() {
                              widget.phoneList.people[i].called = !widget.phoneList.people[i].called;
                            });
                          }),
                  CalledText(text: (i + 1).toString(), called: widget.phoneList.people[i].called)
                ])),
            title: TableCell.content(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: rowBuilder(context, i)),
                onTap: () => setState(() {
                      setStateIterator(i);
                    })),
          ),
        ));
  }

  List<Widget> rowBuilder(BuildContext context, int i) {
    bool selected = i == phoneList.iterator ? true : false;

    return [
          // Container(
          //     child: i == phoneList.iterator
          //         ? IconButton(
          //             padding: const EdgeInsets.all(5.0),
          //             icon: Icon(
          //               Icons.forward,
          //               color: Theme.of(context).iconTheme.color,
          //             ))
          //         : IconButton(
          //             padding: const EdgeInsets.all(5.0),
          //             icon: Icon(Icons.check_circle,
          //                 color: phoneList.people[i].called
          //                     ? Theme.of(context).colorScheme.secondary
          //                     : Theme.of(context).disabledColor),
          //             onPressed: () {
          //               setState(() {
          //                 phoneList.people[i].called = !phoneList.people[i].called;
          //               });
          //             })),
          // Container(child: CalledText(text: phoneList.people[i].id.toString(), called: phoneList.people[i].called)),
          Container(child: CalledText(text: phoneList.people[i].name, called: phoneList.people[i].called)),
          Container(child: CalledText(text: phoneList.people[i].phone, called: phoneList.people[i].called)),
        ] +

        // Additional Columns
        (additionalColumns
            ? List.generate(phoneList.additionalLabels.length, (int idx) {
                return Container(
                    child:
                        CalledText(text: phoneList.people[i].additionalData[idx], called: phoneList.people[i].called));
              })
            : []) +
        (showCallNotes
            ? [
                Container(
                    child: TextFormField(
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
                )),
                Container(
                    child: DropdownButton<String>(
                        value: phoneList.people[i].result.isEmpty ? null : phoneList.people[i].result,
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
                            .toList())),
              ]
            : []);
  }
}
