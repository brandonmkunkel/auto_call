import 'package:flutter/material.dart';


void showFileEmptyError(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("File Load Error"),
        content: Text("No data could be found in the selected file. Trying picking a properly formatted file."),
        actions: <Widget>[
          FlatButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
