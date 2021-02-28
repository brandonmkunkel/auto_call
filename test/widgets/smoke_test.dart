// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:auto_call/main.dart';
import 'package:auto_call/pages/onboarding.dart';
import 'package:auto_call/pages/home.dart';
import 'package:auto_call/pages/analytics.dart';
import 'package:auto_call/pages/contacts.dart';
import 'package:auto_call/pages/file_selector.dart';
import 'package:auto_call/pages/past_sessions.dart';
import 'package:auto_call/pages/settings.dart';

import 'package:auto_call/services/settings_manager.dart';

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(data: MediaQueryData(), child: MaterialApp(home: widget));
}

// testWidgets('App Startup smoke test', (WidgetTester tester) async {
// // Build our app and trigger a frame.
// await tester.pumpWidget(App());
//
// // Verify that our counter starts at 0.
// expect(find.text('0'), findsOneWidget);
// expect(find.text('1'), findsNothing);
//
// // Tap the '+' icon and trigger a frame.
// await tester.tap(find.byIcon(Icons.add));
// await tester.pump();
//
// // Verify that our counter has incremented.
// expect(find.text('0'), findsNothing);
// expect(find.text('1'), findsOneWidget);
// });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Page Widget smoke tests", () {
    // Initializes the SharedPreferences cache
    SharedPreferences.setMockInitialValues({});

    // Load up settings manager
    globalSettingManager.init().then((obj) {});

    testWidgets('App Startup', (WidgetTester tester) async {
      await tester.pumpWidget(App());
    });

    testWidgets('Onboarding', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(OnboardingPage()));
    });

    testWidgets('HomePage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(HomePage()));
    });

    testWidgets('AnalyticsPage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AnalyticsPage()));
    });

    testWidgets('ContactsPage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ContactsPage()));
    });

    testWidgets('FileSelectorPage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(FileSelectorPage()));
    });

    testWidgets('LegalPage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PastSessionsPage()));
    });

    testWidgets('PastSessionsPage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PastSessionsPage()));
    });

    testWidgets('SettingsPage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(SettingsPage()));
    });
  });
}
