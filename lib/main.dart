import 'package:flutter/material.dart';

// Import firebase plugins
import 'package:firebase_core/firebase_core.dart';

import 'autocall.dart';
import 'classes/settings_manager.dart';

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
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => AlertDialog(
                    title: Text("Something Went Wrong With Loading the App"),
                  ));
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
