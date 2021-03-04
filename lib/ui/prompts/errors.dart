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
  final Exception error;
  const GeneralErrorWidget({this.errorText, this.error});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Icon(Icons.error_outline, color: Colors.red, size: 50),
      Padding(
          padding: const EdgeInsets.all(30),
          child: SelectableText(
            '${this.errorText}:\n\n${this.error}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ))
    ]);
  }
}
