import 'package:flutter/material.dart';

Widget buildScrollableTerms(BuildContext context) {
  return new Scrollbar(child: new LayoutBuilder(
    builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight,
            minWidth: viewportConstraints.maxWidth,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                  flex: 0,
                  // A flexible child that will grow to fit the viewport but
                  // still be at least as big as necessary to fit its contents.
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.grey[0],
                        child: new FutureBuilder(
                            future: DefaultAssetBundle.of(context).loadString("assets/text/terms_conditions.txt"),
                            builder: (context, snapshot) {
                              return new Text(snapshot.data ?? '',
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ));
                            }),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      );
    },
  ));
}
