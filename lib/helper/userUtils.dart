import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/model/user.dart';
import 'package:pantryfox/screens/login/widgets/login_bloc.dart';
import 'package:pantryfox/screens/settings/widgets/settings_bloc.dart';
import 'package:pantryfox/bloc/upc_event.dart';
import 'package:pantryfox/bloc/upc_event_state_bloc.dart';
import 'package:pantryfox/screens/help/help_screen.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

import '../singleton.dart';

const double smallerTextSize = 12.0;
const double smallTextSize = 16.0;
const double mediumTextSize = 20.0;
const double buttonSize = 48.0;
const double largeButtonSize = 60.0;
final smallTextColor = Colors.white;
const int BIGNUM = 2147000000;
const Color lightBackColor = Colors.white;
Color darkBackColor = Colors.black54;

IconData darknessIcon = Icons.brightness_3;
double iconSize = 30.0;
double buttonHeight = 60.0;
Color iconColor = Colors.white;

List<Color> lightColors = [
  Colors.yellow[200],
  Colors.blueAccent[100],
  Colors.indigo[300],
];
List<Color> darkColors = [
  Colors.white60,
  Colors.indigo,
  Colors.black,
];

List<Color> myColorArray = lightColors;

Widget multiLineTextField(String label, TextEditingController control, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
    child: Container(
      decoration: new BoxDecoration(color: Colors.black38, borderRadius: new BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: new TextField(
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          style: new TextStyle(
            color: Colors.white,
          ),
          cursorColor: Colors.white,
          controller: control,
          decoration: new InputDecoration(
            labelStyle: new TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
            labelText: label,
          ),
        ),
      ),
    ),
  );
}

Widget addAppLogo() {
  return AnimatedContainer(
    alignment: Alignment.center,
    width: 250.0,
    height: 250.0,
    decoration: BoxDecoration(
      color: lightBackColor,
      borderRadius: BorderRadius.circular(125.0),
    ),
    duration: Duration(seconds: 1),
    child: ClipRRect(
        borderRadius: new BorderRadius.circular(100.0),
        child: Image.asset(
          '${Singleton.instance.imagePath}/fox.png',
          height: 200.0,
          width: 200.0,
        )),
    curve: Curves.fastOutSlowIn,
//          child: Image.asset('images/bag_o_stuff_icon.png'),
  );
}

Widget loadingWheel(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(100.0),
    child: SpinKitCircle(
      color: myColorArray[0],
      size: MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
          ? MediaQuery.of(context).size.width * 0.25
          : MediaQuery.of(context).size.height * 0.25 ?? 150.0,
      duration: Duration(milliseconds: 1000),
    ),
  );
}

