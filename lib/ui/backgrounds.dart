import 'package:flutter/material.dart';

class LanternBackgroundWidget extends StatelessWidget {
  const LanternBackgroundWidget();

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(
        // Darkened image for background
        image: new AssetImage(
          "assets/images/backgrounds/lanterns.jpg",
        ),
        colorFilter:
            ColorFilter.mode(Color.fromARGB(150, 10, 10, 10), BlendMode.darken),
        fit: BoxFit.cover,
      )),
    );
  }
}

class BalloonBackgroundWidget extends StatelessWidget {
  const BalloonBackgroundWidget();

  @override
Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(
            // Darkened image for background
            image: new AssetImage(
              "assets/images/backgrounds/balloons.jpg",
            ),
            colorFilter:
            ColorFilter.mode(
                Color.fromARGB(150, 10, 10, 10), BlendMode.lighten),
            fit: BoxFit.cover,
          )),
    );
  }
}

class FlagBackgroundWidget extends StatelessWidget {
  const FlagBackgroundWidget();

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(
            // Darkened image for background
            image: new AssetImage(
              "assets/images/backgrounds/flag.jpg",
            ),
            colorFilter:
            ColorFilter.mode(Color.fromARGB(150, 10, 10, 10), BlendMode.darken),
            fit: BoxFit.cover,
          )),
    );
  }
}
