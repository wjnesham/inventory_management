import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/route_names.dart';
import 'package:pantryfox/screens/settings/widgets/settings_bloc.dart';
import 'package:pantryfox/controller/upc_http_controller.dart';
import 'package:pantryfox/helper/Notifications.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/services/firebaseAuth.dart';
import 'package:pantryfox/singleton.dart';
import 'package:easy_localization/easy_localization.dart';

import 'widgets/form_button.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final UpcHttpController upcController = Singleton.instance.upcController;

  bool _signedIn = Singleton.instance.prefs.getBool(Singleton.signedInName) ?? false;
  bool _darkMode = Singleton.instance.prefs.getBool(Singleton.darkModeName) ?? false;

  @override
  Widget build(BuildContext context) {
    debugPrint('SettingsPage build called');
    return BlocProvider<SettingsFormBloc>(
      create: (context) => SettingsFormBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: _darkMode ? darkBackColor : lightBackColor,
            appBar: myAppBarWithShadowText(
              title: LocaleKeys.settings.tr(),
            ),
            body: FormBlocListener<SettingsFormBloc, String, String>(
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
              },
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                Navigator.pushReplacementNamed(context, PantryRoute.home);
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                debugPrint("failed to save preferences.");
                Notifications.showSnackBarWithError(context, state?.failureResponse ?? "Unknown Error");
              },
              child: BlocBuilder<SettingsFormBloc, FormBlocState>(
                builder: (context, state) {
                  return ListView(
                    physics: ClampingScrollPhysics(),
                    children: <Widget>[
                      TextFieldBlocBuilder(
                        suggestionsBoxDecoration: SuggestionsBoxDecoration(color: myColorArray[2]),
                        textFieldBloc: state.textFieldBlocOf(SettingsFormBloc.userName),
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.userName.tr(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      DropdownFieldBlocBuilder(
                        selectFieldBloc: state.selectFieldBlocOf(SettingsFormBloc.orderBy),
                        millisecondsForShowDropdownItemsWhenKeyboardIsOpen: 320,
                        itemBuilder: (context, value) => value,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.orderBy.tr(),
                          prefixIcon: Icon(Icons.sort),
                        ),
                      ),
                      DropdownFieldBlocBuilder(
                        selectFieldBloc: state.selectFieldBlocOf(SettingsFormBloc.pageSize),
                        millisecondsForShowDropdownItemsWhenKeyboardIsOpen: 320,
                        itemBuilder: (context, value) => value,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.pageSize.tr(),
                          prefixIcon: Icon(Icons.format_size),
                        ),
                      ),
                      formTile(
                        () => setState(() {
                          _darkMode = !_darkMode;
                          myColorArray = (_darkMode ? darkColors : lightColors);
                          Singleton.instance.prefs.setBool(Singleton.darkModeName, _darkMode);
                        }),
                        "Dark Mode",
                        Switch(
                          value: _darkMode ?? true,
                          onChanged: (value) {
                            setState(() {
                              _darkMode = value;
                              myColorArray = (_darkMode ? darkColors : lightColors);
                              Singleton.instance.prefs.setBool(Singleton.darkModeName, _darkMode);
                            });
                          },
                          activeTrackColor: Colors.green[600],
                          inactiveTrackColor: myColorArray[0],
                          inactiveThumbColor: Colors.white,
                          activeColor: Colors.black54,
                        ),
                      ),
                      FormButton(
                        text: LocaleKeys.save.tr(),
                        onPressed: () => context.bloc<SettingsFormBloc>().submit(),
                      ),

                      _settingsTextContainer(
                          _signedIn ? "Firebase" : "Sign in or create an account to backup your data", null),

                      // Set based on authenticated boolean
                      FormButton(
                        text: _signedIn ? LocaleKeys.logOut.tr() : LocaleKeys.login.tr(),
                        onPressed: () => setState(() {
                          if (_signedIn) {
                            debugPrint("Logging out...");
                            _signedIn = false;
                            final AuthService _auth = AuthService();
                            _auth.signOut();
                            Singleton.instance.prefs.setBool(Singleton.signedInName, false);
                          } else {
                            debugPrint("Loging in...");
                            Navigator.pushReplacementNamed(context, PantryRoute.login);
                          }
                        }),
                      ),

                      if (_signedIn)
                        FormButton(
                          text: LocaleKeys.syncData.tr(),
                          onPressed: () {
                            _syncData(context);
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Container _settingsTextContainer(String text, Color color) {
    if (color == null) color = myColorArray[1];
    return Container(
        alignment: Alignment.center,
        height: buttonHeight,
        decoration: new BoxDecoration(color: color),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Text(text,
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: mediumTextSize, color: smallTextColor, fontStyle: FontStyle.italic)),
        ));
  }

  Future<void> _syncData(BuildContext context) async {
    await upcController.syncData().then((_) {
      showToast(_scaffoldKey, 'Storage has been set.');
    });
    context.bloc<SettingsFormBloc>().submit();
  }

}
