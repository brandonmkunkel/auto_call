import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'package:auto_call/ui/terms.dart';
import 'package:auto_call/services/settings_manager.dart';

import 'home.dart';

class OnboardingPage extends StatefulWidget {
  static const String routeName = "/onboarding";

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  // Custom getter for pulling from the shared preferences cache
  bool get agreedToTerms => globalSettingManager.get("agreedToTerms");

  void _onIntroEnd(context) {
    // Verify that the user has indeed agreed to the user's terms and conditions
    if (this.agreedToTerms) {
      // Log that the User has completed onboarding and accepting terms and conditions
      globalSettingManager.set("userOnboarded", true);

      // Go to the home page (replacing this page)
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
    }
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
            PageViewModel(
              title: "Accept Terms and Conditions",
              body: "Before we continue, let's take care of some paperwork",
              image: _buildSVG(context, 'onboarding2'),
              decoration: pageDecoration,
            ),
            PageViewModel(
                title: "Terms and Conditions",
                bodyWidget: Container(color: Theme.of(context).backgroundColor, child: termsAndConditions()),
                decoration: pageDecoration,
                footer: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("I AGREE TO APP THE TERMS AND CONDITIONS"),
                      Checkbox(
                          value: this.agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              // Store the agreement to the terms and conditions within the app
                              globalSettingManager.set("agreedToTerms", value);
                            });
                          })
                    ],
                  ),
                )),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: this.agreedToTerms,
          skipFlex: 0,
          nextFlex: 0,
          skip: const Text('Skip', style: TextStyle(color: Colors.white)),
          next: const Icon(Icons.arrow_forward, color: Colors.white),
          done: agreedToTerms
              ? Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))
              : Container(),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Colors.grey,
            activeColor: Colors.white,
            activeSize: Size(22.0, 10.0),
          ),
        ))));
  }
}
