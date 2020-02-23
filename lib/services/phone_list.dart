import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:string_similarity/string_similarity.dart';

import 'package:auto_call/services/regex.dart';
import 'package:auto_call/ui/alerts/file_warning.dart';
import 'package:auto_call/services/file_io.dart';

enum Outcome {
  voicemail,
  answered,
  success,
}

class Person {
  bool called = false;
  String name = "";
  String number = "";
  String email = "";
  String comment = "";
  String outcome = "";
  List<String> additionalData = [];

  static final List<String> labels = ["name", "number", "email", "comment", "called"];
  static final List<String> requiredLabels = ["name", "number"];

//  Person(String name, String number, {String email, String outcome, String comment, bool called, List<dynamic> additionalData}) {
//    this.name = name;
//    this.number = number;
//
//    this.email=email;
//    this.outcome = outcome;
//    this.comment = comment;
//    this.called = called;
//    this.additionalData = additionalData != null ? additionalData.cast<String>() : [];
//  }

  Person(String name, String number, {String email="", String outcome="", String comment="", bool called=false, List<dynamic> additionalData}) {
    this.name = name;
    this.number = number;
    this.email=email;

    this.called=called;
    this.outcome=outcome;
    this.comment=comment;
    this.additionalData = additionalData != null ? additionalData.cast<String>() : [];
  }

  String string() {
    return name + ", " + number + ", " + email;
  }

  List<String> encode() {
    return [name, number, email, outcome, comment, called.toString()] + additionalData;
  }
}

class PhoneList {
  List<List<dynamic>> data = [];
  bool headerPresent = false;
  Map<String, int> labelMapping = new Map();
  List<String> additionalLabels = [];
  List<Person> people = [];
  int iterator = 0;

  ///
  /// Constructors
  ///
  PhoneList(String path) {
    processFile(path);
  }

  PhoneList.fromFile(String path) {
    processFile(path);
  }

  PhoneList.fromString(String rawText) {
    processData(readTextAsCSV(rawText));
  }

  PhoneList.fromData(List<List<dynamic>> inputData) {
    processData(inputData);
  }

  ///
  /// Methods for interacting with the final class
  ///
  List<List> export() {
    List<List> headers = [Person.labels + additionalLabels];
    return headers + List<List>.generate(people.length, (int idx) => people[idx].encode());
  }

  bool isNotEmpty() {
    return people.isNotEmpty;
  }

  ///
  /// Methods for processing information from data that was read
  ///
  void processFile(String path) async {
    processData(await readCSVFile(path));
  }

  void processData(List<List<dynamic>> inputData) {
    data = inputData;

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
      String label = header[idx].toString().toLowerCase().trim();
      match = StringSimilarity.findBestMatch(label, Person.labels);

      if (match.bestMatch.rating > 0.75) {
        labelMapping[label] = match.bestMatchIndex;
      } else {
        // If we have not found any matched, register this inside or label map
        labelMapping[label] = idx;
        additionalLabels.add(label);
      }
    }

    // If the Label Map has both of the required "name" and "number" then say the header is valid
    if (labelMapping.containsKey(Person.requiredLabels[0]) && labelMapping.containsKey(Person.requiredLabels[1])) {
      headerPresent = true;
    } else {
      // If no header was found directly via the search, then try to find the entry labels manually
      resolveLabels(header);
    }
  }

  void buildPeople() {
    // If a header was determined to people found, then select the correct entries from the
    // loaded csv
    List<List<dynamic>> rows = headerPresent ? data.sublist(1) : data;

    // By now we assume correct evaluation of the labels/matching indices to now do a proper lookup
    // within each `row`

    for (List<dynamic> entry in rows) {
      people.add(
          Person(
            entry[labelMapping["name"]],
            entry[labelMapping["number"]].toString(),
            email: labelMapping.containsKey("email") ? entry[labelMapping["email"]] : "",
            comment: labelMapping.containsKey("comment") ? entry[labelMapping["comment"]] : "",
            outcome: labelMapping.containsKey("outcome") ? entry[labelMapping["outcome"]] : "",
            called: labelMapping.containsKey("called") ? entry[labelMapping["called"]] : false,
            additionalData: List.generate(additionalLabels.length, (int index) => entry[labelMapping[additionalLabels[index]]]),
          )
      );
    }
  }

  ///
  /// Only Use this function when resolving the headers from no headers
  ///
  void resolveLabels(List<dynamic> row) {
    // Try to ascertain the correct minimally required labels to be able to loop through calls
    int index=0;
    bool matched;
    bool nameFound = false;
    bool phoneFound = false;
    bool emailFound = false;

    for (dynamic text in row) {
      matched = false;

      // Check to see if we found a name already, and check if we haven't found one
      if (!nameFound) {
        nameFound = checkName(text.toString(), index);
        matched = nameFound ? true : false;
      }

      // Check to see if we found a phone number already, and check if we haven't found one
      if (!phoneFound && !matched) {
        phoneFound = checkPhoneNumber(text.toString(), index);
        matched = phoneFound ? true : false;
      }

      // Check to see if we found as email already, and check if we haven't found one
      if (!emailFound && !matched) {
        emailFound = checkEmail(text.toString(), index);
        matched = emailFound ? true : false;
      }

      index++; // Increase iterator by one so we can keep track of the current row index
    }
  }

  ///
  /// Checking functions that use Regex for resolving headers from data
  ///
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
}
