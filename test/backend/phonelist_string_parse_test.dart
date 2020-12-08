import 'package:flutter_test/flutter_test.dart';

import 'package:auto_call/services/phone_list.dart';


///
/// The purpose of these tests is to verify the reading/parsing of string data for PhoneList information
///

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ///
  /// Person Tests
  ///
  test('Person constructor default', () async {
    String name = "spongebob squarepants";
    String number = "8007766437";

    Person person = Person(name, number);

    // Verify that our counter has incremented.
    expect(person.name, name);
    expect(person.phone, number);
    expect(person.email, "");
    expect(person.note, "");
    expect(person.called, false);
  });

  test('Person constructor with email', () async {
    String name = "spongebob squarepants";
    String number = "8007766437";
    String email = "pineapple@binikin_bottom.com";

    Person person = Person(name, number, email: email);

    // Verify that our counter has incremented.
    expect(person.name, name);
    expect(person.phone, number);
    expect(person.email, email);
    expect(person.note, "");
    expect(person.called, false);
  });

  test('Person constructor with optional data', () async {
    String name = "spongebob squarepants";
    String number = "8007766437";
    String email = "pineapple@binikin_bottom.com";
    String note = "oh yeah this is the stuff";
    String result = "voicemail";
    bool called = false;
    List additionalData = ["12341234", "USA"];

    Person person = Person(name,
      number,
      email: email,
      note: note,
      result: result,
      called: called,
      additionalData: additionalData
    );

    // Verify that our counter has incremented.
    expect(person.name, name);
    expect(person.phone, number);
    expect(person.email, email);
    expect(person.note, note);
    expect(person.result, result);
    expect(person.called, called);
    expect(person.additionalData, additionalData);
  });

  ///
  /// Phone List Tests
  ///
  test('PhoneList Build from data with header', () async {
    List<List<dynamic>> data = [
      ["name", "phone"],
      ["bob", 8007766437],
      ["edward", 8007784339]
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["phone"], 1);
  });

  test('PhoneList Build with email', () async {
    List<List<dynamic>> data = [
      ["name", "phone", "email"],
      ["bob", 8007766437, "bob@squarepants.com"],
      ["edward", 8007784339, "edward@squid.com"],
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["phone"], 1);
    expect(phoneList.labelMapping["email"], 2);
  });

//  test('PhoneList Build from data with header but split names', () async {
//    List<List<dynamic>> data = [
//      ["first name", "last name", "phone"],
//      ["bob", "squarepants", 8007766437],
//      ["edward", "tentacles", 8007784339]
//    ];
//    // Instantiation
//    PhoneList phoneList = PhoneList.fromData(data);
//
//    // Verify that our counter has incremented.
//    expect(phoneList.headerPresent, true);
//    expect(phoneList.isNotEmpty(), true);
//    expect(phoneList.labelMapping["name"], 0);
//    expect(phoneList.labelMapping["phone"], 1);
//  });


  test('PhoneList Build from data with poor formatting', () async {
    List<List<dynamic>> data = [
      ["NaMe", "phone", "EMAil"],
      ["bob", 8007766437, "bob@squarepants.com"],
      ["edward", 8007784339, "edward@squid.com"],
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["phone"], 1);
    expect(phoneList.labelMapping["email"], 2);
  });


  test('PhoneList Build from data with additional headers', () async {
    List<List<dynamic>> data = [
      ["name", "phone", "email", "policy number", "location"],
      ["bob", 8007766437, "bob@squarepants.com", 1233, "Pineapple"],
      ["edward", 8007784339, "edward@squid.com", 1234, "Easter Island Head"],
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["phone"], 1);
    expect(phoneList.labelMapping["email"], 2);

    // Verify additional headers
    expect(phoneList.labelMapping[data[0][3]], 3);
    expect(phoneList.labelMapping[data[0][4]], 4);
  });

  ///
  /// These are hopefully rarer, but the PhoneList should at least be able to read
  /// these to some extent
  ///
  test('PhoneList Build from data without header', () async {
    List<List<dynamic>> data = [
        ["bob", 8007766437, "bob@squarepants.com"],
        ["edward", 8007784339, "edward@squid.com"],
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, false);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["phone"], 1);
    expect(phoneList.labelMapping["email"], 2);
  });

  // test('PhoneList Build from data with poor formatting', () async {
  //   List<List<dynamic>> data = [
  //     [" NaMe", " NuMBeR ", " EMAil "],
  //     ["bob", 8007766437, "bob@squarepants.com"],
  //     ["edward", 8007784339, "edward@squid.com"],
  //   ];
  //
  //   // Instantiation
  //   PhoneList phoneList = PhoneList.fromData(data);
  //
  //   // Verify that our counter has incremented.
  //   expect(phoneList.headerPresent, true);
  //   expect(phoneList.isNotEmpty(), true);
  //   expect(phoneList.labelMapping["name"], 0);
  //   expect(phoneList.labelMapping["phone"], 1);
  //   expect(phoneList.labelMapping["email"], 2);
  // });
}
