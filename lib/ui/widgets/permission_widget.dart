import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:auto_call/ui/prompts/errors.dart';

///
/// The [PermissionsWidget] Widget is used to interact with the user's local contacts
///
class PermissionsWidget extends StatefulWidget {
  final Permission requestedPermission;
  final Widget child;
  PermissionsWidget({Key? key, required this.child, required this.requestedPermission}) : super(key: key);

  @override
  PermissionsState createState() => new PermissionsState();
}

class PermissionsState extends State<PermissionsWidget> {
  late PermissionStatus permissionStatus;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.requestedPermission.request(),
      builder: (BuildContext context, AsyncSnapshot<PermissionStatus> snapshot) {
        if (snapshot.hasError) {
          return GeneralErrorWidget(
              errorText: "Error loading ${widget.requestedPermission.toString().split(".")[1]} permission:",
              error: snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data!.isGranted
              ? widget.child
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                          child: Text(
                        "The app does not have access to your ${widget.requestedPermission.toString().split(".")[1]}",
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ))),
                  ElevatedButton(
                    child: Text("Change App Permissions"),
                    onPressed: () async {
                      // The user has not accepted the permission request for this
                      // app. The only way to change the permission's status now is to let the
                      // user manually enable it in the system settings.
                      await openAppSettings();
                      setState(() {});
                    },
                  )
                ]);
        }

        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
          Container(
            padding: EdgeInsets.all(40.0),
            child: Text(
              "Requesting App Permissions",
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            ),
          )
        ]);
      },
    );
  }
}