Widget myCustomAlert(BuildContext context, String title, String message) {
  return AlertDialog(
    backgroundColor: myColorArray[1],
    contentTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    title: shadowText(title, 18.0),
    content: new Text(message),
    actions: <Widget>[
      CloseButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

AlertDialog _sortAlert(BuildContext context, String title, String message) {
  return AlertDialog(
    backgroundColor: myColorArray[1],
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    title: shadowText(title, mediumTextSize),
    content: new Text(message),
    actions: <Widget>[
      // usually buttons at the bottom of the dialog
      Column(
        children: <Widget>[
          _sortItemsButton(context, LocaleKeys.title.tr()),
          _sortItemsButton(context, LocaleKeys.description.tr()),
        ],
      ),
      Column(
        children: <Widget>[
          _sortItemsButton(context, LocaleKeys.upc.tr()),
          _sortItemsButton(context, LocaleKeys.count.tr()),
        ],
      ),
      cancelButton(context),
    ],
  );
}

// Todo: Make this less messy...
Widget _sortItemsButton(BuildContext context, String sortBy) {
  return FlatButton(
      child: new Text(
        sortBy,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        debugPrint("Sorting by " + sortBy);
        Singleton.instance.prefs
            ?.setString(SettingsFormBloc?.userName ?? LocaleKeys.title.tr(), sortBy.toLowerCase());

        Navigator.of(context).pop();
      });
}

Widget myBottomAppBar(BuildContext context, Widget leftButton, Widget rightButton) {
  return BottomAppBar(
    color: myColorArray[1],
    child: new Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[leftButton, rightButton],
    ),
  );
}

/// Returns text with a shadow.
Widget shadowText(String text, double fontSize) {
  return Text(
    text,
    style: new TextStyle(
      fontSize: fontSize,
      color: myColorArray[0],
      shadows: <Shadow>[
        Shadow(
          blurRadius: 2.0,
          color: Colors.black87,
        ),
      ],
    ),
  );
}

Widget darkText(String text, double fontSize) {
  return Text(
    text,
    style: new TextStyle(fontSize: fontSize, color: Colors.black, fontWeight: FontWeight.bold),
  );
}

Widget myAppBar(String title) {
  return AppBar(
    title: Text(title),
    iconTheme: new IconThemeData(color: myColorArray[1]),
  );
}

Widget myAppBarWithShadowText({String title = "Title", Widget rightButton: const Text('')}) {
  return AppBar(
    backgroundColor: myColorArray[1],
    title: shadowText(title, 28.0),
    elevation: 8.0,
    iconTheme: new IconThemeData(color: myColorArray[0]),
    actions: <Widget>[rightButton],
  );
}

/// Add background color
Widget standardContainer(Widget contents) {
  return Container(
    decoration: BoxDecoration(
      // Box decoration takes a gradient
      gradient: LinearGradient(
        // Where the linear gradient begins and ends
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        // Add one stop for each color. Stops should increase from 0 to 1
        stops: [0.1, 0.5, 0.9],
        colors: myColorArray,
      ),
    ),
    child: contents,
  );
}

Future<void> showToast(GlobalKey<ScaffoldState> scaffoldKey, String msg) async {
  if (scaffoldKey.currentState == null) {
    debugPrint('wjndbg: Current state is null in showToast');
    return;
  }
  scaffoldKey.currentState.showSnackBar(SnackBar(
    content: shadowText(msg, smallTextSize),
    backgroundColor: myColorArray[1],
    duration: Duration(seconds: 3),
  ));
}

Widget getTextField(
    String label, TextEditingController control, bool hidden, TextInputType type, BuildContext context) {
  TextField field = TextField(
    textInputAction: TextInputAction.done,
  );
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
    child: Container(
      decoration: new BoxDecoration(color: Colors.black38, borderRadius: new BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: new TextField(
          textInputAction: field.textInputAction,
          keyboardType: type,
          style: new TextStyle(
            color: Colors.white,
          ),
          cursorColor: Colors.white,
          controller: control,
          obscureText: hidden,
          // Obscure if true.
          decoration: new InputDecoration(
            labelStyle: new TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
            labelText: label,
          ),
        ),
      ),
    ),
  );
}

Widget helpTextContainer(String helpText, String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
    child: Container(
      decoration: new BoxDecoration(color: myColorArray[2], borderRadius: new BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: new Text(
          title + ":\n\n" + helpText,
          style: TextStyle(fontSize: mediumTextSize, color: Colors.white),
        ),
      ),
    ),
  );
}

Widget helpButton(BuildContext context, String helpMessage) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return myCustomAlert(context, LocaleKeys.help.tr(), helpMessage);
        },
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: new BoxDecoration(color: myColorArray[2], borderRadius: new BorderRadius.circular(18.0)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.help, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                LocaleKeys.help.tr(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget helpButtonListTile(BuildContext context, String helpMessage) {
  return new ListTile(
      title: new Text(helpMessage),
      trailing: new Icon(Icons.help),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (BuildContext context) => new HelpScreenPage()));
      });
}

ListTile logUserTile(BuildContext context, {bool signedIn = false}) {
  return ListTile(
    title: new Text(
      signedIn ? LocaleKeys.logOut.tr() : "Sign In",
      style: TextStyle(
        color: signedIn ? Colors.red : Colors.green,
      ),
    ),
  );
}

Widget getUsernameText() {
  String name = Singleton.instance.prefs?.getString(SettingsFormBloc.userName) ?? LocaleKeys.userName.tr();
  return new Text(
    name,
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  );
}

Widget getUserEmailText() {
  if (Singleton.instance.prefs?.getBool(Singleton.signedInName) != true) {
    debugPrint("Not Signed-In!");
    return Text("");
  }
  String email = Singleton.instance?.prefs?.getString(PantryUser.emailName) ?? LocaleKeys.email.tr();
  return new Text(
    email,
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  );
}

Widget dbPageNextButton(BuildContext context, UpcEventStateBloc upcBloc) {
  return IconButton(
    icon: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(Icons.keyboard_arrow_right, color: Colors.white),
    ),
    onPressed: () async {
      debugPrint("wjndbg: dbPageNextButton tapped");
      upcBloc.add(NextPageEvent(offSet: 0, fetchQty: 7));
    },
  );
}

/// move to last
Widget dbLastPageButton(BuildContext context, UpcEventStateBloc upcBloc) {
//  final AuthService _auth = AuthService();
  return IconButton(
    icon: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(Icons.fast_forward, color: Colors.white),
    ),
    onPressed: () async {
      debugPrint("wjndbg: dbLastPageButton tapped");
      upcBloc.add(LastPageEvent(offSet: 0, fetchQty: 7));
    },
  );
}

