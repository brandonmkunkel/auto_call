import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';


class FileStorage {
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/file.txt');
  }

  void readFile() {
    /* What to do? */
  }

  Future<Null> writeFile(String text) async {
    final file = await _localFile;

    IOSink sink = file.openWrite(mode: FileMode.append);
    sink.add(utf8.encode('$text'));
    await sink.flush();
    await sink.close();
  }
}

class DataTableInStreamBuilder extends StatelessWidget {
  final double _titleFontSize = 24.0;
  final double _fontSize = 24.0;
  int _numNumbers = 0;
  int iterator = 0;

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
              DataColumn(
                  label: Text("#", style: TextStyle(fontSize: _titleFontSize)),
                  numeric: false
              ),
              DataColumn(
                  label: Expanded(child: Text("Phone Number", style: TextStyle(fontSize: _titleFontSize))),
                  numeric: false
              ),
              DataColumn(
                  label: Text("Called", style: TextStyle(fontSize: _titleFontSize)),
                  numeric: false
              ),
            ],

            rows: [
              DataRow(
                cells: [
                  DataCell(Text("")),
                  DataCell(Text("${count + 1}", style: TextStyle(fontSize: _fontSize))),
                  DataCell(Text("${count + 200000}", style: TextStyle(fontSize: _fontSize))),
                  DataCell(Checkbox(value: false, onChanged: (bool newValue) {})),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text("")),
                  DataCell(Text("${count + 4}", style: TextStyle(fontSize: _fontSize))),
                  DataCell(Text("${count + 500000}", style: TextStyle(fontSize: _fontSize))),
                  DataCell(Checkbox(value: false, onChanged: (bool newValue) {})),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Icon(Icons.forward)),
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