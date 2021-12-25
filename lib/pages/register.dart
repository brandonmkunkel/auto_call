import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_builder.dart';

import 'package:auto_call/classes/settings_manager.dart';
import 'package:auto_call/ui/terms.dart';
import 'package:auto_call/classes/regex.dart';
import 'package:auto_call/pages/home.dart';

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

  late FirebaseAuthException exception;

  String _failureString = "";
  String _userEmail = '';

  bool get agreedToTerms => globalSettingManager.get("agreedToTerms");
  bool get agreedToPrivacyPolicy => globalSettingManager.get("agreedToPrivacyPolicy");

  bool get allowRegistration => this.agreedToTerms && this.agreedToPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Card(
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              controller: _emailController,
                              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))],
                              decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                              validator: (String? value) {
                                if ((value as String).isEmpty) {
                                  return 'Please enter a valid email address';
                                } else if (!MagicRegex.isEmail(value)) {
                                  return 'Invalid email format';
                                }
                                return null;
                              },
                            )),
                        Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                              validator: (String? value) {
                                if ((value as String).isEmpty) {
                                  return 'Please enter a valid password';
                                }
                                return null;
                              },
                              obscureText: true,
                            )),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: _failureString.isEmpty
                                ? null
                                : Text("$_failureString", style: TextStyle(color: Colors.red))),
                        Divider(),
                        ListTile(
                            trailing: Checkbox(
                              onChanged: (value) {
                                setState(() {
                                  globalSettingManager.set("agreedToTerms", value);
                                });
                              },
                              value: this.agreedToTerms,
                              activeColor: Theme.of(context).buttonTheme.colorScheme?.primary,
                            ),
                            title: RichText(
                                text: TextSpan(style: Theme.of(context).textTheme.bodyText2, children: <TextSpan>[
                              TextSpan(text: 'I agree to the '),
                              TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (context) => termsAndConditionsPage()));
                                    })
                            ]))),
                        ListTile(
                            trailing: Checkbox(
                              onChanged: (value) {
                                setState(() {
                                  globalSettingManager.set("agreedToPrivacyPolicy", value);
                                });
                              },
                              value: this.agreedToPrivacyPolicy,
                              activeColor: Theme.of(context).buttonTheme.colorScheme?.primary,
                            ),
                            title: RichText(
                                text: TextSpan(style: Theme.of(context).textTheme.bodyText2, children: <TextSpan>[
                              TextSpan(text: 'I have read and understand the '),
                              TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                                  backgroundColor: Colors.indigo,
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      _register(context);
                                    } else {
                                      setState(() {
                                        _failureString = "";
                                      });
                                    }
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ))),
      ),
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
  void _register(BuildContext context) async {
    try {
      final User? user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;

      setState(() {
        _userEmail = user?.email as String;

        // Go to the home page on successful log-in
        Navigator.of(context).pushNamedAndRemoveUntil(HomePage.routeName, (route) => false);
      });
    } on Exception catch (e) {
      setState(() {
        _failureString = e.toString();
      });

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Failure: ${e.code}")));
    }
  }
}
