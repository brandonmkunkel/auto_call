import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:string_similarity/string_similarity.dart';

final List<String> required_labels = ["name", "number"];

class Person {
  bool active = false;
  bool called = false;
  String name = "";
  String number = "";
  String email = "";
  String comment = "";

  static final List<String> labels = ["name", "number", "email", "comment", "called"];

  Person(String name, String number, {String email=""}) {
    this.name = name;
    this.number = number;
  }

  String print() {
    return name + ", " + number + ", " + email;
  }

  List<String> encode() {
    return [name, number, email, comment, called.toString()];
  }


}

class PhoneList {
  String path;
  List<List<dynamic>> data = [];
  int iterator = 0;
  Map<String, int> label_mapping;
  List<Person> people = [];

  PhoneList(String path) {
    this.path=path;

    print(["phone_list.dart: Loading phone list", path]);
    processFile();

    print("phone_list.dart: Final PhoneList");
    people.asMap().forEach((i, value) {
      print('index=$i, value=$value');
    });
    print("phone_list.dart: Done instantiating the PhoneList class");
  }

  void processFile() async {
    data = await readFile();

    if (data.isNotEmpty) {
      print("phone_list.dart: Data is not empty");
      findHeaders();
    } else {
      print("phone_list.dart: Data is empty");
    }
  }

  Future<List<List<dynamic>>> readFile() async {
    // Read the file handed to the class at instantiation
    final input = new File(path).openRead();
    return await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();
  }

  void findHeaders() {
    print(["phone_list.dart: process_file", data]);
    bool headerExists = false;
    List<String> header = data[0].cast();
    List<List<String>> rows;
    BestMatch match;
    int idx;

    // First look to see if there really is a header row
    for (String label in header) {
      match = StringSimilarity.findBestMatch(label, header);
      print([label, match.bestMatch.target, match.bestMatch.rating, match.bestMatchIndex]);
    }

//    print("Storing rows");
//
//    if (headerExists) {
//      rows = data.sublist(1).cast<List<String>>();
//    } else {
//      rows = data.cast<List<String>>();
//    }
//
//    print(["Header titles", header]);
//    print(["Rows titles", rows]);

  }

  void matchLabels() {

  }

  List<List> encode() {
    List<List> headers = [[]];
    return headers + List<List>.generate(people.length, (int idx) => people[idx].encode());
  }
}
