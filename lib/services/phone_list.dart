import 'package:flutter/foundation.dart';
import 'package:string_similarity/string_similarity.dart';

import 'package:auto_call/services/regex.dart';
import 'package:auto_call/services/file_manager.dart';

enum Result {
  Empty,
  BadNumber,
  Voicemail,
  Answered,
  NotInterested,
  FollowUp,
  Success,
}

class Person {
  int id = 0;
  String name = "";
  String phone = "";
  String email = "";
  bool called = false;
  String note = "";
  String result = "";
  List<String> additionalData = [];
  List<String> additionalLabels = [];
  Map<String, String> additional;

  static final List<String> labels = ["name", "phone", "email", "result", "note", "called"];
  static final List<String> requiredLabels = ["name", "phone"];

  static final Map<String, Result> resultMap = {
    "": Result.Empty,
    "Bad Number": Result.BadNumber,
    "Voicemail": Result.Voicemail,
    "Answered": Result.Answered,
    "Not Interested": Result.NotInterested,
    "Follow Up": Result.FollowUp,
    "Success": Result.Success,
  };

  Person({
      @required int id,
      @required String name,
      @required String phone,
      String email = "",
      String result = "",
      String note = "",
      bool called = false,
      List<dynamic> additionalLabels,
      List<dynamic> additionalData}) {
    this.id = id;
    this.name = name;
    this.phone = phone;
    this.email = email;

    this.called = called;
    this.result = result;
    this.note = note;
    this.additionalData = additionalData != null ? additionalData.cast<String>() : [];
    this.additionalLabels = additionalLabels != null ? additionalData.cast<String>() : [];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> out = {
      "name": name,
      "phone": phone,
      "email": email,
      "result": result,
      "note": note,
      "called": called,
    };
    out.addAll(this.additional);
    return out;
  }

  String string() {
    return "Person{name: $name, phone: $phone, email: $email}";
  }

  static List<List<String>> orderedLabels() {
    return [
      ["name", "phone", "email"],
      ["result", "note", "called"]
    ];
  }

  List<String> encode() {
    return [name, phone, email] + additionalData + [result, note, called.toString()];
  }
}

class PhoneList {
  String path;
  String name;

  bool headerPresent = false;
  Map<String, int> labelMap = new Map();
  List<String> additionalLabels = [];
  List<Person> people = [];
  int iterator = 0;
  int firstUncalled = 0;
  int lastUncalled = 0;

  /// Static asynchronous constructor used for testing
  static Future<PhoneList> fromData(List<List<dynamic>> inputData) async {
    PhoneList phoneList = PhoneList();
    phoneList.processData(inputData);
    return phoneList;
  }

  /// Static asynchronous constructor
  // static Future<PhoneList> fromFile(String path) async {
  //   PhoneList phoneList = await FileManager.readFile();
  //   return await FileManager.readFile();
  // }
  //
  // static Future<PhoneList> fromDB(String path) async {
  //   return await
  // }

  ///
  /// Methods for interacting with the final class
  ///
  int get length => people.length;

  Person operator [](int idx) => people[idx];

  /// Check if the phone List is empty
  bool isNotEmpty() => people.isNotEmpty;

  /// Export the whole PhoneLast as a List of Lists
  List<List<dynamic>> export() {
    return [this.allHeaderLabels()] + List<List<String>>.generate(people.length, (int idx) => people[idx].encode());
  }

  /// Return a string of all Header label strings
  List<String> allHeaderLabels() {
    return Person.orderedLabels()[0] + additionalLabels + Person.orderedLabels()[1];
  }

  /// Return a string of all optionally chosen header labels
  List<String> chosenHeaderLabels() {
    return [];
  }
  //
  // String toString() {
  //   return export().toString();
  // }

  ///
  /// Methods for processing information from data that was read
  ///
  Future<void> processData(List<List<dynamic>> inputData) async {
    if (inputData.isNotEmpty) {
      findHeaders(inputData);
      buildPeople(inputData);

      // Do some bounds checking to set the first iterator correctly
      checkRemainingCallRange();
      iterator = firstUncalled;
    }
  }

  /// Determine or resolve what headers are present within the data
  void findHeaders(List<List<dynamic>> inputData) {
    List<dynamic> header = inputData[0];
    BestMatch match;
    String label;

    // First look to see if there really is a header row
    for (int idx = 0; idx < header.length; idx++) {
      label = header[idx].toString().toLowerCase().trim();
      match = StringSimilarity.findBestMatch(label, Person.labels);

      if (match.bestMatch.rating > 0.75) {
        labelMap[label] = match.bestMatchIndex;
      } else {
        // If we have not found any matched, register this inside or label map
        labelMap[label] = idx;
        additionalLabels.add(label);
      }
    }

    // If the Label Map has both of the required "name" and "phone" then say the header is valid
    if (labelMap.containsKey(Person.requiredLabels[0]) && labelMap.containsKey(Person.requiredLabels[1])) {
      headerPresent = true;
    } else {
      // If no header was found directly via the search, then try to find the entry labels manually
      resolveLabels(header);
    }
  }

