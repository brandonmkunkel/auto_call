import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'package:auto_call/services/settings_manager.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class OnboardingPage extends StatefulWidget {
  static const String routeName = "/onboarding";

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    // Go to the home page (replacing this page)
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => _auth.currentUser != null ? HomePage() : LoginPage()
    ));
  }

  Widget _buildImage(BuildContext context, String assetName) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Image.asset('assets/images/$assetName.png', height: MediaQuery.of(context).size.height * 0.4),
    );
  }

  Widget _buildSVG(BuildContext context, String assetName, {String semanticsLabel}) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: SvgPicture.asset('assets/svg/$assetName.svg', color: Colors.white, semanticsLabel: semanticsLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.white),
      bodyTextStyle: TextStyle(fontSize: 18.0, color: Colors.white),
      pageColor: Theme.of(context).primaryColor,
    );

    return Scaffold(
        primary: true,
        body: Container(
        color: Theme.of(context).primaryColor,
        child: SafeArea(
            child: IntroductionScreen(
          key: introKey,
          pages: [
            PageViewModel(
              title: "Call more clients faster",
              body: "We know how tiring it can be to make a bunch of calls. Let us help you with that!",
              image: _buildSVG(context, 'onboarding1'),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Upload an Excel file or simple text File",
              body: "Make sure this file has at least two columns, 'Name' and 'Number'",
              image: _buildSVG(context, 'onboarding2'),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Let the magic happen!",
              body: "We take care of typing their numbers and dialing them, so you can focus and take notes!",
              image: _buildSVG(context, 'onboarding3'),
              decoration: pageDecoration,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: true,
          skipFlex: 0,
          nextFlex: 0,
          skip: const Text('Skip', style: TextStyle(color: Colors.white)),
          next: const Icon(Icons.arrow_forward, color: Colors.white),
          done: Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Colors.grey,
            activeColor: Colors.white,
            activeSize: Size(22.0, 10.0),
          ),
        ))));
  }
}
