//import 'package:flutter/material.dart';
//import 'package:auto_call/services/file_io.dart';
//
//
//class CallTable extends StatefulWidget {
//  const CallTable({FileManager manager});
//
//  @override
//  _CallTableState createState() => _CallTableState();
//}
//
//class _CallTableState extends State<CallTable> {
//  final double _titleFontSize = 18.0;
//  final double _fontSize = 18.0;
//
//  TextStyle calledTextColor(BuildContext context, bool called) {
//    return TextStyle(color: called ? Theme.of(context).disabledColor : Theme.of(context).textTheme.body1.color);
//  }
//
//  Color calledIconColor(buildContext, bool called) {
//    return called ? Theme.of(context).accentColor : Theme.of(context).disabledColor;
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    TextStyle headerStyle = TextStyle(
//        fontSize: _titleFontSize, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.body1.color);
//
//    return DataTable(
//      horizontalMargin: 0.0,
//      columnSpacing: 10.0,
//      columns: [
//        DataColumn(label: Text("", style: headerStyle), numeric: false),
//        DataColumn(label: Text("#", style: headerStyle), numeric: false),
//        DataColumn(label: Text("Name", style: headerStyle), numeric: false),
//        DataColumn(label: Text("Phone", style: headerStyle), numeric: false),
//      ] +
//          List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
//            return DataColumn(
//                label: Text(fileManager.phoneList.additionalLabels[idx], style: headerStyle), numeric: false);
//          }) +
//          [
////            DataColumn(label: Text("Email", style: headerStyle), numeric: false),
//            DataColumn(label: Text("Comment", style: headerStyle), numeric: false),
//            DataColumn(label: Text("Outcome", style: headerStyle), numeric: false),
//          ],
//      rows: fileManager.phoneList.people
//          .asMap()
//          .map((i, person) => MapEntry(
//          i,
//          DataRow.byIndex(
//              index: i,
//              selected: i == iterator ? true : false,
////                  onSelectChanged: (bool selected) {
////                    if (selected) {
////                      iterator=i;
////                      selected = selected;
////                    }
////                  },
//              cells: [
//                DataCell(
//                    Container(
//                      width: 50.0,
//                      alignment: Alignment.center,
//                      child: i == iterator
//                          ? Icon(Icons.forward)
//                          : IconButton(
//                          icon: Icon(Icons.check_circle,
//                              color: calledIconColor(context, fileManager.phoneList.people[i].called)),
//                          onPressed: () {
//                            setState(() {
//                              fileManager.phoneList.people[i].called =
//                              !fileManager.phoneList.people[i].called;
//                            });
//                          }),
//                    ),
//                    placeholder: true,
//                    onTap: () => setStateIterator(i)),
////                        DataCell(Checkbox(
////                            value: fileManager.phoneList.people[i].called,
////                            onChanged: (bool value) {
////                              setState(() {
////                                fileManager.phoneList.people[i].called = value;
////                              });
////                            })),
//
//                DataCell(
//                    Text(i.toString(), style: calledTextColor(context, fileManager.phoneList.people[i].called)),
//                    placeholder: false,
//                    onTap: () => setStateIterator(i)),
//                DataCell(
//                    Text(fileManager.phoneList.people[i].name,
//                        style: calledTextColor(context, fileManager.phoneList.people[i].called)),
//                    onTap: () => setStateIterator(i)),
//                DataCell(
//                    Text(fileManager.phoneList.people[i].phone,
//                        style: calledTextColor(context, fileManager.phoneList.people[i].called)),
//                    onTap: () => setStateIterator(i)),
////                        DataCell(
////                            Text(fileManager.phoneList.people[i].email,
////                                style: calledTheme(fileManager.phoneList.people[i].called)), onTap: () {
////                          setState(() {
////                            iterator = i;
////                          });
////                        }),
//              ] +
//                  List.generate(fileManager.phoneList.additionalLabels.length, (int idx) {
//                    return DataCell(
//                        Text(fileManager.phoneList.people[i].additionalData[idx],
//                            style: calledTextColor(context, fileManager.phoneList.people[i].called)),
//                        onTap: () => setStateIterator(i));
//                  }) +
//                  [
//                    DataCell(
//                        TextFormField(
//                          autofocus: false,
////                              onChanged: (String text) {
////                                fileManager.phoneList.people[i].comment = text;
////                                FocusScope.of(context).unfocus();
////                              },
//                          onTap: () {
//                            FocusScope.of(context).requestFocus(_focusNode);
//                          },
//                          onEditingComplete: () {
//                            FocusScope.of(context).unfocus();
//                          },
//                          onSaved: (String text) {
//                            fileManager.phoneList.people[i].comment = text;
//                            FocusScope.of(context).unfocus();
//                          },
//                          decoration: InputDecoration(
//                              hintStyle: calledTextColor(context, fileManager.phoneList.people[i].called),
//                              labelStyle: calledTextColor(context, fileManager.phoneList.people[i].called),
//                              border: InputBorder.none,
//                              hintText: '..................'),
//                        ),
//                        onTap: () => setStateIterator(i)),
//                    DataCell(
//                        Text(fileManager.phoneList.people[i].outcome,
//                            style: calledTextColor(context, fileManager.phoneList.people[i].called)),
//                        onTap: () => setStateIterator(i)),
//                  ])))
//          .values
//          .toList(),
//    );
//  }
//}
