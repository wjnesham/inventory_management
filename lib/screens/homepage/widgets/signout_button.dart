import 'package:flutter/material.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/route_names.dart';
import 'package:pantryfox/services/firebaseAuth.dart';
import 'package:pantryfox/singleton.dart';

Widget signoutButton(BuildContext context) {
  final AuthService _auth = AuthService();
  bool _signedIn = Singleton?.instance?.prefs?.getBool(Singleton.signedInName) ?? false;

  return GestureDetector(
    onTap: () async {
      if (_signedIn) {
        await _auth.signOut();
        debugPrint("Signing out - pushing to AuthWrapper");
      }
      Navigator.pushReplacementNamed(context, PantryRoute.login);
    },
    child: logUserTile(context, signedIn: _signedIn),
  );
}
