import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:string_similarity/string_similarity.dart';



class MagicRegex {
  static final String nameStr = r"/^[a-z ,.'-]+$/i";
  static final String emailStr = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  static final String numberStr = r"(?:(?:\+?([1-9]|[0-9][0-9]|[0-9][0-9][0-9])\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([0-9][1-9]|[0-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?";

  static RegExp nameReg = RegExp(nameStr);
  static RegExp emailReg = RegExp(emailStr);
  static RegExp numberReg = RegExp(numberStr);

  static bool isName(String text) => nameReg.hasMatch(text);
  static bool isEmail(String text) => emailReg.hasMatch(text);
  static bool isNumber(String text) => numberReg.hasMatch(text);
}


class Person {
  bool active = false;
  bool called = false;
  String name = "";
  String number = "";
  String email = "";
  String comment = "";

  static final List<String> labels = ["name", "number", "email", "comment", "called"];
  static final List<String> requiredLabels = ["name", "number"];

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
  bool headerPresent = false;
  Map<String, int> labelMapping = new Map();
  List<Person> people = [];

  PhoneList(String path) {
    this.path=path;

//    print(["phone_list.dart: Loading phone list", path]);
    processFile();

//    print("phone_list.dart: Final PhoneList");
//    people.asMap().forEach((i, value) {
//      print('index=$i, value=$value');
//    });
//    print("phone_list.dart: Done instantiating the PhoneList class");
  }

  bool isNotEmpty() {
    return people.isNotEmpty;
  }

  bool isEmpty() {
    return !isNotEmpty();
  }

  void processFile() async {
    data = await readFile();

    if (data.isNotEmpty) {
//      print("phone_list.dart: Data is not empty");
      findHeaders();
      buildPeople();
    } else {
//      print("phone_list.dart: Data is empty");
    }

//    print(encode());
  }

  Future<List<List<dynamic>>> readFile() async {
    // Read the file handed to the class at instantiation
    final input = new File(path).openRead();
    return await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();
  }

//  List<List<dynamic>> readString(String string) {
//    return ;
//  }

  void findHeaders() {
//    print(["phone_list.dart: process_file", data]);
    List<String> header = data[0].cast();
    BestMatch match;

//    print(["phone_list.dart: First row", header]);

    // First look to see if there really is a header row
    for (String label in header) {
      match = StringSimilarity.findBestMatch(label, Person.labels);
//      print(["Looping through header entries", label, match.bestMatch.target, match.bestMatch.rating, match.bestMatchIndex]);

      if (match.bestMatch.rating > 0.80) {
        labelMapping[match.bestMatch.target] = match.bestMatchIndex;
      }
    }

    // If the Label Map has both of the required "name" and "number" then say the header is valid
    if (labelMapping.containsKey(Person.requiredLabels[0]) && labelMapping.containsKey(Person.requiredLabels[1])) {
      headerPresent = true;
    }

    // If no header was found directly via the search, then try to find the entry labels manually
    if (!headerPresent) {
//      print("No Header found in initial check for 1st row, will need to find numbers and other labels via regex");
      resolveLabels(header);
    }

//    print("phone_list.dart: Done finding headers");
  }

  void buildPeople() {
//    print("phone_list.dart: Convert rows to people");
    List<List<dynamic>> rows = [];

    // If a header was determined to people found, then select the correct entries from the
    // loaded csv
    if (headerPresent) {
      rows = data.sublist(1);
    } else {
      rows = data;
    }

    // By now we assume correct evaluation of the labels/matching indices to now do a proper lookup
    // within each `row`
    for (List<dynamic> entry in rows) {
      people.add(
          Person(entry[labelMapping["name"]], entry[labelMapping["number"]].toString())
      );
    }
//    print("phone_list.dart: Done settings");
  }

  void resolveLabels(List<dynamic> row) {
    // Try to ascertain the correct minimally required labels to be able to loop through calls
    int index=0;
    dynamic text;
    bool nameFound = false;
    bool phoneFound = false;
    bool emailFound = false;

    for (text in row) {
      // Check to see if we found a name already, and check if we haven't found one
      if (!nameFound) {
        nameFound = checkName(text, index);
      }

      // Check to see if we found a phone number already, and check if we haven't found one
      if (!phoneFound) {
        phoneFound = checkPhoneNumber(text, index);
      }

      // Check to see if we found as email already, and check if we haven't found one
      if (!emailFound) {
        emailFound = checkEmail(text, index);
      }

      index++; // Increase iterator by one so we can keep track of the current row index
    }
  }

  bool checkName(String text, int index) {
    bool matched = MagicRegex.isName(text);

    // If there is a match with the regular expression, then store this text's index entry into the LabelMap
    if (matched) {
      labelMapping["name"] = index;
    }
    return matched;
  }

  bool checkPhoneNumber(String text, int index) {
    bool matched = MagicRegex.isNumber(text);

    // If there is a match with the regular expression, then store this text's index entry into the LabelMap
    if (matched) {
      labelMapping["number"] = index;
    }
    return matched;
  }

  bool checkEmail(String text, int index) {
    bool matched = MagicRegex.isEmail(text);

    // If there is a match with the regular expression, then store this text's index entry into the LabelMap
    if (matched) {
      labelMapping["email"] = index;
    }
    return matched;
  }



  List<List> encode() {
    List<List> headers = [];
    headers.add(Person.labels);
    return headers + List<List>.generate(people.length, (int idx) => people[idx].encode());
  }
}
