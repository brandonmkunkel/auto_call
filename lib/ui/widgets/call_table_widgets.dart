import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  final String text;
  const HeaderText(this.text, {Key key}) : super(key: key);

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
  final TextAlign align;

  const CalledText({Key key, @required this.text, @required this.called, this.align = TextAlign.left})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: align,
        style: TextStyle(
            color: called ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyText1.color,
            fontSize: Theme.of(context).textTheme.bodyText1.fontSize));
  }
}
