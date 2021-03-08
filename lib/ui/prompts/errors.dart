import 'package:flutter/material.dart';

void showFileEmptyError(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("File Load Error"),
        content: Text("No data could be found in the selected file. Trying picking a properly formatted file."),
        actions: <Widget>[
          TextButton(
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

class GeneralErrorWidget extends StatelessWidget {
  final String errorText;
  final dynamic error;
  const GeneralErrorWidget({this.errorText, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Error"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.arrow_back),
        label: Text("Go Back"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(30),
              child: Icon(Icons.error_outline, color: Colors.red, size: 50),
            ),
            SelectableText(
              '${this.errorText}:\n',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
            SelectableText(
              '${this.error}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ])),
    );
  }
}
