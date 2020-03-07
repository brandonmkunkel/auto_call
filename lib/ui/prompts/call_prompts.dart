import 'package:flutter/material.dart';
import 'package:auto_call/services/phone_list.dart';

class AfterCallPrompt extends StatefulWidget {
  final Person person;
  final int callIdx;
  final TextEditingController controller;

  AfterCallPrompt({
    Key key,
    @required this.person,
    @required this.callIdx,
    this.controller
  }) : super(key: key);

  @override
  AfterCallPromptState createState() => new AfterCallPromptState();
}

class AfterCallPromptState extends State<AfterCallPrompt> {
  FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = new FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        titlePadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        title: GestureDetector(
            onTap: () => _focusNode.unfocus(),
            child: Text("Call Completed (#${widget.callIdx + 1})", textAlign: TextAlign.center)),
        children: [
          Column(children: <Widget>[
            GestureDetector(
                onTap: () => _focusNode.unfocus(),
                child: Column(
                    children: <Widget>[
                          Divider(),
                          Row(
                              children: [Text("Name:"), Text("${widget.person.name}")],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween),
                          Row(
                              children: [Text("Phone:"), Text("${widget.person.phone}")],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween),
                        ] +
                        List.generate(widget.person.additionalData.length, (int idx) {
                          return Row(children: [
                            Text(widget.person.additionalLabels[idx]),
                            Text(widget.person.additionalData[idx])
                          ], mainAxisAlignment: MainAxisAlignment.spaceBetween);
                        }))),
            Divider(),
            TextFormField(
              focusNode: _focusNode,
              controller: widget.controller,
              autofocus: false,
              maxLines: 1,
              onChanged: (String text) {
                setState(() {
                  widget.person.note = text;
                });
              },
              decoration:
                  InputDecoration(labelText: "Note:", border: OutlineInputBorder(), hintText: 'Take a note here'),
            ),
            Divider(),
            GestureDetector(
              onTap: () => _focusNode.unfocus(),
              child: ListTile(
                  title: Text("Call Outcome:"),
                  trailing: DropdownButton<String>(
                      hint: Text("Outcome"),
                      value: widget.person.outcome,
                      onChanged: (String value) {
                        _focusNode.unfocus();
                        setState(() {
                          widget.person.outcome = value;
                        });
                      },
                      elevation: 16,
                      items: Person.possibleOutcomes.map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList())),
            )
          ]),
          Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(child: Text("Done"), onPressed: () => Navigator.of(context).pop()),
          )
        ]);
  }
}
