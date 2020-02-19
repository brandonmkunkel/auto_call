import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:auto_call/services/phone_list.dart';


///
/// The purpose of these tests is to verify the reading/parsing of string data for PhoneList information
///

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PhoneList Build from data with header', () async {
    PhoneList phoneList = PhoneList.fromData(
        [["name", "number"],
         ["brandon", 4406675647]]
    );

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["number"], 1);
  });

  test('PhoneList Build from data with poor formatting', () async {
    PhoneList phoneList = PhoneList.fromData(
        [["NaMe", "NuMBeR", "EMAil"],
          ["brandon", 4406675647, ""],
          ["aaron durda", 4406675647, ""],
        ]
    );

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, true);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["number"], 1);
    expect(phoneList.labelMapping["email"], 2);
  });

  test('PhoneList Build from data without header', () async {
    PhoneList phoneList = PhoneList.fromData(
        [["brandon", 4406675647, "brandon@brandon.com"],
         ["aaron durda", 4406675647, "aaron@aaron.com"],
        ]
    );

    // Verify that our counter has incremented.
    expect(phoneList.headerPresent, false);
    expect(phoneList.isNotEmpty(), true);
    expect(phoneList.labelMapping["name"], 0);
    expect(phoneList.labelMapping["number"], 1);
    expect(phoneList.labelMapping["email"], 2);
  });
}
