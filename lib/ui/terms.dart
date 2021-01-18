import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollableTermsConditions extends StatelessWidget {
  ScrollableTermsConditions({Key key}) : super(key: key);

  Future<String> termsFuture = rootBundle.loadString("assets/text/terms_conditions.txt");

  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        color: Colors.grey,
        child: Scrollbar(
                child: SingleChildScrollView(
                    child: FutureBuilder(
                        future: termsFuture,
                        builder: (context, snapshot) {
                          return Container(
                              padding: EdgeInsets.all(10),
                              child: Text(snapshot.data ?? '',
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600)));
                        }))));
  }
}
