import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pantryfox/screens/ads/widgets/banner_ad.dart';

class LoginForm extends StatelessWidget {
  final formBloc;

  LoginForm({@required this.formBloc}) : super();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(44.0),
          child: Column(
            children: <Widget>[
              TextFieldBlocBuilder(
                textFieldBloc: formBloc.emailField,
                decoration: InputDecoration(
                  labelText: LocaleKeys.email.tr(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              TextFieldBlocBuilder(
                textFieldBloc: formBloc.passwordField,
                suffixButton: SuffixButton.obscureText,
                obscureTextFalseIcon: Icon(Icons.remove_red_eye),
                obscureTextTrueIcon: Icon(Icons.visibility_off),
                decoration: InputDecoration(
                  labelText: LocaleKeys.password.tr(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
              ),
              CheckboxFieldBlocBuilder(
                booleanFieldBloc: formBloc.rememberMeField,
                body: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(LocaleKeys.rememberMe).tr(),
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // TODO: limit number of login attempts with firestore rules
                children: <Widget>[loginButton(context), forgotPasswordButton(context)],
              ),
              getBannerAd(context),
            ],
          ),
        ));
  }

  Widget loginButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 5.0, top: 20.0, bottom: 0.0),
        child: GestureDetector(
          onTap: formBloc.submit,
          child: buttonContainer(myColorArray[2], LocaleKeys.login.tr(), mediumTextSize,
              height: smallTextSize * 4),
        ),
      ),
    );
  }

  Widget forgotPasswordButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 20.0),
        child: GestureDetector(
          onTap: () {
            print('Are you sure you want to send password reset email?');
            // ignore: unnecessary_statements
            formBloc?.addErrors;
          },
          child: buttonContainer(myColorArray[2], LocaleKeys.forgotPassword.tr(), smallTextSize,
              height: smallTextSize * 4),
        ),
      ), // GestureDetector
    );
  }
}
