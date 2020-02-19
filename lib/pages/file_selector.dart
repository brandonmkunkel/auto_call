import 'package:auto_call/services/file_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/pages/call_queue.dart';

import 'package:auto_call/ui/alerts/file_warning.dart';

class FileSelectorPage extends StatefulWidget {
  static String routeName = "/file_selector";

  @override
  FileSelectorState createState() => FileSelectorState();
}

class FileSelectorState extends State<FileSelectorPage> {
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
    _openFileExplorer();
  }

  void _openFileExplorer() async {
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(type: _pickingType, fileExtension: _extension);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(type: _pickingType, fileExtension: _extension);
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null ? _path.split('/').last : _paths != null ? _paths.keys.toString() : '...';
      });
    }
  }

  Future<PhoneList> readFileAsync() async {
    List<List<dynamic>> data = await readCSVFile(_path);
    return PhoneList.fromData(data);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: AppDrawer(context),
      appBar: new AppBar(
        title: const Text('File Selection'),
      ),
      body: new Center(
        child: new Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Selected Files:",
                style: TextStyle(fontSize: 24),
              ),
              Divider(),
              Expanded(
                child: new Builder(
                  builder: (BuildContext context) => _loadingPath
                      ? Center(child: SizedBox(height: 50.0, width: 50.0, child: const CircularProgressIndicator()))
                      : _path != null || _paths != null
                          ? new Container(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: new Scrollbar(
                                  child: new ListView.separated(
                                itemCount: _paths != null && _paths.isNotEmpty ? _paths.length : 1,
                                itemBuilder: (BuildContext context, int index) {
                                  final bool isMultiPath = _paths != null && _paths.isNotEmpty;
                                  final String name = 'File $index: ' +
                                      (isMultiPath ? _paths.keys.toList()[index] : _fileName ?? '...');
                                  final path = isMultiPath ? _paths.values.toList()[index].toString() : _path;

                                  return new ListTile(
                                    title: new Text(
                                      name,
                                    ),
                                    subtitle: new Text(path),
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) => new Divider(),
                              )),
                            )
                          : new Container(),
                ),
              ),
              Divider(),
              new Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: new Column(
                  children: <Widget>[
                    Text(
                      "Are these files correct?",
                      style: TextStyle(fontSize: 24),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Spacer(flex: 1),
                        ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width * 0.40,
                          height: MediaQuery.of(context).size.width * 0.15,
                          child: RaisedButton(
                            color: Colors.redAccent,
                            onPressed: () => _openFileExplorer(),
                            child: new Text("No", style: TextStyle(fontSize: 32.0)),
                          ),
                        ),
                        Spacer(flex: 1),
                        ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width * 0.40,
                          height: MediaQuery.of(context).size.width * 0.15,
                          child: RaisedButton(
                            color: Colors.greenAccent,
                            onPressed: () async {
                              if (_path != null) {
                                Navigator.pushNamed(
                                  context,
                                  CallQueuePage.routeName,
                                  arguments: await readFileAsync(),
                                );
                              } else {
                                showNoFileError(context);
                              }
                            },
                            child: new Text("Yes", style: TextStyle(fontSize: 32.0)),
                          ),
                        ),
                        Spacer(flex: 1)
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
