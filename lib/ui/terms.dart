import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollableAssetText extends StatefulWidget {
  final String assetPath;

  ScrollableAssetText({Key key, this.assetPath}) : super(key: key);

  @override
  ScrollableAssetTextState createState() => ScrollableAssetTextState();
}

class ScrollableAssetTextState extends State<ScrollableAssetText> {
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        color: Colors.grey,
        child: Scrollbar(
            child: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.all(5),
                    child: FutureBuilder(
                        future: rootBundle.loadString(widget.assetPath),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? '',
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600));
                        })))));
  }
}

/// Pre-defined Widgets functions for returning specific Scrollable Text widgets
Widget termsAndConditions() => ScrollableAssetText(assetPath: "assets/text/terms_conditions.txt");
Widget changelog() => ScrollableAssetText(assetPath: "CHANGELOG.md");