/// move to first
Widget dbFirstPageButton(BuildContext context, UpcEventStateBloc upcBloc) {
//  final AuthService _auth = AuthService();
  return IconButton(
    icon: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(Icons.fast_rewind, color: Colors.white),
    ),
    onPressed: () async {
      debugPrint("wjndbg: dbFirstPageButton tapped");
      upcBloc.add(FirstPageEvent(offSet: 0, fetchQty: 7));
    },
  );
}

Widget dbPagePrevButton(BuildContext context, UpcEventStateBloc upcBloc) {
//  final AuthService _auth = AuthService();
  return IconButton(
    icon: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(Icons.keyboard_arrow_left, color: Colors.white),
    ),
    onPressed: () async {
      debugPrint("wjndbg: Prev Button tapped");
      upcBloc.add(PrevPageEvent(offSet: 0, fetchQty: 7));
    },
  );
}

/// Dialog should contain context, title, and message
Widget _alertMenuButton(BuildContext context, AlertDialog dialog, IconData iconData, String iconText) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        },
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: new BoxDecoration(color: myColorArray[2], borderRadius: new BorderRadius.circular(18.0)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                iconData,
                color: iconColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                iconText,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

GestureDetector cancelButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).pop();
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        LocaleKeys.cancel.tr(),
        style: TextStyle(color: Colors.red),
      ),
    ),
  );
}

Widget proceedWithoutFirebaseButton(BuildContext context, LoginBloc formBloc) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 5.0, top: 20.0, bottom: 0.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/scanHomePage');
          Singleton.instance.prefs.setBool(Singleton.signedInName, false);
          return formBloc.close;
        },
        child: buttonContainer(myColorArray[2], "Start Without DB", smallTextSize, height: smallTextSize * 3),
      ),
    ),
  );
}

Widget loginDebugButton(BuildContext context, LoginBloc formBloc) {
  String title = "Debug";
  AlertDialog debugDialog = AlertDialog(
    backgroundColor: myColorArray[1],
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    title: shadowText(title, mediumTextSize),
    content: new Text("Debug Options"),
    actions: <Widget>[
      proceedWithoutFirebaseButton(context, formBloc),
      cancelButton(context),
    ],
  );
  return _alertMenuButton(context, debugDialog, Icons.bug_report, title);
}

Widget sortButton(BuildContext context, String sortMessage) {
  String alertTitle = LocaleKeys.sort.tr() + LocaleKeys.help.tr();
  AlertDialog sortAlert = _sortAlert(context, alertTitle, sortMessage);
  return _alertMenuButton(context, sortAlert, Icons.sort, LocaleKeys.sort.tr());
}

Widget buttonContainer(Color buttonColor, String buttonText, double buttonFontSize,
    {double height = buttonSize}) {
  return Container(
      alignment: Alignment.center,
      height: height,
      decoration: new BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: myColorArray[2],
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Text(buttonText,
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: buttonFontSize, color: myColorArray[2])),
      ));
}

Widget darknessIconButtonContainer(Color buttonColor, String buttonText, double buttonFontSize) {
  return Container(
    alignment: Alignment.center,
    height: buttonHeight,
    decoration: new BoxDecoration(color: buttonColor, borderRadius: new BorderRadius.circular(18.0)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Icon(
          darknessIcon,
          color: iconColor,
          size: iconSize,
        ),
        new Text(buttonText,
            textAlign: TextAlign.center, style: new TextStyle(fontSize: buttonFontSize, color: Colors.white))
      ],
    ),
  );
}

bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return num.tryParse(str) != null;
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key key}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(key: key),
    );
  }

  static void hide(BuildContext context) {
    Navigator.pop(context);
  }

  LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(child: loadingWheel(context)),
    );
  }
}

Future<String> getDeviceId() async {
  try {
    if (Platform.isAndroid) {
      var info = await Singleton.instance.deviceInfoPlugin.androidInfo;
      debugPrint("deviceInfoPlugin.android id: ${info?.androidId}");
      return info.androidId;
    } else if (Platform.isIOS) {
      var info = await Singleton.instance.deviceInfoPlugin.iosInfo;
      return info.identifierForVendor;
    } else {
      throw new PlatformException(code: "Platform did not determine the device correctly");
    }
  } on PlatformException {
    print('WARNING: Failed to get platform version.');
    throw new PlatformException(code: "Failed to get platform version.");
  }
}

String getFormattedDateByMilliseconds(int dateTimeMilliseconds, BuildContext context) {
  DateTime aDate = DateTime.fromMillisecondsSinceEpoch(dateTimeMilliseconds);
  String locale = Intl.defaultLocale;
  var dateFormat = new DateFormat.yMMMMd(locale);
  // String languageCode = Localizations.localeOf(context).languageCode;
  var dateStr = dateFormat.format(aDate);
  return dateStr;
}