  void buildPeople(List<List<dynamic>> inputData) {
    // If a header was determined to people found, then select the correct entries from the
    // loaded csv
    List<List<dynamic>> rows = headerPresent ? inputData.sublist(1) : inputData;

    // By now we assume correct evaluation of the labels/matching indices to now do a proper lookup
    // within each `row`

    rows.asMap().forEach((id, entry) {
      if (MagicRegex.isName(entry[labelMap["name"]].toString()) &&
          MagicRegex.isNumber(entry[labelMap["phone"]].toString())) {
        people.add(Person(
          id: id,
          name: entry[labelMap["name"]].trim(),
          phone: entry[labelMap["phone"]].toString().trim(),
          email: labelMap.containsKey("email") ? entry[labelMap["email"]].trim() : "",
          note: labelMap.containsKey("note") ? entry[labelMap["note"]].trim() : "",
          result: labelMap.containsKey("result") ? entry[labelMap["result"]].trim() : "",
          called: labelMap.containsKey("called")
              ? entry[labelMap["called"]].toString().toLowerCase().trim() == "true"
              : false,
          additionalLabels: List.generate(
              additionalLabels.length, (int index) => labelMap[additionalLabels[index]].toString().trim()),
          additionalData: List.generate(
              additionalLabels.length, (int index) => entry[labelMap[additionalLabels[index]]].toString().trim()),
        ));
      }
    });
  }

  ///
  /// Only Use this function when resolving the headers from no headers
  ///
  void resolveLabels(List<dynamic> row) {
    // Try to ascertain the correct minimally required labels to be able to loop through calls
    int index = 0;
    bool matched;
    bool nameFound = false;
    bool phoneFound = false;
    bool emailFound = false;

    for (dynamic text in row) {
      matched = false;

      // Check to see if we found a name already, and check if we haven't found one
      if (!nameFound) {
        nameFound = MagicRegex.isName(text.toString());
        if (nameFound) labelMap["name"] = index;
        matched = nameFound;
      }

      // Check to see if we found a phone number already, and check if we haven't found one
      if (!phoneFound && !matched) {
        phoneFound = MagicRegex.isNumber(text.toString());
        if (phoneFound) labelMap["phone"] = index;
        matched = phoneFound;
      }

      // Check to see if we found as email already, and check if we haven't found one
      if (!emailFound && !matched) {
        emailFound = MagicRegex.isEmail(text.toString());
        if (emailFound) labelMap["email"] = index;
        matched = emailFound;
      }

      index++; // Increase iterator by one so we can keep track of the current column index
    }
  }

  ///
  /// Checking functions that use Regex for resolving headers from data
  ///
  List getAdditionalColumns() {
    return List.generate(people.length, (int i) {
      return List.generate(additionalLabels.length, (int idx) {
        return people[i].additionalData[labelMap[additionalLabels[idx]]];
      });
    });
  }

  /// Return the person at the current iterator
  Person currentPerson() => people[iterator];

  /// Check if the call list is complete, which requires all persons to be called
  bool isComplete() => people?.every((Person person) => person.called == true) ?? false;

  /// Find the iterator range of the uncalled persons within the list
  void checkRemainingCallRange() {
    firstUncalled = people.indexWhere((Person p) => !p.called);
    lastUncalled = people.lastIndexWhere((Person p) => !p.called);
  }

  /// Advance the iterator either forward or backwards with bounds checking
  void advance({bool forward = true}) {
    if (forward)
      advanceIterator();
    else
      reverseIterator();
  }

  void advanceIterator() {
    checkRemainingCallRange();
    int nextIterator = iterator + 1;

    // Check to see if the next call is the last
    if (isComplete()) {
      nextIterator = people.length;
    } else if (nextIterator > lastUncalled) {
      nextIterator = firstUncalled;
    } else if (people[nextIterator].called) {
      // If the Next entry has been called already, skip
      if (nextIterator > lastUncalled) {
        nextIterator = firstUncalled;
      } else {
        while (people[nextIterator].called) {
          nextIterator++;
        }
      }
    }

    iterator = nextIterator;
  }

  void reverseIterator() {
    checkRemainingCallRange();
    int nextIterator = iterator - 1;

    // Check to see if the next call is the last
    if (isComplete()) {
      nextIterator = -1;
    } else if (nextIterator < firstUncalled) {
      nextIterator = firstUncalled;
    } else if (people[nextIterator].called) {
      // If the Next entry has been called already, skip
      if (nextIterator < firstUncalled) {
        nextIterator = firstUncalled;
      } else {
        while (people[nextIterator].called) {
          nextIterator--;
        }
      }
    }

    iterator = nextIterator;
  }
}
