import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class PhoneManager {
  /// One touch call requires no interaction from the user to work correctly
  static Future<bool> oneTouchCall(String phoneNumber) async {
    print("one touch call start");
    bool res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    print("one touch call done with result: $res");
    return res;
  }

  /// Two touch call requires the user to complete the call
  static void twoTouchCall(String phoneNumber) async {
    FlutterPhoneState.startPhoneCall(phoneNumber);
  }

  /// Call interface which checks for oneTouch call option
  static void call(String phoneNumber, bool oneTouch) async {
    bool callState = false;

    // Call the correct calling interface
    if (oneTouch) {
      oneTouchCall(phoneNumber).then((state) => callState = state);
    } else {
      twoTouchCall(phoneNumber);
    }
  }

  Future<void> waitForCallCompletion(String phoneNumber) async {
//  Future.wait(
//      Future.value(phoneCall.done)
//  );
//  List<PhoneCallEvent> phoneEvents = _accumulate(FlutterPhoneState.phoneCallEvents);
//  List events = Map.fromEntries(phoneEvents.reversed.map((PhoneCallEvent event) {
//    return MapEntry(event.call.id, event.call);
//  })).values.where((c) => c.isComplete).toList();
//
//  print(events);

    for (final call in FlutterPhoneState.activeCalls) {}

//  FutureBuilder<PhoneCall>(
//    builder: (context, snap) {
//      if (snap.hasData && snap.data?.isComplete == true) {
//        return Text("${phoneCall.duration?.inSeconds ?? '?'}s");
//      } else {
//        return CircularProgressIndicator();
//      }
//    },
//    future: ,
//  ));
  }

  List<R> _accumulate<R>(Stream<R> input) {
    final items = <R>[];
    input.forEach((item) {
      if (item != null) items.add(item);
    });
    return items;
  }
}
