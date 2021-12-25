import 'package:contacts_service/contacts_service.dart';

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
  final int id;
  final String name;
  final String phone;
  String email = "";
  bool called = false;
  String note = "";
  String result = "";
  List<String> additionalData = [];
  List<String> additionalLabels = [];
  Map<String, String> additional = {};

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

  Person(
      {required this.id,
      required this.name,
      required this.phone,
      String email = "",
      String result = "",
      String note = "",
      bool called = false,
      List<dynamic> additionalLabels = const [],
      List<dynamic> additionalData = const []}) {
    this.email = email;

    this.called = called;
    this.result = result;
    this.note = note;
    this.additionalData = additionalData.isNotEmpty ? additionalData.cast<String>() : [];
    this.additionalLabels = additionalLabels.isNotEmpty ? additionalData.cast<String>() : [];
  }

  static Person fromContact(int id, Contact contact) {
    String number = contact.phones?.elementAt(0).value ?? "";
    return Person(id: id, name: "${contact.givenName} ${contact.familyName}", phone: number);
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
