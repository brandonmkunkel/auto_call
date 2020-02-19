import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:string_similarity/string_similarity.dart';

import 'package:auto_call/services/regex.dart';
import 'package:auto_call/ui/alerts/file_warning.dart';
import 'package:auto_call/services/file_io.dart';



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
  List<List<dynamic>> data = [];
  bool headerPresent = false;
  Map<String, int> labelMapping = new Map();
  List<Person> people = [];
  int iterator = 0;

  PhoneList(String path) {
    processFile(path);
  }

  PhoneList.fromFile() {
    // This will eventually be gotten rid of

  }

  PhoneList.fromString(String rawText) {
    data = readTextAsCSV(rawText);
    processData();
  }

  PhoneList.fromData(List<List<dynamic>> inputData) {
    data = inputData;
    processData();
  }

  bool isNotEmpty() {
    return people.isNotEmpty;
  }

  void processFile(String path) async {
    data = await readCSVFile(path);

    processData();
  }

  void processData() {
    if (data.isNotEmpty) {
      findHeaders();
      buildPeople();
    }
  }

  void findHeaders() {
    List<dynamic> header = data[0];
    BestMatch match;

    // First look to see if there really is a header row
    for (int idx=0; idx<header.length; idx++) {
      String label = header[idx].toString();
      match = StringSimilarity.findBestMatch(label.toString().toLowerCase(), Person.labels);

      if (match.bestMatch.rating > 0.75) {
        labelMapping[match.bestMatch.target] = match.bestMatchIndex;
      }
    }

    // If the Label Map has both of the required "name" and "number" then say the header is valid
    if (labelMapping.containsKey(Person.requiredLabels[0]) && labelMapping.containsKey(Person.requiredLabels[1])) {
      headerPresent = true;
    }

    // If no header was found directly via the search, then try to find the entry labels manually
    if (!headerPresent) {
      resolveLabels(header);
    }
  }

  void buildPeople() {
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
//      print([entry[labelMapping["name"]], entry[labelMapping["number"]].toString()]);
      people.add(
          Person(
            entry[labelMapping["name"]],
            entry[labelMapping["number"]].toString(),
            email: labelMapping.containsKey("email") ? entry[labelMapping["email"]] : ""
          )
      );
    }
//    print("phone_list.dart: Done settings");
  }

  void resolveLabels(List<dynamic> row) {
    // Try to ascertain the correct minimally required labels to be able to loop through calls
    int index=0;
    bool nameFound = false;
    bool phoneFound = false;
    bool emailFound = false;

    for (dynamic text in row) {
      // Check to see if we found a name already, and check if we haven't found one
      if (!nameFound) {
        nameFound = checkName(text.toString(), index);
      }

      // Check to see if we found a phone number already, and check if we haven't found one
      if (!phoneFound) {
        phoneFound = checkPhoneNumber(text.toString(), index);
      }

      // Check to see if we found as email already, and check if we haven't found one
      if (!emailFound) {
        emailFound = checkEmail(text.toString(), index);
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
