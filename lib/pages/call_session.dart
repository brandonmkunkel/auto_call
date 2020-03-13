import 'package:flutter/material.dart';

import 'package:auto_call/services/calls_and_messages_service.dart';
import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/call_table.dart';
import 'package:auto_call/ui/call_table_new.dart';
import 'package:auto_call/ui/prompts/call_prompts.dart';
import 'package:auto_call/ui/prompts/post_session_prompt.dart';
import 'package:auto_call/services/settings_manager.dart';

class CallSessionPage extends StatefulWidget {
  static const String routeName = "/call_session";
  final String title = "Call Session";
  final String label = "Call Session";
  final FileManager fileManager;

  CallSessionPage({Key key, @required this.fileManager}) : super(key: key);

  @override
  CallSessionState createState() => new CallSessionState();
}

class CallSessionState extends State<CallSessionPage> {
  bool inCall = false;
  double rowSize = kMinInteractiveDimension;
  ScrollController _controller;
  List<TextEditingController> textControllers = [];
  List<FocusNode> focusNodes = [];

  // Getter for file manager from widget parent
  FileManager get fileManager => widget.fileManager;

  @override
  void initState() {
//    tableSource = CallTableSource(fileManager);
    _controller = ScrollController(keepScrollOffset: true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    textControllers.forEach((_textController) {
      _textController?.dispose();
    });
    focusNodes.forEach((focusNode) {
      focusNode?.dispose();
    });
  }

  Future<bool> monitorCallState() async {
    // Collect whether the user wants to call immediately
    bool oneTouch = globalSettingManager.getSetting("one_touch_call");

    if (oneTouch) {
      oneTouchCall(fileManager.phoneList.currentPerson().phone);
    } else {
      twoTouchCall(fileManager.phoneList.currentPerson().phone);
    }

    // report that the call is over
    return false;
  }

  Future<void> makeCall() async {
    bool inCall = await monitorCallState();

    bool postCallPrompt = globalSettingManager.getSetting("post_call_prompt");
    print(postCallPrompt);

    if (postCallPrompt) {
      // Show after call dialog after the call is complete
      await showDialog(
          context: context,
          builder: (BuildContext context) => AfterCallPrompt(
                person: fileManager.phoneList.currentPerson(),
                callIdx: fileManager.phoneList.iterator,
                controller: textControllers[fileManager.phoneList.iterator],
              ));
    }

    // Update the Widgets on this page
    setState(() {
      fileManager.phoneList.currentPerson().called = true;
    });
  }

  // Update the Scroll controller based on the given item offset
  void updateController(int iteratorOffset) {
    _controller.animateTo(
      _controller.offset + rowSize * iteratorOffset,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 500),
    );
  }

  void setStateIterator(int i) {
    setState(() {
      FocusScope.of(context).unfocus();

      // Only do a scroll update if the selected item is kinda far away, to avoid annoying scroll animations
      int desiredOffset = i - fileManager.phoneList.iterator;
      updateController(desiredOffset.abs() > 5 ? desiredOffset : 0);
      fileManager.phoneList.iterator = i;
    });
  }

