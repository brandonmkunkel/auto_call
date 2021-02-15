import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:auto_call/pages/call_page.dart';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/ui/drawer.dart';

class FileSelectorPage extends StatefulWidget {
  static const String routeName = "/file_selector";
  static String title = "File Selector";
  static String label = "File Selector";

  @override
  FileSelectorState createState() => FileSelectorState();
}

class FileSelectorState extends State<FileSelectorPage> {
  String _fileName;
  String _directoryPath;
  FilePickerResult _result;
  List<PlatformFile> _paths;
  String _extension = "txt,csv,xls,xlsx";
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.custom;

  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();

  @override
  void initState() {
    super.initState();

    controller1 = TextEditingController();
    controller2 = TextEditingController();
    _focusNode1 = FocusNode();
    _focusNode2 = FocusNode();
  }

  @override
  void dispose() {
    _focusNode1?.dispose();
    _focusNode2?.dispose();
    controller1?.dispose();
    controller2?.dispose();
    super.dispose();
  }

  void _openFileExplorer() async {
    // Either the permission was already granted before or the user just granted it.
    if (await Permission.storage.request().isGranted) {

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

    } else {
      print("no storage permissions");
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('File Selection'),
      ),
      body: InkWell(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Card(
                          child: Container(
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Text(_paths != null ? "Selected File:" : "No File Selected:",
                                style: Theme.of(context).textTheme.headline6),
                            Divider(),
                            Builder(
                              builder: (BuildContext context) => _loadingPath
                                  ? Center(
                                      child:
                                          SizedBox(height: 50.0, width: 50.0, child: const CircularProgressIndicator()))
                                  : _paths != null
                                      ? Container(
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: _paths != null && _paths.isNotEmpty ? _paths.length : 1,
                                            itemBuilder: (BuildContext context, int index) {
                                              final bool isMultiPath = _paths != null && _paths.isNotEmpty;
                                              final String name = (isMultiPath
                                                  ? _paths.map((e) => e.name).toList()[index]
                                                  : _fileName ?? '...');
                                              final String path = _paths.map((e) => e.path).toList()[index].toString();

                                              return ListTile(
                                                title: Text('File Name: $name'),
                                                subtitle: Text('Path: $path'),
                                              );
                                            },
                                            separatorBuilder: (BuildContext context, int index) => const Divider(),
                                          ),
                                          // ),
                                        )
                                      : Center(
                                          child: Text(
                                              "You cannot continue without selecting a file. Please select a file.",
                                              style: Theme.of(context).textTheme.bodyText1)),
                            ),
                            Container(
                                padding: EdgeInsets.all(5.0),
                                alignment: Alignment.bottomRight,
                                child: RaisedButton.icon(
                                  icon: Icon(Icons.upload_file, color: Theme.of(context).primaryTextTheme.button.color),
                                  label: Text(_paths != null ? "Reselect File" : "Select File",
                                      style: Theme.of(context).primaryTextTheme.button),
                                  color: Colors.red,
                                  onPressed: () => _openFileExplorer(),
                                ))
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
                            ListTile(
                                leading: Text("Title:"),
                                title: TextFormField(
                                  controller: controller1,
                                  focusNode: _focusNode1,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                      border: OutlineInputBorder(),
                                      hintText: 'Title'),
                                ), onTap: () => FocusScope.of(context).requestFocus(_focusNode1),),
                            ListTile(
                                leading: Text("Stuff:"),
                                title: TextFormField(
                                  controller: controller2,
                                  focusNode: _focusNode2,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                      border: OutlineInputBorder(),
                                      hintText: '..........'),
                                ), onTap: () => FocusScope.of(context).requestFocus(_focusNode2), ),
                          ],
                        ),
                      )),
                    ],
                  ))),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.,
      floatingActionButton: _paths == null
          ? Container()
          : FloatingActionButton.extended(
              heroTag: "accept_file",
              icon: Icon(Icons.check),
              label: Text("Continue"),
              backgroundColor: Theme.of(context).accentColor,
              onPressed: () async {
                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //     builder: (context) => CallSessionPage(fileManager: FileManager(_paths[0].path))));

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CallSessionPage(fileManager: FileManager.fromFile(_paths[0].path))));
              }),
    );
  }
}
