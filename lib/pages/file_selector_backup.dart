import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:auto_call/ui/drawer.dart';

class FileSelectorPage extends StatefulWidget {
  static String routeName = "/file_selector";

  @override
  FileSelectorState createState() => FileSelectorState();
}

class FileSelectorState extends State<FileSelectorPage> {
  List<List<dynamic>> data = [];

  loadAsset() async {
    final myData = await rootBundle.loadString("assets/text/data/sample_numbers.txt");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    data = csvTable;
  }

  loadFilePicker() async {

  }

//  @override
//  Widget build(BuildContext context) {
//    return Center();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: appDrawer(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: assetLoadButton(),
      appBar: AppBar(
        title: Text("Table Layout and CSV"),
      ),
      body: SingleChildScrollView(
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(100.0),
            1: FixedColumnWidth(200.0),
          },
          border: TableBorder.all(width: 1.0),
          children: data.map((item) {
            return TableRow(
                children: item.map((row) {
              return Container(
                color: row.toString().contains("NA") ? Colors.red : Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    row.toString(),
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              );
            }).toList());
          }).toList(),
        ),
      ),
    );
  }

  Widget assetLoadButton() {
    return FloatingActionButton(
        child: Icon(Icons.file_upload),
        onPressed: () async {
          await loadAsset();
          print(data);
        });
  }

  Widget filePickButton() {
    return FloatingActionButton(
        child: Icon(Icons.cloud_upload),
        onPressed: () async {
          await loadFilePicker();
          print(data);
        });
  }
}
