import 'package:auto_call/services/settings_manager.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:auto_call/services/phone_list.dart';

class AfterCallPrompt extends StatefulWidget {
  final Person person;
  final int callIdx;
  final TextEditingController controller;

  AfterCallPrompt({Key key, @required this.person, @required this.callIdx, this.controller}) : super(key: key);

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
    bool premium = globalSettingManager.getSetting("is_premium");
    bool autoCall = globalSettingManager.getSetting("auto_call");

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).backgroundColor.withOpacity(0.9)),
      child: SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          titlePadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          title: GestureDetector(
              onTap: () => _focusNode.unfocus(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[Text("Call Completed (#${widget.callIdx + 1})"), Divider()],
              )),
          children: [
            Column(children: <Widget>[
              GestureDetector(
                  onTap: () => _focusNode.unfocus(),
                  child: Column(
                      children: <Widget>[
//                      Divider(),
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
                    title: Text("Call Result:"),
                    trailing: DropdownButton<String>(
                        hint: Text("Result"),
                        value: widget.person.result.isEmpty
                            ? null
                            : widget.person.result,
                        onChanged: (String value) {
                          _focusNode.unfocus();
                          setState(() {
                            widget.person.result = value;
                          });
                        },
                        elevation: 16,
                        items: Person.resultMap.keys
                            .where((String outcome) => outcome.isNotEmpty)
                            .toList()
                            .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            )
                        ).toList())),
              )
            ]),
            Align(
              alignment: Alignment.centerRight,
              child:
                  Row(mainAxisAlignment: premium ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end, children: [
                premium
                    ? RaisedButton(
                        child: autoCall ? Text("Pause Auto Call") : Text("Restart Auto Call"),
                        onPressed: () {
                          setState(() {
                            globalSettingManager.setSetting("auto_call", !autoCall);
                          });
                        },
                        color: autoCall ? Colors.red : Colors.green,
                      )
                    : Container(),
                RaisedButton(child: Text("Done"), onPressed: () => Navigator.of(context).pop())
              ]),
            )
          ]),
    );
  }
}
