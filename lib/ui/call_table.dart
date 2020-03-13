import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/settings_manager.dart';

class CallTable extends StatefulWidget {
  final ScrollController scrollController;
  final FileManager manager;
  final List<TextEditingController> textControllers;

  CallTable({Key key, @required this.manager, @required this.scrollController, @required this.textControllers})
      : super(key: key);

  @override
  _CallTableState createState() => _CallTableState();
}

class _CallTableState extends State<CallTable> {
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
                      horizontalMargin: 0.0,
                      columnSpacing: 10.0,
                      dataRowHeight: rowSize,
                      columns: [
                            DataColumn(label: HeaderText("#"), numeric: true),
                            DataColumn(label: HeaderText("Name"), numeric: false),
                            DataColumn(label: HeaderText("Phone"), numeric: false),
                          ] +
                          List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
                            return DataColumn(
                                label: HeaderText(fileManager.phoneList.additionalLabels[idx]), numeric: false);
                          }) +
                          [
                            DataColumn(label: HeaderText("Note"), numeric: false),
                            DataColumn(label: HeaderText("Outcome"), numeric: false),
                          ],
                      rows: List<DataRow>.generate(fileManager.phoneList.people.length, (i) => rowBuilder(context, i)),
                    ),
                  ])),
              Container(
                  height: rowSize,
                  alignment: Alignment.center,
                  child: Text("End of Phone List", textAlign: TextAlign.center)),
              Container(height: rowSize * 2.0)
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
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: Icon(
                                  Icons.forward,
                                  color: Theme.of(context).iconTheme.color,
                                )))
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
            List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
              return DataCell(
                  CalledText(
                      text: fileManager.phoneList.people[i].additionalData[idx],
                      called: fileManager.phoneList.people[i].called),
                  onTap: () => setStateIterator(i));
            }) +
            [
              DataCell(
                  TextFormField(
                    controller: widget.textControllers[i],
                    focusNode: focusNodes[i],
                    style: TextStyle(
                        color: fileManager.phoneList.people[i].called
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).textTheme.body1.color),
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
                  DropdownButton<String>(
                      value: fileManager.phoneList.people[i].outcome,
                      onChanged: (String outcome) {
                        setState(() {
                          focusNodes[i].unfocus();
                          fileManager.phoneList.people[i].outcome = outcome;
                        });
                      },
                      elevation: 16,
                      isDense: true,
                      items: <String>['None', 'Voicemail', 'Answered', 'Success', 'Follow Up']
                          .map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: CalledText(text: value, called: fileManager.phoneList.people[i].called),
                          );
                        },
                      ).toList()),
                  onTap: () => setStateIterator(i)),
            ]);
  }
}

class HeaderText extends StatelessWidget {
  final String text;
  HeaderText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          color: Theme.of(context).textTheme.body1.color,
          fontSize: Theme.of(context).textTheme.body2.fontSize * 1.2,
          fontWeight: FontWeight.bold,
        ));
  }
}

class CalledText extends StatelessWidget {
  final String text;
  final bool called;
  CalledText({this.text, this.called});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: called ? Theme.of(context).disabledColor : Theme.of(context).textTheme.body1.color,
            fontSize: Theme.of(context).textTheme.body1.fontSize));
  }
}
