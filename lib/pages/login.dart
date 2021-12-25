import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/button_builder.dart';

import 'package:auto_call/pages/register.dart';
import 'package:auto_call/pages/sign_in.dart';
import 'package:auto_call/ui/terms.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = "/login";

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Navigates to a new page
  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Logo
              // Align(
              //   child: SizedBox(
              //       width: MediaQuery.of(context).size.shortestSide / 3.0, child: Image.asset("assets/images/logo.png")),
              // ),

              SignInWidget(),

              // Text("Don't have an account? "),
              Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        child: SignInButtonBuilder(
                          icon: Icons.person_add,
                          backgroundColor: Colors.indigo,
                          text: 'Create Account',
                          onPressed: () => _pushPage(context, RegisterPage()),
                        ),
                        padding: const EdgeInsets.only(top: 10),
                        alignment: Alignment.center,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText2,
                            children: <TextSpan>[
                              TextSpan(text: 'By clicking Create Account, you agree to our '),
                              TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (context) => termsAndConditionsPage()));
                                    }),
                              TextSpan(text: ' and that you have read our '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (context) => privacyPolicyPage()));
                                  },
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            ],
          ),
        ));
  }
}
