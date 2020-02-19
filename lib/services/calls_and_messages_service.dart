import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;

GetIt locator = GetIt.instance;

class CallsAndMessagesService {
  void call(String number) => launch("tel://$number");

  void sendSms(String number) => launch("sms:$number");

  void sendEmail(String email) => launch("mailto:$email");
}

//_make_phone_call(String number) async {
//  const String url = 'tel://'+number;
//  if (await canLaunch(url)) {
//    await launch(url);
//  } else {
//    throw 'Could not launch $url';
//  }
//}

void setupLocator() {
  locator.registerSingleton(CallsAndMessagesService());
}

launchCall(String number) async {
  // Replace 12345678 with your tel. no.

  android_intent.Intent()
    ..setAction(android_action.Action.ACTION_CALL)
    ..setData(Uri(scheme: "tel", path: number))
    ..startActivity().catchError((e) => print(e));
}