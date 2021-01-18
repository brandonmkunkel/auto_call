import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  final String text;
  const HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyText1.color,
          fontSize: Theme.of(context).textTheme.bodyText2.fontSize * 1.2,
          fontWeight: FontWeight.bold,
        ));
  }
}

class CalledText extends StatelessWidget {
  final String text;
  final bool called;
  TextAlign align = TextAlign.left;

  CalledText({this.text, this.called, this.align});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: align,
        style: TextStyle(
            color: called ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyText1.color,
            fontSize: Theme.of(context).textTheme.bodyText1.fontSize));
  }
}
