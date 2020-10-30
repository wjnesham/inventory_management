import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/model/user.dart';
import 'package:pantryfox/screens/settings/widgets/settings_bloc.dart';
import 'package:pantryfox/services/firestore.dart';
import 'package:pantryfox/singleton.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth?.instance;

  // create user obj based on firebase user
  PantryUser _userFromFirebaseUser(User user) {
    print("enter _userFromFirebaseUser ${user?.uid ?? "firebase user is null"}");
    return user != null
        ? PantryUser(
            email: user.email,
            darknessBoolean: Singleton.instance?.prefs?.getBool(Singleton.darkModeName) ?? false,
            name: user.displayName ??
                Singleton.instance?.prefs?.getString(SettingsFormBloc.userName) ??
                "Go to settings to set your name",
            uid: user.uid)
        : null;
  }

  // auth change user stream
  Stream<PantryUser> get user {
    print("enter get user");
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future signInAnon() async {
    print("enter signInAnon");
    try {
      UserCredential authResult = await _auth.signInAnonymously();
      User user = authResult.user;
      Singleton.instance.currentUser = _userFromFirebaseUser(user);
      return Singleton.instance.currentUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// sign in with email and password
  Future<PantryUser> signInWithEmailAndPassword(String email, String password) async {
    print("enter signInWithEmailAndPassword");
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);

      User user = result.user;
      Singleton.instance.currentUser = _userFromFirebaseUser(user);

      await updateUserWithPantryProfile();

      return Singleton.instance.currentUser;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future updateUserWithPantryProfile() async {
    debugPrint("enter updateUserWithPantryProfile");
    if (Singleton?.instance?.currentUser == null) {
      print("currentUser is null Login - did login fail??");
      return;
    }
    Singleton.instance.deviceId = await getDeviceId();
    LinkedHashMap pantryProfile;
    pantryProfile = await Singleton.instance.firebaseService.getUserProfile(Singleton.instance.deviceId);

    String name = Singleton.instance.currentUser?.name;
    String pageSize = Singleton.instance.currentUser?.itemPageSize?.toString();
    String email = Singleton.instance.currentUser?.email ?? "unknown email";
    if (pantryProfile == null) {
      //no pantry profile, add one
      await Singleton.instance.firebaseService.updateUserData(name ?? "Your Name Here", email,
          Singleton.instance.deviceId, pageSize ?? SettingsFormBloc.defaultPageSize);
      //get profile just added
      pantryProfile = await Singleton.instance.firebaseService.getUserProfile(Singleton.instance.deviceId);
    }

    if (pantryProfile == null) {
      print("Error! pantryProfile is null");
      return;
    }

    //update currentUser with pantryProfile to make sure they're in sync
    name = pantryProfile['name'];
    Singleton.instance.currentUser.name = name ?? "Your Name Here";

    pageSize = pantryProfile['itemPageSize'];
    Singleton.instance.currentUser.itemPageSize =
        (pageSize == null ? int.parse(SettingsFormBloc.defaultPageSize) : int.parse(pageSize));
  }

// register with email and password
  Future<PantryUser> registerWithEmailAndPassword(
      String email, String password, GlobalKey<ScaffoldState> scaffoldKey) async {
    print("enter registerWithEmailAndPassword");
    PantryUser upcUser;
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      upcUser = _userFromFirebaseUser(user);
      Singleton.instance.currentUser = upcUser;
      await updateUserWithPantryProfile();

      ///TODO: test only
      //await createTestUpcData(upcUser);
    } catch (error) {
      debugPrint(error.toString());
      showToast(scaffoldKey, error.toString());
    }
    return upcUser;
  }

// sign out
  Future signOut() async {
    print("enter signOut");
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  /// Just for testing
  createTestUpcData(User user) {
    print("Inserting test UpcDb ********** ");
    FireStoreService service = new FireStoreService(uid: user.uid);
    service.createTestUpcDbItem();
  }
}
