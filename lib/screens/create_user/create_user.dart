import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pantryfox/controller/users_database.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/model/user.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/screens/create_user/widgets/check_fb_purchases.dart';
import 'package:pantryfox/services/firebaseAuth.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateUser extends StatefulWidget {
  final Function toggleView;
  CreateUser({this.toggleView});
  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final AuthService _auth = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String result = "";
  Hash hasher = sha1;

  /// In App Purchases
  FirebasePurchases fbPurchases = FirebasePurchases();
  StreamSubscription<List<PurchaseDetails>> _subscription;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final checkPasswordController = TextEditingController();

  @override
  void dispose() {
    _subscription?.cancel();
    // Clean up the controller when the Widget is disposed
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    checkPasswordController.dispose();
    super.dispose();
  }

  //TODO: Loading Purchase UI Event

  @override
  void initState() {
    Stream purchaseUpdated = InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      fbPurchases.listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    // Create an event for -> initStoreInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: myAppBarWithShadowText(title: LocaleKeys.createAccount.tr()),
        bottomNavigationBar: myBottomAppBar(
            context, shadowText(' ', smallTextSize), helpButton(context, LocaleKeys.passwordHelp.tr())),
        body: standardContainer(Center(
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              getTextField(LocaleKeys.userName.tr(), nameController, false, TextInputType.text, context),
              new SizedBox(
                height: 10.0,
              ),
              getTextField(
                  LocaleKeys.email.tr(), emailController, false, TextInputType.emailAddress, context),
              new SizedBox(
                height: 10.0,
              ),
              getTextField(LocaleKeys.password.tr(), passwordController, true, TextInputType.text, context),
              new SizedBox(
                height: 10.0,
              ),
              getTextField(
                  LocaleKeys.password.tr(), checkPasswordController, true, TextInputType.text, context),
              new SizedBox(
                height: 10.0,
              ),
              submitButton(context),
              fbPurchases.buildConnectionCheckTile(),
              // _buildProductList(),
            ],
          )),
        )) // End standardContainer.

        );
  }

  Widget submitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: GestureDetector(
          onTap: () async {
            if (nameController.text.length < 1) {
              alertInvalidField(LocaleKeys.noName.tr(), LocaleKeys.noNameHelp.tr());
            } else if (passwordController.text != checkPasswordController.text) {
              alertInvalidField(LocaleKeys.passwordMismatch.tr(), LocaleKeys.passwordMismatchHelp.tr());
              // TODO: replace with bloc validation
            } else if (passwordController.text.length < 8 ||
                !passwordController.text.contains(new RegExp(r'[a-z]')) ||
                !passwordController.text.contains(new RegExp(r'[A-Z]')) ||
                !passwordController.text.contains(new RegExp(r'[0-9]'))) {
              alertInvalidField(
                  LocaleKeys.password.tr() + LocaleKeys.help.tr(), LocaleKeys.passwordHelp.tr());
            } else {
              PantryUser user = new PantryUser();
              String password = passwordController.text;

              user.email = emailController.text.toLowerCase().trim();

              //Register in Firebase
              PantryUser fbUser =
                  await _auth.registerWithEmailAndPassword(user.email, password, _scaffoldKey);
              insertUserToDatabase(fbUser);

              Navigator.pop(context); // Goes back to login page.
            }
          },
          child: buttonContainer(myColorArray[2], LocaleKeys.submit.tr(), mediumTextSize)),
    );
  }

  // ignore: missing_return
  Future<void> insertUserToDatabase(PantryUser user) async {
    UsersSqflite usersSqflite;

    usersSqflite = new UsersSqflite();
    await usersSqflite.init();
    await usersSqflite.bean.insert(user);
  }

  // Alert user of an invalid field.
  void alertInvalidField(String messageTitle, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return myCustomAlert(context, messageTitle, message);
      },
    );
  }
} //End of Class
