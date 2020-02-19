// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import 'package:auto_call/services/phone_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MagicRegex isname()', () {
    expect(MagicRegex.isName("Brandon"), true);
    expect(MagicRegex.isName("brandon"), true);
    expect(MagicRegex.isName("ba"), true);
  });

  test('MagicRegex isnumber()', () {
    expect(MagicRegex.isNumber("4406675647"), true);
    expect(MagicRegex.isNumber("440-667-5647"), true);
    expect(MagicRegex.isNumber("(440)667-5647"), true);
  });

  test('PhoneList Build with header', () async {
    String data = await rootBundle.loadString('assets/test/data/sample_numbers.txt');
    PhoneList phoneList = PhoneList.fromString(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["number"], 1);
  });

  test('PhoneList Build with different header', () async {
    String data = await rootBundle.loadString('assets/test/data/sample_numbers_different_headers.csv');
    PhoneList phoneList = PhoneList.fromString(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["number"], 1);
  });

  test('PhoneList Build without header', () async {
    String data = await rootBundle.loadString('assets/test/data/sample_numbers_no_header.txt');
    PhoneList phoneList = PhoneList.fromString(data);

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, false);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["number"], 1);
  });
}
