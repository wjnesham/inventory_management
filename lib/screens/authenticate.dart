import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pantryfox/controller/upc_database.dart';
import 'package:pantryfox/helper/components.dart';
import 'package:pantryfox/helper/persistence_helper.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/model/user.dart';
import 'package:pantryfox/screens/homepage/homePage.dart';
import 'package:pantryfox/services/firebaseAuth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../singleton.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool loadingThings = true;

  @override
  initState() {
    _getThingsOnStartup().then((val) {
      print("_getThingsOnStartup completed");
    });
    super.initState();
  }

  Future<void> _getThingsOnStartup() async {
    if (Singleton.instance.prefs == null) {
      Singleton.instance.prefs = await SharedPreferences.getInstance();
    }
    bool _darkMode = Singleton.instance.prefs.getBool(Singleton.darkModeName) ?? false;

    FirebaseApp fireApp = await Firebase.initializeApp();

    UpcSqflite upcSqflite = Singleton.instance.upcSqfliteDb;
    if (Singleton.instance.prefs == null) {
      SharedPreferences.getInstance().then((value) => {Singleton.instance.prefs = value});
    }
    await Singleton.instance.upcSqfliteDb.init(null).then((val) {
      if (upcSqflite.upcBean != null) {
        print("upcSqfliteDb.init completed");
      } else {
        print("upcSqflite bean is null");
      }
    });

    if (Singleton.instance?.currentUser?.uid == null) {
      final PersistenceHelper _userHelper = new PersistenceHelper();
      PantryUser tempUser = await _userHelper.loadUser();
      if (tempUser?.uid != null) {
        Singleton.instance.currentUser.uid = tempUser.uid;
      } else if (Singleton.instance?.currentUser?.uid == null) {
        //Sign in
        final AuthService _auth = AuthService();
        String userEmail = tempUser?.email ?? "";
        String userPass = tempUser?.password ?? "";
        PantryUser user;
        if (userEmail.isEmpty || userPass.isEmpty) {
          user = null;
        } else {
          user = await _auth.signInWithEmailAndPassword(userEmail, userPass);
        }

        if (user == null) {
          debugPrint("User is not signed in.");
          Singleton.instance?.prefs?.setBool(Singleton.signedInName, false);
        } else {
          Singleton.instance?.currentUser?.uid = user.uid;
          Singleton.instance?.prefs?.setBool(Singleton.signedInName, true);
        }
      }
      debugPrint("Current user UID = " + Singleton.instance?.currentUser?.uid ?? "AUTH ERROR");
    }

    setState(() {
      debugPrint(Singleton.instance?.prefs?.getString(PantryUser.emailName) ?? "Email is null on startup");
      myColorArray = _darkMode ? darkColors : lightColors;
      loadingThings = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingThings) {
      return Loading();
    }
    if (Singleton?.instance?.prefs?.getBool(Singleton.signedInName) == true) {
      debugPrint("authenticated user");
    }
    return ScanHomePage();
  }
}
