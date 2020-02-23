import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_call/services/phone_list.dart';


List<List<dynamic>> readTextAsCSV(String data) {
  return const CsvToListConverter().convert(data);
}

String saveTextAsCSV(List<List<dynamic>> data) {
  return const ListToCsvConverter().convert(data);
}

///
/// CSV FILES
///
Future<List<List<dynamic>>> readCSVFile(String path) async {
  final input = File(path).openRead().transform(utf8.decoder);
  return await input.transform(new CsvToListConverter()).toList();
}

void saveCSVFile(String path, List<List<dynamic>> data) async {
  final File file = File(path);
  file.writeAsString(ListToCsvConverter().convert(data));
}

///
/// Excel Files
///
//Future<List<List<dynamic>>> readExcelFile(String path) async {
//  OpenFile.open("");
//  ByteData data = await File(path).openRead();
//  List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//  var decoder = SpreadsheetDecoder.decodeBytes(bytes);
//}

//Future<List<List<dynamic>>> saveExcelFile(String path) async {
//  OpenFile.open("");
//  ByteData data = await File(path).openRead();
//  List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//  var decoder = SpreadsheetDecoder.decodeBytes(bytes);
//}


class FileIOWrapper {
  const FileIOWrapper(this.read, this.save);

  final Future<List<List<dynamic>>> Function(String) read;
  final void Function(String, List<List<dynamic>>) save;
}

class FileManager {
  final Map<String, FileIOWrapper> registeredInterfaces = {
    "csv" : FileIOWrapper(readCSVFile, saveCSVFile),
    "txt" : FileIOWrapper(readCSVFile, saveCSVFile),
  };
  static final Map<String, int> registeredExtensions = Map.fromIterables(
    ["csv", "txt", "xls", "xlsx"], [0, 1, 2, 3]
  );
  String path;
  String ext;
  PhoneList phoneList;

  FileManager(String path){
    this.path=path;
    this.ext=getExtension(path);
//    readFile();
  }

  static String getExtension(String path) {
    List pathComponents = path.split(".");
    return pathComponents.last;
  }

  static String updatedFilePath(String path) {
    // Split at the extension label, add "update" and rejoin to not overwrite the excel sheet
    List paths = path.split(".");
    paths[paths.lastIndexOf(paths.last)-1] += "_updated";
    return paths.join(".");
  }

  bool checkValidExtension() {
    return registeredInterfaces.containsKey(ext);
  }

  // Read the file from the stored path
  void readFile() async {
    if (checkValidExtension()) {
      this.phoneList = PhoneList.fromData(await registeredInterfaces[ext].read(path));
    } else {
      print("Not a valid file type");
    }
  }

  // Save the file to the same location but under a new name
  void saveFile() {
    if (checkValidExtension()) {
      registeredInterfaces[ext].save(updatedFilePath(path), this.phoneList.export());

//      registeredInterfaces[ext].save(path, this.phoneList.export());
    } else {
      print("Not a valid file type");
    }
  }

  void emailFile() async {

  }

  void saveToOldCalls() async {

  }
}

