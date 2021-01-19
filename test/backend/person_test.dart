import 'package:flutter_test/flutter_test.dart';

import 'package:auto_call/services/phone_list.dart';


///
/// The purpose of these tests is to verify the Person class used for storing maintaining the call information
///
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // test('Person Outcomes keys simplified', () async {
  //   // List keys = Person.resultMap.keys.toList();
  //   // List updatedKeys = Person.resultMap.keys.where((String outcome) => outcome.isNotEmpty).toList();
  //   // assert(keys.length != updatedKeys.length);
  // });

  group('Person constructor default', () {
    int id = 0;
    String name = "spongebob squarepants";
    String phone = "8007766437";

    Person person = Person(id: id, name: name, phone: phone);

    test("id is correct", () => expect(person.id, id));
    test("name is correct", () => expect(person.name, name));
    test("number is correct", () => expect(person.phone, phone));
    test("email is blank", () => expect(person.email, ""));
    test("note is blank", () => expect(person.note, ""));
    test("not called", () => expect(person.called, false));

  });

  group('Person constructor default', () {
    int id = 0;
    String name = "spongebob squarepants";
    String phone = "8007766437";
    String email = "pineapple@bikini_bottom.com";

    Person person = Person(id: id, name: name, phone: phone, email: email);

    // Verify that our counter has incremented.
    test("id is correct", () => expect(person.id, id));
    test("name is correct", () => expect(person.name, name));
    test("number is correct", () => expect(person.phone, phone));
    test("email is blank", () => expect(person.email, email));
    test("note is blank", () => expect(person.note, ""));
    test("not called", () => expect(person.called, false));
  });

  group('Person constructor with optional data', () {
    int id = 0;
    String name = "spongebob squarepants";
    String phone = "8007766437";
    String email = "pineapple@bikini_bottom.com";
    String note = "oh yeah this is the stuff";
    String result = "voicemail";
    bool called = false;
    List additionalData = ["12341234", "USA"];

    Person person = Person(
        id: id,
        name: name,
        phone: phone,
        email: email,
        note: note,
        result: result,
        called: called,
        additionalData: additionalData
    );

    // Verify that our counter has incremented.
    test("id is correct", () => expect(person.id, id));
    test("name is correct", () => expect(person.name, name));
    test("phone is correct", () => expect(person.phone, phone));
    test("email is correct", () => expect(person.email, email));
    test("note is correct", () => expect(person.note, note));
    test("result is correct", () => expect(person.result, result));
    test("called is correct", () => expect(person.called, called));
    test("additional data is correct", () => expect(person.additionalData, additionalData));
  });

}
