import 'package:string_similarity/string_similarity.dart';

import 'package:auto_call/services/regex.dart';
import 'package:auto_call/services/file_io.dart';

enum Outcome {
  None,
  Voicemail,
  Answered,
  Success,
  FollowUp,
}

Map<String, Outcome> outcomes = {
  "None": Outcome.None,
  "Voicemail": Outcome.Voicemail,
  "Answered": Outcome.Answered,
  "Success": Outcome.Success,
  "Follow Up": Outcome.FollowUp,
};

class Person {
  bool called = false;
  String name = "";
  String phone = "";
  String email = "";
  String note = "";
  String outcome = "None";
  List<String> additionalData = [];
  List<String> additionalLabels = [];

  static final List<String> labels = ["name", "phone", "email", "outcome", "note", "called"];
  static final List<String> requiredLabels = ["name", "phone"];
  static final List<String> possibleOutcomes = ['None', 'Voicemail', 'Answered', 'Follow Up', 'Success'];

  Person(String name, String phone, {String email="", String outcome="None", String note="", bool called=false, List<dynamic> additionalLabels, List<dynamic> additionalData}) {
    this.name=name;
    this.phone=phone;
    this.email=email;

    this.called=called;
    this.outcome=outcome;
    this.note=note;
    this.additionalData = additionalData != null ? additionalData.cast<String>() : [];
    this.additionalLabels = additionalLabels != null ? additionalData.cast<String>() : [];
  }

  String string() {
    return name + ", " + phone + ", " + email;
  }

  static List<List<String>> orderedLabels() {
    return [["name", "phone", "email"], ["outcome", "note", "called"]];
  }

  List<String> encode() {
    return [name, phone, email] + additionalData + [outcome, note, called.toString()];
  }
}

class PhoneList {
  List<List<dynamic>> data = [];
  bool headerPresent = false;
  Map<String, int> labelMapping = new Map();
  List<String> additionalLabels = [];
  List<Person> people = [];
  int iterator = 0;
  int firstUncalled = 0;
  int lastUncalled = 0;

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
  Person operator[](int idx) => people[idx];

  bool isNotEmpty() {
    return people.isNotEmpty;
  }

  List<List> export() {
    List<List> headers = [Person.orderedLabels()[0] + additionalLabels + Person.orderedLabels()[1]];
    return headers + List<List>.generate(people.length, (int idx) => people[idx].encode());
  }





  ///
  /// Methods for processing information from data that was read
  ///
  void processFile(String path) async {
    processData(await CSVWrapper().read(path));
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

    // If the Label Map has both of the required "name" and "phone" then say the header is valid
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
//      print(entry);
      if (MagicRegex.isName(entry[labelMapping["name"]].toString()) && MagicRegex.isNumber(entry[labelMapping["phone"]].toString())) {
        people.add(
            Person(
              entry[labelMapping["name"]].trim(),
              entry[labelMapping["phone"]].toString().trim(),
              email: labelMapping.containsKey("email") ? entry[labelMapping["email"]].trim() : "",
              note: labelMapping.containsKey("note") ? entry[labelMapping["note"]].trim() : "",
              outcome: labelMapping.containsKey("outcome") ? entry[labelMapping["outcome"]].trim() : "None",
              called: labelMapping.containsKey("called") ? entry[labelMapping["called"]].toString().toLowerCase().trim() == "true" : false,
              additionalLabels: List.generate(additionalLabels.length, (int index) => labelMapping[additionalLabels[index]].toString().trim()),
              additionalData: List.generate(additionalLabels.length, (int index) => entry[labelMapping[additionalLabels[index]]].toString().trim()),
            )
        );
      }
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
      labelMapping["phone"] = index;
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

  List getAdditionalColumns() {
    return List.generate(people.length, (int i) {
      return List.generate(additionalLabels.length, (int idx) {
        return people[i].additionalData[labelMapping[additionalLabels[idx]]];
      });
    });
  }

  // Return the person at the current iterator
  Person currentPerson() {
    return people[iterator];
  }

  bool isComplete() {
    return people?.every((Person person) => person.called == true) ?? false;
  }

  void checkRemainingCallRange() {
    firstUncalled = people.indexWhere((Person p) => !p.called);
    lastUncalled = people.lastIndexWhere((Person p) => !p.called);
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
