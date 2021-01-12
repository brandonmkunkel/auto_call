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
      resizeToAvoidBottomPadding: false,
      drawer: AppDrawer(),
      appBar: new AppBar(
        title: const Text('File Selection'),
      ),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
                child: Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Text("Selected File:", style: Theme.of(context).textTheme.headline6),
                  Divider(),
                  Builder(
                    builder: (BuildContext context) => _loadingPath
                        ? Center(child: SizedBox(height: 100.0, width: 100.0, child: const CircularProgressIndicator()))
                        : _paths != null
                            // ? Center(child: Text("sample"),)
                            ? Container(
                                // child: Scrollbar(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: _paths != null && _paths.isNotEmpty ? _paths.length : 1,
                                  itemBuilder: (BuildContext context, int index) {
                                    final bool isMultiPath = _paths != null && _paths.isNotEmpty;
                                    final String name =
                                        (isMultiPath ? _paths.map((e) => e.name).toList()[index] : _fileName ?? '...');
                                    final String path = _paths.map((e) => e.path).toList()[index].toString();

                                    return ListTile(
                                      title: Text('File ${index + 1}: $name'),
                                      subtitle: Text('Path: $path'),
                                    );
                                  },
                                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                                ),
                                // ),
                              )
                            : Center(child: Text("No file selected", style: Theme.of(context).textTheme.bodyText1)),
                  ),
                ],
              ),
            )),
            Card(
                child: Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Call Session Settings", style: Theme.of(context).textTheme.headline6),
                  Divider(),
                  Container(padding: EdgeInsets.all(15.0), child: Text("Coming soon!")),
                  // ListTile(leading: Text("Title:"), title: TextFormField(autofocus: false, decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10), border: OutlineInputBorder(), hintText: '..........'),)),
                  // ListTile(leading: Text("Stuff:"), title: TextFormField(autofocus: false, decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10), border: OutlineInputBorder(), hintText: '..........'),)),
                  // ListTile(leading: Text("Stuff:"), title: TextFormField(autofocus: false, decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10), border: OutlineInputBorder(), hintText: '..........'),)),
                  // ListTile(leading: Text("Stuff:"), title: TextFormField(autofocus: false, decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10), border: OutlineInputBorder(), hintText: '..........'),)),
                ],
              ),
            )),
            Expanded(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(10.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                    FloatingActionButton.extended(
                      heroTag: "reselect_file",
                      icon: Icon(Icons.file_upload),
                      label: new Text("Reselect File", style: Theme.of(context).textTheme.headline6),
                      backgroundColor: Colors.red,
                      onPressed: () => _openFileExplorer(),
                    ),
                    FloatingActionButton.extended(
                        heroTag: "accept_file",
                        icon: Icon(Icons.check),
                        label: new Text("Continue", style: Theme.of(context).textTheme.headline6),
                        backgroundColor: Theme.of(context).accentColor,
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
                        }),
                  ])),
            )
          ],
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: Padding(
      //     padding: const EdgeInsets.all(20.0),
      //     child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
      //       FloatingActionButton.extended(
      //         heroTag: "reselect_file",
      //         icon: Icon(Icons.file_upload),
      //         label: new Text("Reselect File", style: Theme.of(context).textTheme.headline6),
      //         backgroundColor: Colors.red,
      //         onPressed: () => _openFileExplorer(),
      //       ),
      //       FloatingActionButton.extended(
      //           heroTag: "accept_file",
      //           icon: Icon(Icons.check),
      //           label: new Text("Continue", style: Theme.of(context).textTheme.headline6),
      //           backgroundColor: Theme.of(context).accentColor,
      //           onPressed: () async {
      //             if (_paths != null) {
      //               Navigator.popAndPushNamed(
      //                 context,
      //                 CallSessionPage.routeName,
      //                 arguments: FileManager(_paths[0].path),
      //               );
      //             } else {
      //               showNoFileError(context);
      //             }
      //           }),
      //     ])),
    );
  }
}
