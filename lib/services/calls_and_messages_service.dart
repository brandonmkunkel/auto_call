import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

GetIt locator = GetIt.instance;

class CallsAndMessagesService {
  void call(String number) => launch("tel://$number");

  void sendSms(String number) => launch("sms:$number");

  void sendEmail(String email) => launch("mailto:$email");
}

void setupLocator() {
  locator.registerSingleton(CallsAndMessagesService());
}

void originalCall(String phoneNumber) {
  locator.call(phoneNumber);
}

void oneTouchCall(String phoneNumber) async {
  await FlutterPhoneDirectCaller.callNumber(phoneNumber);
}

void twoTouchCall(String phoneNumber) async {
  FlutterPhoneState.startPhoneCall(phoneNumber);
}


