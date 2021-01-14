import 'package:flutter/material.dart';

class ScrollableTermsConditions extends StatelessWidget {
  const ScrollableTermsConditions({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scrollbar(child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
            child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(5),
              color: Colors.grey,
              child: FutureBuilder(
                  future: DefaultAssetBundle.of(context).loadString("assets/text/terms_conditions.txt"),
                  builder: (context, snapshot) {
                    return Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          snapshot.data ?? '',
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ));
                  }),
            ),
          ],
        ));
      },
    ));
  }
}
