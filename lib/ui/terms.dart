import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:package_info/package_info.dart';

class ScrollableAssetText extends StatefulWidget {
  final String assetPath;
  final TextAlign textAlign;

  ScrollableAssetText({Key key, @required this.assetPath, this.textAlign = TextAlign.center}) : super(key: key);

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
                              textAlign: widget.textAlign,
                              style: TextStyle(fontWeight: FontWeight.w600));
                        })))));
  }
}


// class ScrollableAssetTextState extends State<ScrollableAssetText> {
//   Widget build(BuildContext context) {
//     return Container(
//         padding: EdgeInsets.all(5),
//         color: Colors.grey,
//         child: Scrollbar(
//             child: FutureBuilder(
//                         future: rootBundle.loadString(widget.assetPath),
//                         builder: (context, snapshot) {
//                           return Column(
//                             children: [Markdown(data: snapshot.data ?? '')],
//                           );
//                         })));
//   }
// }



class VersionText extends StatefulWidget {
  VersionText({Key key}) : super(key: key);

  @override
  VersionTextState createState() => VersionTextState();
}

class VersionTextState extends State<VersionText> {
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot.data);
            PackageInfo packageInfo = snapshot.data;
            // String appName = packageInfo.appName;
            // String packageName = packageInfo.packageName;
            String version = packageInfo.version;
            String buildNumber = packageInfo.buildNumber;

            return Text('App Version: $version+$buildNumber');
          }

          return Text('App Version: ');
        });
  }
}

/// Pre-defined Widgets functions for returning specific Scrollable Text widgets
Widget termsAndConditions() => ScrollableAssetText(assetPath: "assets/text/terms_conditions.txt");
Widget privacyPolicy() => ScrollableAssetText(assetPath: "assets/text/privacy_policy.txt");
Widget changelog() => ScrollableAssetText(assetPath: "CHANGELOG.md", textAlign: TextAlign.start);

Widget autoCallCopyright({TextAlign textAlign=TextAlign.center}) => Text("Copyright 2021 - Brandon Kunkel", textAlign: textAlign,);
