import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

import 'services/settings_manager.dart';

import 'app.dart';

///
/// Main for running the app
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up the shared preferences
  SharedPreferences.getInstance().then((SharedPreferences prefs) {
    globalSettingManager.fromPrefs(prefs);

    runApp(App());
  });
}

///
/// App Stateful Widget
///
class App extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print("Something wrong");
          // return Pop
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return AutoCall();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
}
