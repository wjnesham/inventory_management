import 'package:device_info/device_info.dart';
import 'package:pantryfox/screens/settings/widgets/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controller/upc_database.dart';
import 'controller/upc_http_controller.dart';
import 'generated/locale_keys.g.dart';
import 'model/user.dart';
import 'package:pantryfox/services/firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class Singleton {
  static final Singleton _singleton = new Singleton._internal();

  Singleton._internal();

  static Singleton get instance => _singleton;

  static final String signedInName = "signedIn";
  static final String darkModeName = "darkMode";

  String imagePath = "assets/images";

  PantryUser _currentUser;
  PantryUser get currentUser {
    if (_currentUser != null) {
      if (_currentUser?.uid == null) {
        print("User not signed in to Firebase.");
        // Set current user id
      }
      return _currentUser;
    }
// Set current user
    _currentUser = PantryUser(
      email: prefs?.getString(PantryUser.emailName) ?? "Email",
      darknessBoolean: Singleton.instance?.prefs?.getBool(Singleton.darkModeName) ?? false,
      name: prefs?.getString(SettingsFormBloc.userName) ?? LocaleKeys.userName.tr(),
    );
    return _currentUser;
  }

  set currentUser(PantryUser value) {
    _currentUser = value;
  }

  String deviceId;

  /// Store these with user preferences ///
  SharedPreferences _prefs;

  SharedPreferences get prefs {
    return _prefs;
  }

  set prefs(value) {
    _prefs = value;
  }

  UpcSqflite _upcSqflite;

  ///_upcSqflite.init() called in Authenticate.
  ///Don't use this reference until after Authenticate loads as it does the init call
  UpcSqflite get upcSqfliteDb {
    if (_upcSqflite == null) {
      _upcSqflite = new UpcSqflite();
    }
    return _upcSqflite;
  }

  UpcHttpController upcController = new UpcHttpController();

  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  FireStoreService _databaseService;
  FireStoreService get firebaseService {
    if (_databaseService != null) {
      return _databaseService;
    }

    if (currentUser?.uid == null) {
      print("Cannot get firebase reference as user is null");
      _databaseService = null;
    } else {
      _databaseService = new FireStoreService(uid: currentUser.uid);
    }
    return _databaseService;
  }

  set fireStoreService(String uid) {
    if (currentUser?.uid == null) {
      print("Cannot set firebase reference because user id is null");
      return;
    }
    _databaseService = FireStoreService(uid: currentUser.uid);
  }
}
