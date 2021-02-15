import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/button_builder.dart';

import 'package:auto_call/services/settings_manager.dart';
import 'package:auto_call/pages/home.dart';

import 'register.dart';
import 'sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

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

              // Login In Card
              // Card(
              //     margin: EdgeInsets.all(10),
              //     child: Container(
              //       child: SignInButtonBuilder(
              //         icon: Icons.verified_user,
              //         backgroundColor: Colors.orange,
              //         text: 'Sign In',
              //         onPressed: () => _pushPage(context, SignInPage()),
              //       ),
              //       padding: const EdgeInsets.all(5),
              //       alignment: Alignment.center,
              //     )),

              SignInWidget(),

              // Text("Don't have an account? "),
              Card(
                margin: EdgeInsets.all(10),
                child: Container(
                  child: SignInButtonBuilder(
                    icon: Icons.person_add,
                    backgroundColor: Colors.indigo,
                    text: 'Create Account',
                    onPressed: () => _pushPage(context, RegisterPage()),
                  ),
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
        ));
  }
}
