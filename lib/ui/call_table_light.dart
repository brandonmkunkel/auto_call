import 'package:flutter/material.dart';

import 'package:auto_call/services/phone_list.dart';
import 'package:auto_call/ui/widgets/call_table_widgets.dart';

class CallTableLight extends StatefulWidget {
  final PhoneList phoneList;
  final ScrollController scrollController;
  final List<bool> acceptedColumns;
  final Function callback;

  CallTableLight(
      {Key key,
      @required this.phoneList,
      @required this.scrollController,
      @required this.callback,
      this.acceptedColumns})
      : super(key: key);

  @override
  _CallTableState createState() => _CallTableState();
}

class _CallTableState extends State<CallTableLight> {
  double rowSize = kMinInteractiveDimension;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        decoration: BoxDecoration(color: Theme.of(context).textTheme.subtitle1.backgroundColor),
        child: ListTile(
          dense: true,
          leading: SizedBox(width: 65),
          title: Text("Name", style: Theme.of(context).textTheme.subtitle1),
          trailing: Text("Phone", style: Theme.of(context).textTheme.subtitle1),
        ),
      ),
      Expanded(
          child: Scrollbar(
              showTrackOnHover: true,
              // hoverThickness: 10,
              isAlwaysShown: true,
              interactive: true,
              // radius: Radius.circular(10),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                controller: widget.scrollController,
                scrollDirection: Axis.vertical,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) => RowWidget(
                              i: index,
                              iterator: widget.phoneList.iterator,
                              height: rowSize,
                              person: widget.phoneList.people[index],
                              callback: widget.callback),
                          itemCount: widget.phoneList.people.length),
                      Container(
                          padding: EdgeInsets.only(top: 0.5 * rowSize),
                          height: rowSize * 2.0,
                          alignment: Alignment.topCenter,
                          child: const Text("End of Phone List", textAlign: TextAlign.center))
                    ]),
              )))
    ]);
  }
}

class RowWidget extends StatefulWidget {
  final int i;
  final int iterator;
  final double height;
  final Person person;
  final Function callback;

  const RowWidget({Key key, this.i, this.iterator, this.height, this.person, this.callback}) : super(key: key);

  @override
  _RowWidgetState createState() => _RowWidgetState();
}

class _RowWidgetState extends State<RowWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        dense: true,
        leading: SizedBox(
            width: 65,
            child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(
                width: 36.0,
                child: widget.i == widget.iterator
                    ? Icon(
                        Icons.forward,
                        color: Theme.of(context).iconTheme.color,
                      )
                    : IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon: Icon(Icons.check_circle,
                            color: widget.person.called
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).disabledColor),
                        onPressed: () {
                          setState(() {
                            widget.person.called = !widget.person.called;
                          });
                        }),
              ),
              CalledText(text: (widget.i + 1).toString(), called: widget.person.called),
            ])),
        title: CalledText(text: widget.person.name, called: widget.person.called),
        trailing: CalledText(text: widget.person.phone, called: widget.person.called),
        onTap: () => widget.callback(widget.i));
  }
}
