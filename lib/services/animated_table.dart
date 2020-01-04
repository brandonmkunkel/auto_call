import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class Person {
  bool active = false;
  bool called = false;
  String name = "";
  int number = 0;
  String email = "";
  String comment = "";
}

//class PersonRow extends DataRow {
//  Person person;
//
//  PersonRow() {
//
//  }
//}

class DataTableInStreamBuilder extends StatelessWidget {
  final double _titleFontSize = 24.0;
  final double _fontSize = 24.0;
  int _numNumbers = 0;
  int iterator = 0;
  final List<Person> people = [];

  Stream<int> timedCounter(Duration interval, [int maxCount]) async* {
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      yield i++;
      if (i == maxCount) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: timedCounter(Duration(seconds: 2), 10),
      //print an integer every 2secs, 10 times
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text("Loading");
        }
        int count = snapshot.data;

        return DataTable(
          columnSpacing: 10.0,
          columns: [
            DataColumn(
              label: Text("", style: TextStyle(fontSize: _titleFontSize)),
              numeric: false,
            ),
            DataColumn(label: Text("#", style: TextStyle(fontSize: _titleFontSize)), numeric: false),
            DataColumn(
                label: Expanded(child: Text("Phone Number", style: TextStyle(fontSize: _titleFontSize))),
                numeric: false),
            DataColumn(label: Text("Called", style: TextStyle(fontSize: _titleFontSize)), numeric: false),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(Icon(Icons.forward)),
                DataCell(Text("${count + 1}", style: TextStyle(fontSize: _fontSize))),
                DataCell(Text("${count + 200000}", style: TextStyle(fontSize: _fontSize))),
                DataCell(Checkbox(value: false, onChanged: (bool value) {})
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Icon(null)),
                DataCell(Text("${count + 4}", style: TextStyle(fontSize: _fontSize))),
                DataCell(Text("${count + 500000}", style: TextStyle(fontSize: _fontSize))),
                DataCell(Checkbox(value: false, onChanged: (bool newValue) {})),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text("")),
                DataCell(Text("${count + 6}", style: TextStyle(fontSize: _fontSize))),
                DataCell(Text("${count + 700000}", style: TextStyle(fontSize: _fontSize))),
                DataCell(Checkbox(value: false, onChanged: (bool newValue) {})),
              ],
            ),
          ],
        );
      },
    );
  }
}
