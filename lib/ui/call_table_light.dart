import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/services/settings_manager.dart';
import 'package:auto_call/ui/prompts/pre_session_prompt.dart';
import 'package:auto_call/ui/widgets/call_table_widgets.dart';

class CallTableLight extends StatefulWidget {
  final PhoneList phoneList;
  final ScrollController scrollController;
  final List<TextEditingController> textControllers;
  final List<bool> acceptedColumns;

  CallTableLight(
      {Key key,
      @required this.phoneList,
      @required this.scrollController,
      @required this.textControllers,
      this.acceptedColumns})
      : super(key: key);

  @override
  _CallTableState createState() => _CallTableState();
}

class _CallTableState extends State<CallTableLight> {
  double rowSize = kMinInteractiveDimension;
  List<FocusNode> focusNodes = [];

  // Getters for global settings
  bool get showCallNotes => globalSettingManager.get("showNotes");
  bool get additionalColumns =>
      globalSettingManager.isPremium() ? globalSettingManager.get("additionalColumns") : false;

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
    return Column(children: [
      Expanded(
        flex: 0,
        child: ListTile(
          dense: true,
          leading: SizedBox(width: 65),
          title: Text("Name", style: Theme.of(context).textTheme.subtitle1),
          trailing: Text("Phone", style: Theme.of(context).textTheme.subtitle1),
        ),
      ),
      Expanded(
          child: Scrollbar(
              child: SingleChildScrollView(
        controller: widget.scrollController,
        scrollDirection: Axis.vertical,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) => rowBuilder(context, index),
                  itemCount: widget.phoneList.people.length),
              Container(
                  padding: EdgeInsets.only(top: 0.5 * rowSize),
                  height: rowSize * 2.5,
                  alignment: Alignment.topCenter,
                  child: const Text("End of Phone List", textAlign: TextAlign.center))
            ]),
      )))
    ]);
  }

  Widget rowBuilder(BuildContext context, int i) {
    return SizedBox(
        height: rowSize,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ListTile(
                dense: true,
                leading: SizedBox(
                    width: 65,
                    child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
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
                      CalledText(text: (i + 1).toString(), called: widget.phoneList.people[i].called),
                    ])),
                title: CalledText(text: widget.phoneList.people[i].name, called: widget.phoneList.people[i].called),
                trailing: CalledText(text: widget.phoneList.people[i].phone, called: widget.phoneList.people[i].called),
                onTap: () => setStateIterator(i)),
            // Divider(),
          ],
        ));
  }
}
