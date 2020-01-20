import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';


class FileStorage {
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/file.txt');
  }

  void readFile() {
    /* What to do? */
  }

  Future<Null> writeFile(String text) async {
    final file = await _localFile;

    IOSink sink = file.openWrite(mode: FileMode.append);
    sink.add(utf8.encode('$text'));
    await sink.flush();
    await sink.close();
  }
}
