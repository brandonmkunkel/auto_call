import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

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
              // color: Colors.grey,
              child: Scrollbar(
                  showTrackOnHover: true,
                  isAlwaysShown: true,
                  interactive: true,
                  child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Container(
                          padding: EdgeInsets.all(5),
                          child: FutureBuilder(
                              future: rootBundle.loadString(widget.assetPath),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? '',
                                  softWrap: true,
                                  textAlign: widget.textAlign,
                                );
                              }))))))
    ]);
  }
}

class ReleaseNotes extends StatefulWidget {
  final bool mostRecentOnly;
  ReleaseNotes({Key key, this.mostRecentOnly = false}) : super(key: key);

  @override
  ReleaseNotesState createState() => ReleaseNotesState();
}

class ReleaseNotesState extends State<ReleaseNotes> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: rootBundle.loadString("CHANGELOG.md"),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // return CustomScrollView(shrinkWrap: true, scrollDirection: Axis.vertical, slivers: <Widget>[
          //   SliverList(
          //     delegate: SliverChildListDelegate(splitMarkdownText(widget.mostRecentOnly
          //             ? snapshot.data.substring(0, snapshot.data.indexOf("#", 1))
          //             : snapshot.data)),
          //   )
          // ]);

          return Markdown(
            data: widget.mostRecentOnly ? snapshot.data.substring(0, snapshot.data.indexOf("#", 1)) : snapshot.data,
            selectable: true,
            extensionSet: md.ExtensionSet.commonMark,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  // List<Widget> splitMarkdownText(String text) {
  //   List<String> versionTexts = text.split("#");
  //   versionTexts.removeAt(0);
  //
  //   // versionTexts.forEach((element) {return "#"+element;});
  //
  //
  //   // print(versionTexts);
  //
  //   List<Widget> out = [];
  //   String version;
  //
  //   versionTexts.forEach((element) {
  //     print("#"+element);
  //
  //     ExpansionTile(),
  //
  //     // out.add(Markdown(
  //     //         data: "#"+element,
  //     //         selectable: true,
  //     //         extensionSet: md.ExtensionSet.commonMark,
  //     //       ));
  //   });
  //
  //   return out;
  //
  // }
}

///
/// Version Text is used to create a Text Widget which specifies the current version of the app
///
class VersionText extends StatefulWidget {
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
    return Text('$appName version: $version+$buildNumber');
  }
}

/// Pre-defined Widgets functions for returning specific Scrollable Text widgets
Widget termsAndConditions() => ScrollableAssetText(assetPath: "assets/text/terms_conditions.txt");
Widget privacyPolicy() => ScrollableAssetText(assetPath: "assets/text/privacy_policy.txt");

Widget autoCallCopyright({TextAlign textAlign = TextAlign.center}) =>
    Text("© Copyright 2020-${DateTime.now().year} Brandon Kunkel", textAlign: textAlign);

// Whole page versions of the above
Widget termsAndConditionsPage() =>
    Scaffold(appBar: AppBar(title: Text("Terms and Conditions")), body: termsAndConditions());
Widget privacyPolicyPage() => Scaffold(appBar: AppBar(title: Text("Privacy Policy")), body: privacyPolicy());
