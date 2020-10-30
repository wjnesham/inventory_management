import 'package:flutter/material.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/route_names.dart';
import 'package:pantryfox/screens/homepage/widgets/signout_button.dart';
import 'package:pantryfox/screens/settings/widgets/settings_bloc.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/singleton.dart';
import 'package:easy_localization/easy_localization.dart';

Widget getDrawer(BuildContext context) {
  return new Drawer(
    child: new ListView(
      children: <Widget>[
        new UserAccountsDrawerHeader(
          accountName: getUsernameText(),
          currentAccountPicture: new GestureDetector(
            child: new CircleAvatar(
              backgroundImage:
                  new AssetImage('${Singleton.instance.imagePath}/blank-profile-picture-973460_1280.png'),
            ),
            onTap: () => print("This is your current account."),
          ),
          decoration: new BoxDecoration(
              color: myColorArray[0],
              shape: BoxShape.circle,
              image: new DecorationImage(
                  // TODO: Trim white off of image
                  image: AssetImage('${Singleton.instance.imagePath}/fox.png'),
                  fit: BoxFit.fitHeight)),
          accountEmail: getUserEmailText(),
        ),
        new ListTile(
            title: new Text(LocaleKeys.settings).tr(),
            trailing: new Icon(Icons.settings),
            onTap: () {
              debugPrint("wjndbg: Page size is " +
                  (Singleton.instance.prefs?.getString(SettingsFormBloc.pageSize) ?? "zero") +
                  " items.");
              Navigator.pushNamed(context, PantryRoute.settings);
            }),
        new Divider(),
        helpButtonListTile(context, LocaleKeys.help.tr()),
        new Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: signoutButton(context),
        ),
        new Divider(),
      ],
    ),
  );
}
