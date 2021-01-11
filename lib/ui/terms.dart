import 'package:flutter/material.dart';

class ScrollableTermsConditions extends StatelessWidget {
  const ScrollableTermsConditions({Key key, }) : super(key: key);

  Widget build(BuildContext context) {
    return Scrollbar(child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                  // flex: 0,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  // A flexible child that will grow to fit the viewport but
                  // still be at least as big as necessary to fit its contents.
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          color: Colors.grey,
                          child: new FutureBuilder(
                              future: DefaultAssetBundle.of(context).loadString("assets/text/terms_conditions.txt"),
                              builder: (context, snapshot) {
                                return Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      snapshot.data ?? '',
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ));
                              }),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        );
      },
    ));
  }
}
