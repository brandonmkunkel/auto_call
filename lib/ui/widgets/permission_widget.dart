import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

///
/// The [PermissionsWidget] Widget is used to interact with the user's local contacts
///
class PermissionsWidget extends StatefulWidget {
  final Permission requestedPermission;
  final Widget child;
  PermissionsWidget({Key key, @required this.requestedPermission, @required this.child}) : super(key: key);

  @override
  PermissionsState createState() => new PermissionsState();
}

class PermissionsState extends State<PermissionsWidget> {
  PermissionStatus permissionStatus;

  @override
  void initState() {
    super.initState();

    _askPermissions();
  }

  void _askPermissions() {
    widget.requestedPermission.request().then((PermissionStatus perm) {
      permissionStatus = perm;
    });

    // if (permissionStatus != PermissionStatus.granted) {
    //   _handleInvalidPermissions(permissionStatus);
    // }
  }

  // void _handleInvalidPermissions(PermissionStatus permissionStatus) {
  //   if (permissionStatus == PermissionStatus.denied) {
  //     throw PlatformException(code: "PERMISSION_DENIED", message: "Access to user contacts denied", details: null);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.requestedPermission.request(),
      builder: (BuildContext context, AsyncSnapshot<PermissionStatus> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data.isGranted
              ? widget.child
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: Text("The app does not have access to your ${widget.requestedPermission.toString()}"))),
                  RaisedButton(
                    child: Text("Change App Permissions"),
                    onPressed: () async {
                      // The user has not accept the permission request for this
                      // app. The only way to change the permission's status now is to let the
                      // user manually enable it in the system settings.
                      await openAppSettings();
                    },
                  )
                ]);
        }

        if (snapshot.hasError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("An error occurred while requesting ${widget.requestedPermission.toString()}"),
              Text("${snapshot.error}")
            ],);
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
