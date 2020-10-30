import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:core' as prefix0;
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pantryfox/model/user.dart';
import 'package:path_provider/path_provider.dart';

bool rememberMe = true; // Default value
const int TWO_BILLION = 2000000000;

/// See unit test persistence_helper_test.dart
class PersistenceHelper {
  static const String stateFileName = "/appstateNew.json";
  static const String upcFileName = "/upcStorage.json";
  static const String userFileName = "/rememberMe.txt"; //Needs '/'
  static const String emailString = "email";
  static const String passwordString = "password";

  Future<Map<String, dynamic>> loadMap(String fileName) async {
    Map<String, dynamic> data;
    String dataDir = await _getDirectory();
    File file = new File(dataDir + fileName);
    if (file.existsSync()) {
      String json = file.readAsStringSync();
      JsonDecoder decoder = new JsonDecoder();
      data = await decoder.convert(json);
    }
    return data;
  }

  // Dynamics?
  Future storeMap(Map<String, dynamic> data, String fileName) async {
    String dataDir = await _getDirectory();
    File file = new File(dataDir + fileName);

    JsonEncoder encoder = new JsonEncoder();
    String json = encoder.convert(data);
    file.writeAsStringSync(json);
  }

//  Future addMap(Map<String, dynamic> data, String fileName) async {
//    String dataDir = await _getDirectory();
//    File file = new File(dataDir + fileName);
//
//    JsonEncoder encoder = new JsonEncoder();
//    String json = encoder.convert(data);
//    file.writeAsStringSync(json);
//  }

  //(Could add these to a new class).
  // Return user with decrypted, plaintext password.
  Future<PantryUser> loadUser() async {
    PantryUser user = new PantryUser();

    Map<String, dynamic> dataMap = await loadMap(userFileName);
    if (dataMap == null) {
      printWarning("Failed to load user. See persistence_helper.dart");
      return null;
    }
    if (dataMap[emailString] == null) {
      user.email = '';
      user.password = '';
      return user;
    } else {
      user.email = dataMap[emailString];

      try {
        Encrypted encrypted = Encrypted.fromBase16(dataMap[passwordString]);
        String decrypted = await decrypt(encrypted);
        user.password = decrypted;
      } catch (e) {
        //unable to decrypt (wrong key or forged data)
        print('Unable to decrypt. Error: ' + e.toString());
      }

      return user;
    }
  }

  //Store user and encrypt password.
  Future<void> storeUser(String email, String pass) async {
    Encrypted encrypted;

    //Check that password is not empty.
    if (pass.length > 1) {
      encrypted = await encrypt(pass);
    }
    if (encrypted == null) print('ENCRYPTION ERROR!');

    Map<String, String> data = {emailString: email, passwordString: encrypted.base16};
    storeMap(data, userFileName);
  }

  //Return AES decryption.
  Future<String> decrypt(Encrypted encrypted) async {
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  }

  //American Encryption Standard
  Future<Encrypted> encrypt(String pass) async {
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(pass, iv: iv);
    return encrypted;
  }

  Future<void> removeUser() async {
    Map<String, String> data = {emailString: '', passwordString: ''};
    storeMap(data, userFileName);
  }

  // Returns directory path.
  Future<String> _getDirectory() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    new Directory(appDocDirectory.path).create(recursive: true)
        // The created directory is returned as a Future.
        .then((Directory directory) {
      appDocDirectory = directory;
//      print('Path of New Dir: '+ directory.path);
    });

    return appDocDirectory.path;
  }
}
