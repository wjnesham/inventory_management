import 'package:flutter/material.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/route_names.dart';

import 'package:easy_localization/easy_localization.dart';

Widget addUserButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      // Prompt user to make purchase
      Navigator.pushNamed(context, PantryRoute.createUser);
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: new BoxDecoration(color: myColorArray[2], borderRadius: new BorderRadius.circular(18.0)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.person_add, color: iconColor),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                LocaleKeys.createAccount.tr(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
