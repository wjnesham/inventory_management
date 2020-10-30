import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/helper/persistence_helper.dart';
import 'package:pantryfox/model/user.dart';
import 'package:pantryfox/services/firebaseAuth.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../singleton.dart';

class LoginBloc extends FormBloc<String, String> {
  final AuthService _auth = AuthService();
  final PersistenceHelper _userHelper = new PersistenceHelper();

  static final String emailName = 'email';
  static final String passwordName = 'password';
  static final String rememberMeName = 'rememberMe';

  final emailField =
      TextFieldBloc(name: emailName, validators: [FieldBlocValidators.required, FieldBlocValidators.email]);

  final passwordField = TextFieldBloc(
      name: passwordName, validators: [FieldBlocValidators.required, FieldBlocValidators.passwordMin6Chars]);

  final rememberMeField = BooleanFieldBloc(initialValue: true, name: rememberMeName);

  void addErrors() {
    emailField.addFieldError('Email is required');
    passwordField.addFieldError('Password is required');
  }

  void dispose() {
    emailField.drain();
    passwordField.drain();
    rememberMeField.drain();
  }

  LoginBloc() {
    _userHelper.loadUser().then((val) {
      emailField.updateInitialValue(val?.email ?? "");
      passwordField.updateInitialValue(val?.password ?? "");
      addFieldBlocs(fieldBlocs: [emailField, passwordField, rememberMeField]);
    });
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    addErrors();
    super.onError(error, stackTrace);
  }

  @override
  void onSubmitting() async {
    try {
      /// Check email and password.
      String userEmail = emailField.value;
      String userPass = passwordField.value;
      if (userEmail.length > 1 && userPass.length > 5) {
        /// Find user. Then...
        PantryUser user = await _auth.signInWithEmailAndPassword(userEmail, userPass);

        if (user == null) {
          emitFailure(failureResponse: LocaleKeys.passwordHelp.tr());
          throw FirebaseAuthException(message: LocaleKeys.passwordHelp.tr(), code: "404");
        }
        if (user?.uid == null) {
          emitFailure(failureResponse: LocaleKeys.passwordHelp.tr());
          throw FirebaseAuthException(message: LocaleKeys.passwordHelp.tr(), code: "500");
        }

        _checkShouldRememberUser(userEmail, userPass);

        Singleton.instance.currentUser = user;

        emitSuccess();
      } else {
        emitFailure(failureResponse: "Email and Password are required to login with Firebase");
        print("No user found when mapping login to state");
      }
    } catch (e) {
      debugPrint("ERROR: " + e + ". On line 89 login_bloc.dart");
      emitFailure();
    }
  }

  void _checkShouldRememberUser(String userEmail, String userPass) async {
    if (rememberMeField.value == true) {
      await _userHelper.storeUser(userEmail, userPass);
      Singleton.instance?.prefs?.setString(emailName, userEmail);
    } else {
      // Forget user.
      await _userHelper.removeUser(); // Clears user fields
      Singleton.instance?.prefs?.setString(emailName, null);
    }
  }
}
