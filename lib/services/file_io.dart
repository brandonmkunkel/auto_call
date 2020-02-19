import 'package:csv/csv.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_call/services/phone_list.dart';



// Read a CSV file
Future<List<List<dynamic>>> readCSVFile(String path) async {
  // Read the file handed to the class at instantiation
  final input = new File(path).openRead();
  return await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();
}

List<List<dynamic>> readTextAsCSV(String data) {
  return CsvToListConverter().convert(data);
}

class FileIOWrapper {
  const FileIOWrapper({this.reader, this.saver});

  final Future<List<List<dynamic>>> Function(String) reader;
  final bool Function(String) saver;
}

class FileManager {
  Map<String, FileIOWrapper> registeredInterfaces;
  String path;
  PhoneList phoneList;

  FileManager(String path){
    this.path=path;
    readFile();
  }

  void readFile() {
//    phoneList.fromData();
  }

  void saveFile() {

  }

  void passToShare() {

  }
}

