import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:auto_call/pages/call_session.dart';
import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/ui/drawer.dart';
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
  String _directoryPath;
  FilePickerResult _result;
  List<PlatformFile> _paths;
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
      _directoryPath = null;
      _result = await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        allowedExtensions: (_extension?.isNotEmpty ?? false) ? _extension?.replaceAll(' ', '')?.split(',') : null,
      );
      _paths = _result?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }

    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName = _paths != null ? _paths.map((e) => e.name).toString() : '...';
    });
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _directoryPath = value);
    });
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
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
              Text("Selected Files:", style: TextStyle(fontSize: 24)),
              Divider(),
              Expanded(
                child: new Builder(
                  builder: (BuildContext context) => _loadingPath
                      ? Center(child: SizedBox(height: 100.0, width: 100.0, child: const CircularProgressIndicator()))
                      : _paths != null
                          ? Container(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: Scrollbar(
                                  child: ListView.separated(
                                itemCount: _paths != null && _paths.isNotEmpty ? _paths.length : 1,
                                itemBuilder: (BuildContext context, int index) {
                                  final bool isMultiPath = _paths != null && _paths.isNotEmpty;
                                  final String name = 'File $index: ' +
                                      (isMultiPath ? _paths.map((e) => e.name).toList()[index] : _fileName ?? '...');
                                  final path = _paths.map((e) => e.path).toList()[index].toString();

                                  return ListTile(
                                    title: Text(name),
                                    subtitle: Text(path),
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) => const Divider(),
                              )),
                            )
                          : Container(),
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
                              if (_paths != null) {
                                Navigator.popAndPushNamed(
                                  context,
                                  CallSessionPage.routeName,
                                  arguments: FileManager(_paths[0].path),
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
