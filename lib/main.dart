import 'package:flutter/material.dart';

// Import firebase plugins
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/settings_manager.dart';

import 'autocall.dart';

///
/// Create instance of FireBase auth
///
// final FirebaseAuth _auth = FirebaseAuth.instance;

///
/// Main for running the app
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up the shared preferences
  await globalSettingManager.init();

  runApp(App());
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
          showDialog(context: context, barrierDismissible: true, child: AlertDialog(title: Text("Something Went Wrong With Loading the App"),));
          print("Something Went Wrong With Loading the App");
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
