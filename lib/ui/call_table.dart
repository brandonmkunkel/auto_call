import 'package:flutter/material.dart';
import 'package:auto_call/services/file_io.dart';

class InheritedProvider<T> extends InheritedWidget {
  final T data;
  InheritedProvider({
    Widget child,
    this.data,
  }) : super(child: child);

  @override
  bool updateShouldNotify(InheritedProvider oldWidget) => data != oldWidget.data;

  static T of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: T);
  }
}

class CallTable extends StatefulWidget {
  final ScrollController controller;
  final FileManager manager;

  CallTable({Key key, @required this.manager, @required this.controller}) : super(key: key);
//  CallTable({Key key, this.manager, @required this.controller}) : super(key: key);

  @override
  _CallTableState createState() => _CallTableState();
}

class _CallTableState extends State<CallTable> {
  double rowSize = kMinInteractiveDimension;
  FocusNode _focusNode;
//  FileManager fileManager;
//  ScrollController widget.controller;
  FileManager get fileManager => widget.manager;

  // Getter for file manager from widget parent
//  FileManager get fileManager => widget.fileManager;

  @override
  void initState() {
    super.initState();
//    readFile();
//    widget.controller = ScrollController(keepScrollOffset: true);
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode?.dispose();
//    widget.controller?.dispose();
  }

//  void readFile() async {
//    fileManager.readFile();
//  }

  // Update the Scroll controller based on the given item offset
  void updateController(int iteratorOffset) {
    print("initialoffset ${widget.controller.initialScrollOffset}, "
        "current offset ${widget.controller.offset}, "
        "offset update ${rowSize * iteratorOffset}");

    widget.controller.animateTo(
      widget.controller.offset + rowSize * iteratorOffset,
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

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Expanded(
          child: SingleChildScrollView(
//            controller: _controller,
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
    ]);
  }

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
            ]);
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
