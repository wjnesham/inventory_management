import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:pantryfox/route_names.dart';
import 'package:pantryfox/screens/create_user/widgets/add_user_button.dart';
import 'package:pantryfox/screens/login/widgets/login_bloc.dart';
import 'package:pantryfox/screens/login/widgets/login_form.dart';
import 'package:pantryfox/helper/userUtils.dart';

import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pantryfox/singleton.dart';

class LoginPage extends StatelessWidget {
  void dispose(LoginBloc formBloc) {
    formBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<LoginBloc>(context);

          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              appBar:
                  //'Sign in to Pantry Fox'
                  myAppBarWithShadowText(
                      title: LocaleKeys.loginTitle.tr(),
                      rightButton: kReleaseMode ? Text("") : loginDebugButton(context, formBloc)),
              bottomNavigationBar: myBottomAppBar(
                  context, addUserButton(context), helpButton(context, LocaleKeys.passwordHelp.tr())),
              body: FormBlocListener<LoginBloc, String, String>(
                onSubmitting: (context, state) {
                  LoadingDialog.show(context);
                },
                onSuccess: (context, state) {
                  LoadingDialog.hide(context);
                  dispose(formBloc);
                  Singleton.instance.prefs.setBool(Singleton.signedInName, true);
                  Navigator.pushReplacementNamed(context, PantryRoute.home);
                },
                onFailure: (context, state) {
                  LoadingDialog.hide(context);
                  Singleton.instance.prefs.setBool(Singleton.signedInName, false);

                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(state?.failureResponse ?? "Unknown failure")));
                },
                child: LoginForm(formBloc: formBloc),
              ),
            ),
          );
        },
      ),
    );
  }
}
