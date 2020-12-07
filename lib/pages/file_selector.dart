import 'package:auto_call/services/file_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/pages/call_session.dart';

import 'package:auto_call/ui/prompts/file_warning.dart';

class FileSelectorPage extends StatefulWidget {
  static const String routeName = "/file_selector";
  static String title = "File Selector";
  static String label = "File Selector";

  @override
  FileSelectorState createState() => FileSelectorState();
}

class FileSelectorState extends State<FileSelectorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension = "txt,csv,xls,xlsx";
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.custom;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
    _openFileExplorer();
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      if (_multiPick) {
        _path = null;
        _paths = await FilePicker.getMultiFilePath(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false) ? _extension?.replaceAll(' ', '')?.split(',') : null);
      } else {
        _paths = null;
        _path = await FilePicker.getFilePath(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false) ? _extension?.replaceAll(' ', '')?.split(',') : null);
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

  void _clearCachedFiles() {
    FilePicker.clearTemporaryFiles().then((result) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: result ? Colors.green : Colors.red,
          content: Text((result ? 'Temporary files removed with success.' : 'Failed to clean temporary files')),
        ),
      );
    });
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
                padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: new Column(
                  children: <Widget>[
                    SizedBox(
                      height: 40.0,
                      child: Text(
                        "Is this file correct?",
                        style: TextStyle(fontSize: 24),
                      ),
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
                            color: Theme.of(context).disabledColor,
                            onPressed: () => _openFileExplorer(),
                            child: new Text("Reselect", style: Theme.of(context).textTheme.display1),
                          ),
                        ),
                        Spacer(flex: 1),
                        ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width * 0.40,
                          height: MediaQuery.of(context).size.width * 0.15,
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              if (_path != null) {
                                Navigator.popAndPushNamed(
                                  context,
                                  CallSessionPage.routeName,
                                  arguments: FileManager(_path),
                                );
                              } else {
                                showNoFileError(context);
                              }
                            },
                            child: new Text("Yes", style: Theme.of(context).textTheme.display1),
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
