import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return Row(children: [
      Expanded(
          child: Container(
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
                              }))))))
    ]);
  }
}

class VersionText extends StatefulWidget {
  VersionText({Key key}) : super(key: key);

  @override
  VersionTextState createState() => VersionTextState();
}

class VersionTextState extends State<VersionText> {
  String appName;
  String version;
  String buildNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Executes after build is done
      getVersion();
    });
  }

  Future<void> getVersion() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      // Refresh the page once the data is captured
      setState(() {
        appName = packageInfo.appName;
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });
  }

  Widget build(BuildContext context) {
    return Text('App Version: $version+$buildNumber');
  }
}

/// Pre-defined Widgets functions for returning specific Scrollable Text widgets
Widget termsAndConditions() => ScrollableAssetText(assetPath: "assets/text/terms_conditions.txt");
Widget privacyPolicy() => ScrollableAssetText(assetPath: "assets/text/privacy_policy.txt");
Widget changelog() => ScrollableAssetText(assetPath: "CHANGELOG.md", textAlign: TextAlign.start);

Widget autoCallCopyright({TextAlign textAlign = TextAlign.center}) =>
    Text("© Copyright 2020-${DateTime.now().year} Brandon Kunkel", textAlign: textAlign);
