import 'package:flutter/material.dart';
import 'services/file_reader.dart';

class OldCallsPage extends StatefulWidget {
  static String routeName = "/old_calls";
  final String title = "Call Queue";

  @override
  OldCallsState createState() => new OldCallsState();
}

class OldCallsState extends State<OldCallsPage> {
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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  heroTag: "btn_close",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  tooltip: 'Close Call Queue',
                  child: Icon(Icons.clear),
                ),
              ),
            ),
            Expanded(
              child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DataTableInStreamBuilder(),
                    ],
                  )

              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                child: Center(
                    child: Row(
                      children: <Widget>[
                        FloatingActionButton(
                            onPressed: () {},
                            heroTag: "btn_back",
                            tooltip: "Back",
                            child: Icon(Icons.arrow_back)),
                        FloatingActionButton(
                          onPressed: () {
                            changeCallState();
                          },
                          heroTag: "btn_cancel",
                          tooltip: "Cancel",
                          child: inCall ? Icon(Icons.cancel) : Icon(Icons.call),
                          backgroundColor:
                          inCall ? Colors.red : Theme.of(context).accentColor,
                        ),
                        FloatingActionButton(
                            onPressed: () {},
                            heroTag: "btn_forward",
                            tooltip: "Forward",
                            child: Icon(Icons.arrow_forward)),
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
