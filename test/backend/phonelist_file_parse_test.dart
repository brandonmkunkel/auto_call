import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:auto_call/services/phone_list.dart';


///
/// The purpose of these tests is to verify the reading/parsing of txt files for correct header and row names
///
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PhoneList Build from TXT', () async {
    String data = await rootBundle.loadString('assets/test/data/sample_numbers.txt');
    PhoneList phoneList = PhoneList.fromString(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["phone"], 1);
  });

  test('PhoneList Build from TXT', () async {
    PhoneList phoneList = PhoneList.fromFile('assets/test/data/sample_numbers.txt');

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["phone"], 1);
  });

  test('PhoneList Build from CSV', () async {
    String data = await rootBundle.loadString('assets/test/data/sample_numbers.csv');
    PhoneList phoneList = PhoneList.fromString(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["phone"], 1);
  });

//  test('PhoneList Build from Excel', () async {
//    String data = await rootBundle.loadString('assets/test/data/sample_numbers.xlsx');
//    PhoneList phoneList = PhoneList.fromString(data);
//
//    // Verify that our counter has incremented.
//    expect(phoneList.headerPresent, true);
//    expect(phoneList.isNotEmpty(), true);
//    expect(phoneList.labelMapping["name"], 0);
//    expect(phoneList.labelMapping["phone"], 1);
//  });

  test('PhoneList Build from CSV with extra rows at the bottom to ignore', () async {
//    ByteData bytes = await rootBundle.load('assets/test/data/book23.csv');
//    bytes.Uint8.buffer.asUint16List

    String data = await rootBundle.loadString('assets/test/data/book23_backup.txt');
    PhoneList phoneList = PhoneList.fromString(data);

    print(phoneList.additionalLabels);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["phone"], 1);
    expect(phoneList.labelMapping["policy"], 2);
  });
}
