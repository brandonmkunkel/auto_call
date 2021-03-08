import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/services/regex.dart';


///
/// CSV FILES
///
class CSVWrapper {
  Future<List<List<dynamic>>> read(String path) async {
    Stream input = File(path).openRead().transform(utf8.decoder);
    return await input.transform(new CsvToListConverter()).toList();
  }

  Future<void> save(String path, List<List<dynamic>> data) async {
    File(path)
      ..createSync(recursive: true)
      ..writeAsString(ListToCsvConverter().convert(data));
  }
}

///
/// Excel Files
///
class ExcelWrapper {
  static SpreadsheetDecoder decoder;

  Future<List<List<dynamic>>> readBytes(Uint8List bytes) async {
    decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
    return List.generate(decoder.tables[decoder.tables.keys.first].maxRows, (int idx) {
      return decoder.tables[decoder.tables.keys.first].rows[idx];
    });
  }

  Future<List<List<dynamic>>> read(String path) async {
    Uint8List bytes = File(path).readAsBytesSync();
    decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
    return List.generate(decoder.tables[decoder.tables.keys.first].maxRows, (int idx) {
      return decoder.tables[decoder.tables.keys.first].rows[idx];
    });
  }

  Future<void> save(String path, List<List<dynamic>> data) async {
    var sheet = decoder.tables.keys.first;

    if (data[0].length != decoder.tables[decoder.tables.keys.first].maxCols) {
      int missingCols = data[0].length - decoder.tables[decoder.tables.keys.first].maxCols;
      for (int idx = 0; idx < missingCols; idx++) {
        decoder.insertColumn(sheet, decoder.tables[decoder.tables.keys.first].maxCols);
      }
    }

    int rowIdx = 0;
    for (List row in data) {
      for (int idx = 0; idx < row.length; idx++) {
        decoder.updateCell(sheet, idx, rowIdx, row[idx]);
      }
    }

    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(decoder.encode());
  }
}

///
/// File Manager takes a path, uses the correct file interface and loads the
///
class FileManager {
  final Map<String, dynamic> registeredInterfaces = {
    "csv": CSVWrapper(),
    "txt": CSVWrapper(),
    "xls": ExcelWrapper(),
    "xlsx": ExcelWrapper(),
  };
  String path;
  String formattedTime;

  /// Construct a FileManager object based off a file path
  FileManager.fromFile(String path, {bool reuseDateTime = false}) {
    this.path = path;
    this.formattedTime = reuseDateTime ? "" : getFormattedTime();

    if (!this.checkValidExtension()) {
      print("Not a valid file type");
    }
  }

  /// Returns file name of input file used by FileManager based on its path
  String get fileName => getFileName(path);

  /// Returns directory of FileManager instance based on its path
  String get directory => getDirectory(path);

  /// Returns extension of FileManager instance based on its path
  String get extension => getExtension(path);

  /// Check to see if the given file is one of the approved file types
  bool checkValidExtension() => registeredInterfaces.containsKey(extension);

  // Get the file interface based off of the chosen file extension
  dynamic get interface => registeredInterfaces[extension];

  ///
  /// Futures based file interaction with instances of FileManager
  ///
  Future<PhoneList> readFile() async {
    // Read the file from the stored path
    return await PhoneList.fromData(await registeredInterfaces[extension].read(path));
  }

  Future<void> saveCallSession(PhoneList phoneList) async {
    String oldCallsPath = await callsDirectory() + callFilePath(path, date: formattedTime);
    await _saveFile(oldCallsPath, phoneList.export());
  }

  // Save the file to the same location but under a new name
  Future<void> _saveFile(String path, List<List> data) async {
    if (checkValidExtension()) {
      // Request permissions for the storage to save back into the original folder
      if (await Permission.storage.status == PermissionStatus.denied) {
        await Permission.storage.request();
      }

      await registeredInterfaces[extension].save(path, data);
    } else {
      print("Not a valid file type");
    }
  }

  String outputFileName() {
    return callFilePath(path, date: formattedTime);
  }

  Future<String> outputFilePath() async {
    return await callsDirectory() + outputFileName();
  }

  ///
  /// All class methods accessible outside of any instance
  ///
  static String getFileName(String path) {
    return path.split("/").last;
  }

  static String getDirectory(String path) {
    List pathComponents = path.split("/");
    pathComponents.removeLast();
    return pathComponents.join("/");
  }

  static String getExtension(String path) {
    return path.split(".").last;
  }

  // Get the date modified of this file
  static String getDateModified(String path) {
    return File(path).lastModifiedSync().toString();
  }

  static String updatedFilePath(String path) {
    // Split at the extension label, add "update" and rejoin to not overwrite the excel sheet
    List paths = path.split(".");
    paths[paths.lastIndexOf(paths.last) - 1] += "_updated";
    return paths.join(".");
  }

  static Future<String> userDirectory() async {
    // Get the user Directory from the Path Provider lib
    Directory dir = await getExternalStorageDirectory();
    return dir.path;
  }

  static Future<String> savedFilePath(String path) async {
    return await callsDirectory() + getFileName(path);
  }

  static Future<String> callsDirectory() async {
    // Get the old calls directory from within the App's document directory
    Directory dir = await getApplicationDocumentsDirectory();
    Directory oldCallsDir = Directory(dir.path + "/call_sessions/");

    // Create the directory
    if (!await oldCallsDir.exists()) {
      oldCallsDir.create(recursive: true);
    }
    return oldCallsDir.path;
  }

  static String callFilePath(String path, {String date = ""}) {
    // Split at the extension label, add "update" and rejoin to not overwrite the excel sheet
    List name = getFileName(path).split(".");
    String dateString = date ?? getFormattedTime();
    name[name.lastIndexOf(name.last) - 1] += "_" + dateString;
    return name.join(".");
  }

  // Formatted time is used for saving into old call files and the global database
  static String getFormattedTime() {
    return fileDateFormat().format(DateTime.now());
  }

  // Look through the old calls directory and look for saved old calls
  static Future<List<String>> findOldCalls() async {
    Directory _oldCallsDir = Directory(await callsDirectory());
    List _files = _oldCallsDir.listSync(recursive: false);
    return List.generate(_files.length, (int idx) => _files[idx].path);
  }

  static Future<void> deleteFile(String path) async {
    File file = File(path);
    if (file.existsSync()) {
      file.deleteSync(recursive: false);
    }
  }

  static String dateFormatString() {
    return 'yyyy-MM-dd_kk-mm-ss';
  }

  static DateFormat fileDateFormat() {
    // Standardize the DateTime format used in naming files
    return DateFormat(dateFormatString());
  }
}
