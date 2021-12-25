import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_call/classes/phone_list.dart';

///
/// The purpose of these tests is to verify the reading/parsing of txt files for correct header and row names
///
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PhoneList Build from TXT via root bundle', () async {
    String data = await rootBundle.loadString('test/assets/sample_numbers.txt');
    PhoneList phoneList = await PhoneList.fromString(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMap["name"], 0);
    expect(phoneList.labelMap["phone"], 1);
  });

  test('PhoneList Build from CSV via root bundle', () async {
    String data = await rootBundle.loadString('test/assets/sample_numbers.csv');
    PhoneList phoneList = await PhoneList.fromString(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMap["name"], 0);
    expect(phoneList.labelMap["phone"], 1);
  });

  // test('PhoneList Build from Excel via root bundle', () async {
  //   ByteData data = await rootBundle.load('test/assets/sample_numbers.xlsx');
  //   PhoneList phoneList = await PhoneList.fromString(data);
  //
  //   // Verify that our counter has incremented.
  //   expect(phoneList.headerPresent, true);
  //   expect(phoneList.isNotEmpty(), true);
  //   expect(phoneList.labelMap["name"], 0);
  //   expect(phoneList.labelMap["phone"], 1);
  // });

  // test('PhoneList Build from Excel', () async {
  //   // String data = await rootBundle.loadString('test/assets/sample_numbers.xlsx');
  //   PhoneList phoneList = PhoneList.fromFile('test/assets/sample_numbers.xlsx');
  //
  //   // Verify that our counter has incremented.
  //   expect(phoneList.headerPresent, true);
  //   expect(phoneList.isNotEmpty(), true);
  //   expect(phoneList.labelMap["name"], 0);
  //   expect(phoneList.labelMap["phone"], 1);
  // });

  test('PhoneList Build from CSV with extra rows at the bottom to ignore', () async {
    String data = await rootBundle.loadString('test/assets/book23_backup.txt');
    PhoneList phoneList = await PhoneList.fromString(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMap["name"], 0);
    expect(phoneList.labelMap["phone"], 1);
    expect(phoneList.labelMap["policy"], 2);
  });
}
