import 'package:flutter_test/flutter_test.dart';

import 'package:auto_call/services/phone_list.dart';


///
/// The purpose of these tests is to verify the reading/parsing of string data for PhoneList information
///

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhoneList Build from data with header', () {
    List<List<dynamic>> data = [
      ["name", "phone"],
      ["bob", 8007766437],
      ["edward", 8007784339]
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    test("header present", () => expect(phoneList.headerPresent, true));
    test("not empty", () => expect(phoneList.isNotEmpty(), true));
    test("label mapping - name match", () => expect(phoneList.labelMapping["name"], 0));
    test("label mapping - phone match", () => expect(phoneList.labelMapping["phone"], 1));
  });

  group('PhoneList Build with email', () {
    List<List<dynamic>> data = [
      ["name", "phone", "email"],
      ["bob", 8007766437, "bob@squarepants.com"],
      ["edward", 8007784339, "edward@squid.com"],
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    test("header present", () => expect(phoneList.headerPresent, true));
    test("not empty", () => expect(phoneList.isNotEmpty(), true));
    test("label mapping - name match", () => expect(phoneList.labelMapping["name"], 0));
    test("label mapping - phone match", () => expect(phoneList.labelMapping["phone"], 1));
    test("label mapping - email match", () => expect(phoneList.labelMapping["email"], 2));
  });

  group('PhoneList Build from data with header but split names', () {
   // List<List<dynamic>> data = [
   //   ["first name", "last name", "phone"],
   //   ["bob", "squarepants", 8007766437],
   //   ["edward", "tentacles", 8007784339]
   // ];
   // // Instantiation
   // PhoneList phoneList = PhoneList.fromData(data);
   //
   // // Verify that our counter has incremented.
   // test("header present", () => expect(phoneList.headerPresent, true));
   // test("not empty", () => expect(phoneList.isNotEmpty(), true));
   // test("label mapping - name match", () => expect(phoneList.labelMapping["name"], 0));
   // test("label mapping - phone match", () => expect(phoneList.labelMapping["phone"], 1));
  });

  group('PhoneList Build from data with poor formatting', () {
    List<List<dynamic>> data = [
      ["NaMe", "phone", "EMAil"],
      ["bob", 8007766437, "bob@squarepants.com"],
      ["edward", 8007784339, "edward@squid.com"],
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    test("header present", () => expect(phoneList.headerPresent, true));
    test("not empty", () => expect(phoneList.isNotEmpty(), true));
    test("label mapping - name match", () => expect(phoneList.labelMapping["name"], 0));
    test("label mapping - phone match", () => expect(phoneList.labelMapping["phone"], 1));
    test("label mapping - email match", () => expect(phoneList.labelMapping["email"], 2));
  });

  group('PhoneList Build from data with additional headers', () {
    List<List<dynamic>> data = [
      ["name", "phone", "email", "policy number", "location"],
      ["bob", 8007766437, "bob@squarepants.com", 1233, "Pineapple"],
      ["edward", 8007784339, "edward@squid.com", 1234, "Easter Island Head"],
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    test("header present", () => expect(phoneList.headerPresent, true));
    test("not empty", () => expect(phoneList.isNotEmpty(), true));
    test("label mapping - name match", () => expect(phoneList.labelMapping["name"], 0));
    test("label mapping - phone match", () => expect(phoneList.labelMapping["phone"], 1));
    test("label mapping - email match", () => expect(phoneList.labelMapping["email"], 2));

    // Verify additional headers
    test("label mapping - 3 correct", () => expect(phoneList.labelMapping[data[0][3]], 3));
    test("label mapping - 4 correct", () => expect(phoneList.labelMapping[data[0][4]], 4));
  });

  ///
  /// These are hopefully rarer, but the PhoneList should at least be able to read
  /// these to some extent
  ///

  group('PhoneList Build from data without header', () {
    List<List<dynamic>> data = [
      ["bob", 8007766437, "bob@squarepants.com"],
      ["edward", 8007784339, "edward@squid.com"],
    ];

    // Instantiation
    PhoneList phoneList = PhoneList.fromData(data);

    // Verify that our counter has incremented.
    test("no header present", () => expect(phoneList.headerPresent, false));
    test("list not empty", () => expect(phoneList.isNotEmpty(), true));
    test("label mapping - name match", () => expect(phoneList.labelMapping["name"], 0));
    test("label mapping - phone match", () => expect(phoneList.labelMapping["phone"], 1));
    test("label mapping - email match", () => expect(phoneList.labelMapping["email"], 2));
  });

  // group('PhoneList Build from data with poor formatting', () {
  //   List<List<dynamic>> data = [
  //     [" NaMe", " NuMBeR ", " EMAil "],
  //     ["bob ", 8007766437, " bob@squarepants.com "],
  //     ["edward ", 8007784339, " edward@squid.com "],
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
