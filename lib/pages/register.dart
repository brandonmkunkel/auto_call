import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/button_builder.dart';

import 'package:auto_call/services/settings_manager.dart';
import 'package:auto_call/ui/terms.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

/// Entrypoint example for registering via Email/Password.
class RegisterPage extends StatefulWidget {
  final String title = 'Registration';

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _success;
  String _userEmail = '';

  bool get agreedToTerms => globalSettingManager.get("agreedToTerms");
  bool get agreedToPrivacyPolicy => globalSettingManager.get("agreedToPrivacyPolicy");

  bool get allowRegistration => this.agreedToTerms && this.agreedToPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            labelText: 'Email', border: OutlineInputBorder()),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      )),
                  Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder()),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        obscureText: true,
                      )),
                  ListTile(
                      trailing: Checkbox(onChanged: (value) {
                        setState(() {
                          globalSettingManager.set("agreedToTerms", value);
                        });

                      }, value: this.agreedToTerms),
                      leading: RichText(
                          text: TextSpan(style: Theme.of(context).textTheme.bodyText2, children: <TextSpan>[
                        TextSpan(text: 'I agree to the '),
                        TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(color: Theme.of(context).accentColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) => termsAndConditionsPage()));
                              })
                      ]))),
                  ListTile(
                      trailing: Checkbox(onChanged: (value) {
                        setState(() {
                          globalSettingManager.set("agreedToPrivacyPolicy", value);
                        });
                      }, value: this.agreedToPrivacyPolicy),
                      leading: RichText(
                          text: TextSpan(style: Theme.of(context).textTheme.bodyText2, children: <TextSpan>[
                            TextSpan(text: 'I have read and understand the '),
                            TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: Theme.of(context).accentColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (context) => termsAndConditionsPage()));
                                  })
                          ]))),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: !(this.allowRegistration)
                        ? null
                        : SignInButtonBuilder(
                            text: 'Register',
                            icon: Icons.person_add,
                            backgroundColor: Theme.of(context).buttonColor,
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                _register();
                              }
                            },
                          ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(_success == null
                        ? ''
                        : (_success
                            ? 'Successfully registered ' + _userEmail
                            : 'Registration failed')),
                  )
                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code for registration.
  void _register() async {
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;
    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });
    } else {
      _success = false;
    }
  }
}