  Future<PhoneList> callTableFuture() async {
    if (fileManager.phoneList == null) {
      await fileManager.readFile();
    }

    return fileManager.phoneList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(context),
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: true,
        actions: <Widget>[
          SaveButton(fileManager: fileManager),
          CloseButton(),
        ],
      ),
      body: FutureBuilder<PhoneList>(
          future: callTableFuture(),
          builder: (BuildContext context, AsyncSnapshot<PhoneList> snapshot) {
            return snapshot.hasData
                ? Stack(children: [
//                    NewCallTable(manager: fileManager, scrollController: _controller, textControllers: textControllers),
                    CallTable(manager: fileManager, scrollController: _controller, textControllers: textControllers),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: fileManager.phoneList.isComplete()
                          ? Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Theme.of(context).backgroundColor.withOpacity(1.0),
                                        Theme.of(context).backgroundColor.withOpacity(0.0)
                                      ])),
                              child: FloatingActionButton.extended(
                                  label: Text('Calls Completed'),
                                  icon: Icon(Icons.check_circle),
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();

                                    // Store information from the user prompt
                                    var result = await showDialog(
                                        context: context, child: PostSessionPrompt(fileManager: fileManager));

                                    print("call_session.dart: COMPLETED");
                                  }))
                          : Container(
                              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Theme.of(context).scaffoldBackgroundColor.withOpacity(1.0),
                                        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0)
                                      ])),
                              child: Row(
                                children: <Widget>[
                                  FloatingActionButton.extended(
                                    label: Text('Back'),
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        int origIterator = fileManager.phoneList.iterator;
                                        fileManager.phoneList.reverseIterator();
                                        int offset = fileManager.phoneList.iterator - origIterator;
                                        updateController(offset);
                                      });
                                    },
                                    heroTag: "btn_back",
                                    tooltip: "Back",
                                  ),
                                  FloatingActionButton(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();

                                      await makeCall();

                                      setState(() {
                                        // Advance iterator and update the scroll controller
                                        int origIterator = fileManager.phoneList.iterator;
                                        fileManager.phoneList.advanceIterator();
                                        int offset = fileManager.phoneList.iterator - origIterator;
                                        updateController(offset);
                                      });
                                    },
                                    heroTag: "btn_call",
                                    tooltip: "Call",
                                    child: inCall ? Icon(Icons.cancel) : Icon(Icons.call),
                                    backgroundColor: inCall ? Colors.red : Theme.of(context).accentColor,
                                  ),
                                  FloatingActionButton.extended(
                                    label: Text('Next'),
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();

                                      setState(() {
                                        int origIterator = fileManager.phoneList.iterator;
                                        fileManager.phoneList.advanceIterator();
                                        int offset = fileManager.phoneList.iterator - origIterator;
                                        updateController(offset);
                                      });
                                    },
                                    heroTag: "btn_next",
                                    tooltip: "Call",
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              )
                              // fill in required params
                              ),
                    )
                  ])
                : snapshot.hasError
                    ? Column(
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: ${snapshot.error}'),
                          )
                        ],
                      )
                    : Center(child: SizedBox(width: 50.0, height: 50.0, child: const CircularProgressIndicator()));
          }),
    );
  }
}

class SaveButton extends StatelessWidget {
  final FileManager fileManager;
  SaveButton({this.fileManager});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.save, color: Theme.of(context).accentColor),
      iconSize: 40.0,
      onPressed: () async {
        bool acceptSave = await showDialog(barrierDismissible: false, context: context, child: SaveAlert());

        if (acceptSave) {
          // Find the Scaffold in the widget tree and use
          // it to show a SnackBar.
          await fileManager.saveCallSession();
          await fileManager.saveToOldCalls();

          // Show the snack
          SnackBar snackBar = SnackBar(
            content: Text("File saved to " + await FileManager.savedFilePath(fileManager.path)),
            backgroundColor: Colors.grey[600],
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () async {
                // SDelete the files that were just saved
                await FileManager.deleteFile(await FileManager.savedFilePath(fileManager.path));
                await FileManager.deleteFile(await FileManager.oldCallsPath(fileManager.path));
              },
            ),
          );

          // Show the snackbar
          Scaffold.of(context).showSnackBar(snackBar);
        }
      },
    );
  }
}

class CloseButton extends StatelessWidget {
  final FileManager fileManager;
  CloseButton({this.fileManager});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.cancel, color: Theme.of(context).accentColor),
      iconSize: 40.0,
      onPressed: () async {
        bool acceptClose = await showDialog(
            barrierDismissible: false, context: context, builder: (BuildContext context) => CloseAlert());

        if (acceptClose) {
//          bool acceptSave = await showDialog(
//              barrierDismissible: false, context: context, builder: (BuildContext context) => SaveAlert());
//
//          if (acceptSave) {
//            print("should be doing some saving");
//          }

          Navigator.of(context).pop();
        }
      },
    );
  }
}

class CloseAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Call Session Close Alert"),
      content: Text("Are you sure you want end your call session?"),
      actions: <Widget>[
        FlatButton(child: Text("No"), onPressed: () => Navigator.of(context).pop(false)),
        FlatButton(child: Text("Yes"), onPressed: () => Navigator.of(context).pop(true))
      ],
    );
  }
}

class SaveAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Save Call Session"),
      content: Text("Do you wish to save your call session?"),
      actions: <Widget>[
        FlatButton(child: Text("No"), onPressed: () => Navigator.of(context).pop(false)),
        FlatButton(child: Text("Yes"), onPressed: () => Navigator.of(context).pop(true))
      ],
    );
  }
}
