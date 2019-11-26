import 'package:flutter/material.dart';
import 'services/file_reader.dart';

class CallQueuePage extends StatefulWidget {
  static String routeName = "/numbers";
  final String title = "Call Queue";

  @override
  CallQueueState createState() => new CallQueueState();
}

class CallQueueState extends State<CallQueuePage> {
  bool inCall = false;

  @override
  void initState() {
    super.initState();
  }

//  @override
//  void setState(){
//    super.initState();
//  }

  void changeCallState() {
    setState(() {
      inCall = !inCall;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cancel, color: Theme.of(context).buttonColor),
            iconSize: 40.0,
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
//            Padding(
//              padding: EdgeInsets.all(10.0),
//              child: Container(
//                alignment: Alignment.centerRight,
//                child: FloatingActionButton(
//                  heroTag: "btn_close",
//                  onPressed: () {
//                    Navigator.pop(context);
//                  },
//                  tooltip: 'Close Call Queue',
//                  child: Icon(Icons.clear),
//                ),
//              ),
//            ),
            Expanded(
              child: Center(
                  child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DataTableInStreamBuilder(),
                  ],
                ),
              )),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                child: Center(
                    child: Row(
                  children: <Widget>[
                    FloatingActionButton(
                        onPressed: () {}, heroTag: "btn_back", tooltip: "Back", child: Icon(Icons.arrow_back)),
                    FloatingActionButton(
                      onPressed: () {
                        changeCallState();
                      },
                      heroTag: "btn_cancel",
                      tooltip: "Cancel",
                      child: inCall ? Icon(Icons.cancel) : Icon(Icons.call),
                      backgroundColor: inCall ? Colors.red : Theme.of(context).accentColor,
                    ),
                    FloatingActionButton(
                        onPressed: () {}, heroTag: "btn_forward", tooltip: "Forward", child: Icon(Icons.arrow_forward)),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ))
                // fill in required params
                ),
          ],
        ),
      ),
    );
  }
}
