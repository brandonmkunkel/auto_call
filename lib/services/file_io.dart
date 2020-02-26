import 'package:csv/csv.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_call/services/phone_list.dart';

///
/// General Async function for reading files
///
Future<FileManager> readFileAsync(String path) async {
  FileManager fileManager = FileManager(path);
  await fileManager.readFile();
  return fileManager;
}

///
/// FileIOWrapper is a class that wraps function pointers
///
class FileIOWrapper {
  const FileIOWrapper(this.read, this.save);

  final Future<List<List<dynamic>>> Function(String) read;
  final void Function(String, List<List<dynamic>>) save;
}

///
/// CSV FILES
///
List<List<dynamic>> readTextAsCSV(String data) {
  return const CsvToListConverter().convert(data);
}

String saveTextAsCSV(List<List<dynamic>> data) {
  return const ListToCsvConverter().convert(data);
}

class CSVWrapper {
  Future<List<List<dynamic>>> read(String path) async {
    final input = File(path).openRead().transform(utf8.decoder);
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
  SpreadsheetDecoder decoder;

  Future<List<List<dynamic>>> read(String path) async {
    var bytes = File(path).readAsBytesSync();
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
  String fileName;
  String ext;
  String formattedTime;
  PhoneList phoneList;

  FileManager(String path) {
    this.path = path;
    this.formattedTime = getFormattedTime();
    this.fileName = getFileName(path);
    this.ext = getExtension(path);
  }

  static String getFileName(String path) {
    List pathComponents = path.split("/");
    return pathComponents.last;
  }

  static String getExtension(String path) {
    List pathComponents = path.split(".");
    return pathComponents.last;
  }

  static String updatedFilePath(String path) {
    // Split at the extension label, add "update" and rejoin to not overwrite the excel sheet
    List paths = path.split(".");
    paths[paths.lastIndexOf(paths.last) - 1] += "_updated";
    return paths.join(".");
  }

  static Future<String> oldCallsDirectory() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Directory oldCallsDir = Directory(dir.path + "/old_calls/");

    // Create the directory
    if (!await oldCallsDir.exists()) {
      oldCallsDir.create();
    }
    return oldCallsDir.path;
  }

  static String oldCallsFileName(String path, {String date = ""}) {
    // Split at the extension label, add "update" and rejoin to not overwrite the excel sheet
    List name = getFileName(path).split(".");
    String dateString = date ?? getFormattedTime();
    name[name.lastIndexOf(name.last) - 1] += "_" + dateString;
    return name.join(".");
  }

  // Formatted time is used for saving into old call files and the global database
  static String getFormattedTime() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd_kk-mm').format(now);
  }

  bool checkValidExtension() {
    return registeredInterfaces.containsKey(ext);
  }

  // Read the file from the stored path
  Future<void> readFile() async {
    if (checkValidExtension()) {
      List<List> data = await registeredInterfaces[ext].read(path);
      this.phoneList = PhoneList.fromData(data);
    } else {
      print("Not a valid file type");
    }
  }

  // Save the file to the same location but under a new name
  Future<void> savePhoneList() async {
    String updatedPath = updatedFilePath(path);
    await saveFile(updatedPath, this.phoneList.export());
  }

  Future<void> saveToOldCalls() async {
    // Create the path for the file to be saved in /old_calls
    String oldCallsPath = await oldCallsDirectory() + oldCallsFileName(path, date: formattedTime);
    await saveFile(oldCallsPath, this.phoneList.export());
  }

  // Save the file to the same location but under a new name
  Future<void> saveFile(String path, List<List> data) async {
    if (checkValidExtension()) {
//      SimplePermissions.requestPermission(Permission.WriteExternalStorage).then((PermissionStatus status) async {
//        if (status == PermissionStatus.authorized) {
//          var filePath = File(path);
//          filePath.exists().then((isThere) {
//            print(isThere);
//            if (isThere) {
//              print("file exists");
//              filePath.deleteSync(recursive: false);
//            }
//          });
//        }
//
//        // Call the load interface of the IO Wrapper
//        await registeredInterfaces[ext].save(path, data);
//      });
      await registeredInterfaces[ext].save(path, data);
    } else {
      print("Not a valid file type");
    }
  }

  // Look through the old calls directory and look for saved old calls
  static Future<List<String>> findOldCalls() async {
    Directory _oldCallsDir = Directory(await oldCallsDirectory());
    List _files = _oldCallsDir.listSync(recursive: false);
    return List.generate(_files.length, (int idx) {
      return _files[idx].path;
    });
  }

  static Future<void> deleteFile(String path) async {
    var filePath = File(path);
    filePath.exists().then((isThere) {
      print(isThere);
      if (isThere) {
        print("file exists");
        filePath.deleteSync(recursive: false);
      }
    });
  }

  void emailFile() async {}
}
