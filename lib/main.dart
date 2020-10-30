import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pantryfox/bloc/details_bloc/details_bloc_bloc.dart';
import 'package:pantryfox/bloc/history/history_bloc.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/route_names.dart';
import 'package:pantryfox/screens/authenticate.dart';
import 'package:pantryfox/screens/create_user/create_user.dart';
import 'package:pantryfox/screens/history_page/history_page.dart';
import 'package:pantryfox/screens/homepage/homePage.dart';
import 'package:pantryfox/screens/login/login.dart';
import 'package:pantryfox/screens/settings/settings.dart';
import 'package:pantryfox/screens/settings/widgets/settings_bloc.dart';
import 'package:pantryfox/screens/upc_details/details.dart';
import 'screens/login/widgets/login_bloc.dart';
import 'bloc/theme_bloc.dart';
import 'bloc/upc_event_state_bloc.dart';
import 'repository/upc_repository.dart';
import 'generated/codegen_loader.g.dart';

var localizationData;

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  Bloc.observer = SimpleBlocObserver();
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('de', 'DE'), Locale('fr', 'FR'), Locale('es', 'ES')],
        path: 'assets/langs',
        assetLoader: CodegenLoader(),
        fallbackLocale: Locale('en', 'US'),
        child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp().then((value) => {debugPrint("Firebase app => ${value.name} => is ready... ?")});
    return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(create: (BuildContext context) => ThemeBloc(getTheme())),
          BlocProvider<LoginBloc>(create: (BuildContext context) => BlocProvider.of<LoginBloc>(context)),
          BlocProvider<SettingsFormBloc>(
              create: (BuildContext context) => BlocProvider.of<SettingsFormBloc>(context)),
          BlocProvider<UpcEventStateBloc>(
            create: (BuildContext context) => UpcEventStateBloc(UpcRepository()),
            child: ScanHomePage(),
          ),
          BlocProvider<DetailsBlocBloc>(
            create: (BuildContext context) => BlocProvider.of<DetailsBlocBloc>(context),
            child: DetailsPage(),
          ),
          BlocProvider<HistoryBloc>(
            create: (BuildContext context) => BlocProvider.of<HistoryBloc>(context),
            child: HistoryPage(),
          ),
        ],
        // ChildA()
        child: BlocBuilder<ThemeBloc, ThemeData>(
          builder: (context, theme) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              title: 'PantryFox',
              home: Authenticate(),
              theme: getTheme(),
              routes: {
                PantryRoute.home: (context) => ScanHomePage(),
                PantryRoute.login: (context) => LoginPage(),
                PantryRoute.settings: (context) => SettingsPage(),
                PantryRoute.createUser: (context) => CreateUser(),
                PantryRoute.upcDetails: (context) => DetailsPage(),
                PantryRoute.upcHistory: (context) => HistoryPage(),
              },
              debugShowCheckedModeBanner: false,
              // themeMode: ThemeMode.system, //maybe?
            );
          },
        ));
  }
}

ThemeData getTheme() {
  return ThemeData(
    primaryColor: myColorArray[1] ?? Colors.blueAccent[100],
    accentColor: myColorArray[0] ?? Colors.yellow[200],
    backgroundColor: myColorArray[0],
    textTheme: TextTheme(
      bodyText2: TextStyle(
        color: Colors.black,
        fontFamily: 'Times',
      ),
      button: TextStyle(
        color: Colors.white,
        fontFamily: 'Times',
      ),
      headline6: TextStyle(
        color: Colors.white,
        fontFamily: 'Times',
      ),
    ),
  );
}
