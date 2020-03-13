import 'package:flutter/material.dart';
import 'package:auto_call/services/file_io.dart';
import 'package:flutter/rendering.dart';

class NewCallTable extends StatefulWidget {
  final ScrollController scrollController;
  final FileManager manager;
  final List<TextEditingController> textControllers;

  NewCallTable({Key key, @required this.manager, @required this.scrollController, @required this.textControllers})
      : super(key: key);

  @override
  _NewCallTableState createState() => _NewCallTableState();
}

class _NewCallTableState extends State<NewCallTable> {
  final ScrollController horizontalController = ScrollController();
  double rowSize = kMinInteractiveDimension;
  List<FocusNode> focusNodes = [];

  // Getter for the FileManager
  FileManager get fileManager => widget.manager;

  @override
  void initState() {
    super.initState();

    for (int idx = 0; idx < fileManager.phoneList.people.length; idx++) {
      // Text Editors for tracking text and passing between widgets
      widget.textControllers.add(TextEditingController(text: fileManager.phoneList.people[idx].note));

      // Focus Nodes for focusing on text editing
      focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    super.dispose();
    focusNodes.forEach((focusNode) {
      focusNode?.dispose();
    });
  }

  // Update the Scroll controller based on the given item offset
  void updateController(int iteratorOffset) {
    widget.scrollController.animateTo(
      widget.scrollController.offset + rowSize * iteratorOffset,
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

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Expanded(
          child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListView.builder(
//          physics: NeverScrollableScrollPhysics(),
              controller: widget.scrollController,
              shrinkWrap: true,
              itemCount: fileManager.phoneList.people.length,
              itemBuilder: (context, idx) {
                return CallTableEntry(
                  manager: fileManager,
                  idx: idx,
                  focusNode: focusNodes[idx],
                  textController: widget.textControllers[idx],
                );
              },
            ),
            Container(
                height: rowSize,
                alignment: Alignment.center,
                child: Text("End of Phone List", textAlign: TextAlign.center)),
            Container(height: rowSize * 2.0)
          ],
        ),
      ))
    ]);

//    return Column(
//      mainAxisSize: MainAxisSize.min,
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//        SingleChildScrollView(
//                scrollDirection: Axis.horizontal,
//                child: Row(
////                  mainAxisSize: MainAxisSize.min,
//                  children: <Widget>[
//                    Expanded(
//                      child: ListView.builder(
////                      physics: NeverScrollableScrollPhysics(),
//                        scrollDirection: Axis.vertical,
//                        shrinkWrap: true,
//                        itemCount: fileManager.phoneList.people.length,
//                        itemBuilder: (context, idx) {
//                          return rowBuilder(context, idx);
//                        },
//                      )
//                    ),
//
//                    DataTable(
//                      horizontalMargin: 0.0,
//                      columnSpacing: 10.0,
//                      dataRowHeight: rowSize,
//                      columns: [
//                        DataColumn(label: HeaderText(""), numeric: false),
//                        DataColumn(label: HeaderText("#"), numeric: false),
//                        DataColumn(label: HeaderText("Name"), numeric: false),
//                        DataColumn(label: HeaderText("Phone"), numeric: false),
//                      ] +
//                          List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
//                            return DataColumn(
//                                label: HeaderText(fileManager.phoneList.additionalLabels[idx]),
//                                numeric: false);
//                          }) +
//                          [
////            DataColumn(label: Text("Email", style: headerStyle(context)), numeric: false),
//                            DataColumn(label: HeaderText("Note"), numeric: false),
//                            DataColumn(label: HeaderText("Outcome"), numeric: false),
//                          ],
//                      rows: fileManager.phoneList.people
//                          .asMap()
//                          .map((i, person) => MapEntry(i, rowBuilder(context, i)))
//                          .values
//                          .toList(),
//                    ),
//              Container(
//                  height: rowSize,
//                  alignment: Alignment.center,
//                  child: Text("End of Phone List", textAlign: TextAlign.center)),
//              Container(height: rowSize * 2.0)
//            ],
//    ),
//      ),
//    ),
//    ],
//    );
  }
}

class CallTableEntry extends StatefulWidget {
  final FileManager manager;
  final int idx;
  final FocusNode focusNode;
  final TextEditingController textController;

  CallTableEntry(
      {Key key, @required this.manager, @required this.idx, @required this.focusNode, @required this.textController})
      : super(key: key);

  @override
  _CallTableEntryState createState() => _CallTableEntryState();
}

class _CallTableEntryState extends State<CallTableEntry> {
  FileManager get fileManager => widget.manager;
  @override
  Widget build(BuildContext context) {
    int i = widget.idx;

    return Row(
//        index: i,
//        selected: i == fileManager.phoneList.iterator ? true : false,
      children: [
            Expanded(
              flex: 0,
              child: Container(
                  width: 40.0,
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
                          },
                        )),
            ),
            Expanded(flex: 1, child: CalledText(text: "${i + 1}", called: fileManager.phoneList.people[i].called)),
            Expanded(
              flex: 2,
              child: CalledText(
                  text: fileManager.phoneList.people[i].name, called: fileManager.phoneList.people[i].called),
            ),
            Expanded(
              flex: 2,
              child: CalledText(
                  text: fileManager.phoneList.people[i].phone, called: fileManager.phoneList.people[i].called),
            ),
          ] +
          List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
            return Expanded(
              flex: 2,
              child: CalledText(
                  text: fileManager.phoneList.people[i].additionalData[idx],
                  called: fileManager.phoneList.people[i].called),
            );
          }) +
          [
//                        DataCell(
//                            SelectableText(fileManager.phoneList.people[i].email,
//                                style: calledTheme(fileManager.phoneList.people[i].called)),
//                                onTap: () => setStateIterator(i));
//                        ),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: widget.textController,
                focusNode: widget.focusNode,
                style: TextStyle(
                    color: fileManager.phoneList.people[i].called
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).textTheme.body1.color),
                autofocus: false,
                onChanged: (String text) {
                  fileManager.phoneList.people[i].note = text;
                },
                decoration: InputDecoration(border: InputBorder.none, hintText: '..........'),
              ),
            ),
            Expanded(
              flex: 0,
              child: DropdownButton<String>(
                  value: fileManager.phoneList.people[i].outcome,
                  onChanged: (String outcome) {
                    widget.focusNode.unfocus();
                    fileManager.phoneList.people[i].outcome = outcome;
                    setState(() {});
                  },
                  elevation: 16,
                  items:
                      <String>['None', 'Voicemail', 'Answered', 'Success', 'Follow Up'].map<DropdownMenuItem<String>>(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: CalledText(text: value, called: fileManager.phoneList.people[i].called),
                      );
                    },
                  ).toList()),
            )
          ],
    );
  }
}

class HeaderText extends StatelessWidget {
  final String text;
  HeaderText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.body1.color));
  }
}

class CalledText extends StatelessWidget {
  final String text;
  final bool called;
  CalledText({this.text, this.called});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(color: called ? Theme.of(context).disabledColor : Theme.of(context).textTheme.body1.color));
  }
}
