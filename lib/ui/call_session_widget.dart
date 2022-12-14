import 'package:flutter/material.dart';
import 'package:auto_call/pages/settings.dart';

import 'package:auto_call/services/calls_and_messages_service.dart';
import 'package:auto_call/services/file_manager.dart';
import 'package:auto_call/classes/phone_list.dart';
import 'package:auto_call/ui/call_table.dart';
import 'package:auto_call/ui/call_table_light.dart';
// import 'package:auto_call/ui/call_table_new.dart';
// import 'package:auto_call/ui/call_table_sticky.dart';
import 'package:auto_call/ui/prompts/call_prompts.dart';
import 'package:auto_call/ui/prompts/post_session_prompt.dart';
import 'package:auto_call/ui/widgets/call_page_widgets.dart';
import 'package:auto_call/classes/settings_manager.dart';

class CallSessionWidget extends StatefulWidget {
  final String title = "Call Session";
  final FileManager fileManager;
  final PhoneList phoneList;

  CallSessionWidget({Key? key, required this.phoneList, required this.fileManager}) : super(key: key);

  @override
  CallSessionWidgetState createState() => new CallSessionWidgetState();
}

class CallSessionWidgetState extends State<CallSessionWidget> {
  bool inCall = false;
  double rowSize = kMinInteractiveDimension;
  late ScrollController _controller;
  List<TextEditingController> textControllers = [];
  List<FocusNode> focusNodes = [];
  List<bool> acceptedColumns = [];

  // Getters for file managers/phone list
  FileManager get fileManager => widget.fileManager;
  PhoneList get phoneList => widget.phoneList;

  // Helpful Settings Getters
  bool get postCallPromptEnabled => globalSettingManager.get("postCallPrompt");
  bool get autoCallEnabled => globalSettingManager.isPremium() ? globalSettingManager.get("autoCall") : false;
  bool get oneTouchCallEnabled => globalSettingManager.get("oneTouchCall");
  bool get editColumnsEnabled => globalSettingManager.isPremium() ? globalSettingManager.get("editColumns") : false;
  bool get showNotes => globalSettingManager.get("showNotes");

  @override
  void initState() {
    // Start up the Scroll Controller
    _controller = ScrollController(keepScrollOffset: true, initialScrollOffset: rowSize * phoneList.iterator);

    // Set a setting to show that there is an active call session
    globalSettingManager.set("activeCallSession", true);

    fileManager.outputFilePath().then((String path) {
      globalSettingManager.set("activeCallSessionPath", path);
    });

    // Get settings for this page from the SettingsManager
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose of text/scroll controllers
    _controller.dispose();
    textControllers.forEach((_textController) => _textController.dispose());
    focusNodes.forEach((focusNode) => focusNode.dispose());
  }

  Future<bool> managedCall() async {
    bool callState = false;

    PhoneManager.call(phoneList.currentPerson().phone, this.oneTouchCallEnabled);

//    await waitForCallCompletion(phoneList.currentPerson().phone);

    // report that the call is over
    return callState;
  }

  Future<void> makeCall(BuildContext context) async {
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

      // Async save to log the current progress each call
      fileManager.saveCallSession(phoneList);
    });
  }

  Future<void> makeAutoCall(BuildContext context) async {
    if (this.autoCallEnabled) {
      // Make consecutive calls
      while (!phoneList.isComplete() && this.autoCallEnabled) {
        await makeCall(context);
      }
    } else {
      // Make a single call
      await makeCall(context);
    }
  }

  // Update the Scroll controller based on the given item offset
  void updateController(int iterator) {
    _controller.animateTo(
      rowSize * iterator,
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 400),
    );
  }

  // Advance the scroll controller one place
  void advanceController({bool forward = true}) {
    setState(() {
      // int origIterator = phoneList.iterator;

      phoneList.advance(forward: forward);

      // int offset = phoneList.iterator - origIterator;
      updateController(phoneList.iterator);
    });
  }

  void setStateIterator(int i) {
    setState(() {
      FocusScope.of(context).unfocus();

      // Only do a scroll update if the selected item is kinda far away, to avoid annoying scroll animations
      phoneList.iterator = i;
    });
  }

  // Check that the phonelist is complete
  bool isComplete() => phoneList.isComplete();

  @override
  Widget build(BuildContext context) {
    //     if (editColumns && acceptedColumns.isEmpty) {
    //   showDialog(context: context, barrierDismissible: true, child: PreSessionPrompt(fileManager: fileManager)).then(
    //           (dynamic columns) {
    //         acceptedColumns = columns;
    //       }
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          // CallSettingsButton(),
          SaveButton(fileManager: fileManager, phoneList: phoneList),
          CallCloseButton(fileManager: fileManager, phoneList: phoneList),
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                // Trigger a Widget redraw after pulling form settings
                await Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage()));

                setState(() {});
              })
        ],
      ),
      body: showNotes
          ? CallTable(
              phoneList: phoneList,
              scrollController: _controller,
              textControllers: textControllers,
              callback: setStateIterator,
            )
          : CallTableLight(
              phoneList: phoneList,
              scrollController: _controller,
              callback: setStateIterator,
            ),
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
                        tooltip: "Back",
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      FloatingActionButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          await makeAutoCall(context);
                        },
                        heroTag: "btn_call",
                        tooltip: "Call",
                        child: inCall ? Icon(Icons.cancel) : Icon(Icons.call),
                        backgroundColor: inCall ? Colors.red : Theme.of(context).colorScheme.primary,
                      ),
                      FloatingActionButton.extended(
                        label: Text('Next'),
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          advanceController(forward: true);
                        },
                        heroTag: "btn_next",
                        tooltip: "Forward",
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
                      var result = await showDialog(
                          context: context,
                          builder: (_) => PostSessionPrompt(fileManager: fileManager, phoneList: phoneList));

                      // Remove all pages in stack and return to home
                      Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
                    })
            // fill in required params
            ),
      ),
    );
  }
}
