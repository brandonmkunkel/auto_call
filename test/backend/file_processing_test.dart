import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:auto_call/services/file_io.dart';


///
/// The purpose of these tests is to verify the reading/parsing of txt files for correct header and row names
///
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FileManager Get extension txt', () async {
    String path = 'assets/test/data/sample_numbers.txt';
    String extension = FileManager.getExtension(path);

    // Verify that our counter has incremented.
    expect(extension, "txt");
  });

  test('FileManager Get extension csv', () async {
    String path = 'assets/test/data/sample_numbers.csv';
    String extension = FileManager.getExtension(path);

    // Verify that our counter has incremented.
    expect(extension, "csv");
  });

  test('FileManager Get extension xlsx', () async {
    String path = 'assets/test/data/sample_numbers.xlsx';
    String extension = FileManager.getExtension(path);

    // Verify that our counter has incremented.
    expect(extension, "xlsx");
  });

  test('FileManager Get extension with . in the middle', () async {
    String path = 'randomplace.com/data/sample_numbers.extension';
    String extension = FileManager.getExtension(path);

    // Verify that our counter has incremented.
    expect(extension, "extension");
  });


  test('FileManager Updated file name', () async {
    String path = 'assets/test/data/sample_numbers.txt';
    String updatedPath = FileManager.updatedFilePath(path);

    // Verify that our counter has incremented.
    expect(updatedPath, 'assets/test/data/sample_numbers_updated.txt');
  });

}
