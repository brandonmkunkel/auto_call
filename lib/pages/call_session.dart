import 'package:flutter/material.dart';

import 'package:auto_call/services/calls_and_messages_service.dart';
import 'package:auto_call/services/file_io.dart';
import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/ui/drawer.dart';
import 'package:auto_call/ui/call_table.dart';
import 'package:auto_call/ui/call_table_new.dart';
import 'package:auto_call/ui/prompts/call_prompts.dart';
import 'package:auto_call/ui/prompts/post_session_prompt.dart';
import 'package:auto_call/ui/prompts/pre_session_prompt.dart';
import 'package:auto_call/ui/widgets/call_page_widgets.dart';
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
  List<bool> acceptedColumns = [];
  PhoneList phoneList;
  Future<PhoneList> futurePhoneList;

  // Getter for file manager from widget parent
  FileManager get fileManager => widget.fileManager;

  // Helpful Settings Getters
  bool get postCallPromptEnabled => globalSettingManager.get("postCallPrompt");
  bool get autoCallEnabled => globalSettingManager.isPremium() ? globalSettingManager.get("autoCall") : false;
  bool get oneTouchCallEnabled => globalSettingManager.get("oneTouchCall");
  bool get editColumnsEnabled => globalSettingManager.isPremium() ? globalSettingManager.get("editColumns") : false;

  @override
  void initState() {
    // Start up the Scroll Controller
    _controller = ScrollController(keepScrollOffset: true);

    // Set a setting to show that there is an active call session
    globalSettingManager.set("activeCallSession", true);

    // Preliminary start future, so we only load the file once
    futurePhoneList = readFile();

    // Get settings for this page from the SettingsManager
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose of text/scroll controllers
    _controller?.dispose();
    textControllers.forEach((_textController) => _textController?.dispose());
    focusNodes.forEach((focusNode) => focusNode?.dispose());
  }

  Future<bool> managedCall() async {
    bool callState = false;

    PhoneManager.call(phoneList.currentPerson().phone, this.oneTouchCallEnabled);

//    await waitForCallCompletion(phoneList.currentPerson().phone);

    // report that the call is over
    return callState;
  }

  Future<void> makeCall() async {
//    if (inCall) {
    managedCall().then((callState) => inCall = callState);
    print("make call - inCall $inCall");

    if (this.postCallPromptEnabled) {
      // Show after call dialog after the call is complete
      await showDialog(
          context: context,
          builder: (BuildContext context) => AfterCallPrompt(
                person: phoneList.currentPerson(),
                callIdx: phoneList.iterator,
                controller: textControllers[phoneList.iterator],
              ));
    }

    // Update the Widgets on this page
    setState(() {
      phoneList.currentPerson().called = true;
      advanceController(forward: true);
    });
  }

  Future<void> makeAutoCall() async {
    while (!phoneList.isComplete() && this.autoCallEnabled) {
      await makeCall();
    }
  }

  // Update the Scroll controller based on the given item offset
  void updateController(int iteratorOffset) {
    setState(() {
      _controller.animateTo(
        _controller.offset + rowSize * iteratorOffset,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400),
      );
    });
  }

  void advanceController({bool forward = true}) {
    int origIterator = phoneList.iterator;

    phoneList.advance(forward: forward);

    int offset = phoneList.iterator - origIterator;
    updateController(offset);
  }

  void setStateIterator(int i) {
    setState(() {
      FocusScope.of(context).unfocus();

      // Only do a scroll update if the selected item is kinda far away, to avoid annoying scroll animations
      int desiredOffset = i - phoneList.iterator;
      updateController(desiredOffset.abs() > 5 ? desiredOffset : 0);
      phoneList.iterator = i;
    });
  }

  Future<PhoneList> readFile() async {
    return await fileManager.readFile();
  }

  // Check that the phonelist is complete
  bool isComplete() => phoneList?.isComplete() ?? false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futurePhoneList,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //     if (snapshot.hasData && editColumns && acceptedColumns.isEmpty) {
          //   showDialog(context: context, barrierDismissible: true, child: PreSessionPrompt(fileManager: fileManager)).then(
          //           (dynamic columns) {
          //         acceptedColumns = columns;
          //       }
          //   );
          // }

          if (snapshot.hasData && phoneList == null) {
            phoneList = snapshot.data;
          }

          return Scaffold(
            drawer: AppDrawer(),
            appBar: AppBar(
              title: Text(widget.title),
              // automaticallyImplyLeading: true,
              actions: <Widget>[
                CallSettingsButton(),
                SaveButton(fileManager: fileManager, phoneList: phoneList),
                CallCloseButton(),
              ],
            ),

            // Body of Call Session Page
            body: phoneList != null
                ? CallTable(
                    fileManager: fileManager,
                    phoneList: phoneList,
                    scrollController: _controller,
                    textControllers: textControllers)
                // return NewCallTable(manager: fileManager, phoneList: phoneList, scrollController: _controller, textControllers: textControllers)
                : snapshot.hasError
                    ? Column(children: <Widget>[
                        Icon(Icons.error_outline, color: Colors.red, size: 50.0),
                        Padding(padding: const EdgeInsets.only(top: 16), child: Text('Error: ${snapshot.error}'))
                      ])
                    : Center(child: SizedBox(width: 50.0, height: 50.0, child: const CircularProgressIndicator())),

            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(1.0),
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0)
                    ]),
                  ),
                  child: !isComplete()
                      ? Row(
                          children: <Widget>[
                            FloatingActionButton.extended(
                                label: Text('Back'),
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  advanceController(forward: false);
                                },
                                heroTag: "btn_back",
                                tooltip: "Back"),
                            FloatingActionButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();

                                if (autoCallEnabled) {
                                  await makeAutoCall();
                                } else {
                                  await makeCall();
                                }
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
                                advanceController(forward: true);
                              },
                              heroTag: "btn_next",
                              tooltip: "Call",
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        )
                      : FloatingActionButton.extended(
                          label: Text('Calls Completed'),
                          icon: Icon(Icons.check_circle),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();

                            // Store information from the user prompt
                            var result = await showDialog(context: context, child: PostSessionPrompt(fileManager: fileManager, phoneList: phoneList));

                            Navigator.of(context).pop();
                          })
                  // fill in required params
                  ),
            ),
          );
        });
  }
}
